import 'dart:async';

import 'package:serverpod_cloud_cli/util/stream_util.dart';
import 'package:test/test.dart';

void main() {
  group('cancelOnInterrupt -', () {
    test(
      'Given a source stream and an interrupt stream '
      'when the interrupt stream emits '
      'then StreamInterruptedException is thrown and the source is cancelled',
      () async {
        final source = StreamController<int>();
        final interrupt = StreamController<void>();

        final result = cancelOnInterrupt(
          source.stream,
          interrupt.stream,
        ).listen((_) {}, onError: (_) {});

        source.add(1);
        await Future<void>.delayed(Duration.zero);
        interrupt.add(null);

        await expectLater(
          result.asFuture(),
          throwsA(isA<StreamInterruptedException>()),
        );

        expect(source.hasListener, isFalse);

        await source.close();
        await interrupt.close();
      },
    );

    test('Given a source stream and an interrupt stream '
        'when the interrupt stream emits '
        'then the returned stream terminates with the error', () async {
      final source = StreamController<int>();
      final interrupt = StreamController<void>();

      final resultFuture = cancelOnInterrupt(
        source.stream,
        interrupt.stream,
      ).toList();

      interrupt.add(null);

      await expectLater(
        resultFuture,
        throwsA(isA<StreamInterruptedException>()),
      );

      await source.close();
      await interrupt.close();
    });

    test('Given a source stream that completes '
        'when no interrupt occurs '
        'then all source events are emitted', () async {
      final interrupt = StreamController<void>();

      final result = await cancelOnInterrupt(
        Stream.fromIterable([1, 2, 3]),
        interrupt.stream,
      ).toList();

      expect(result, [1, 2, 3]);

      await interrupt.close();
    });
  });

  group('withFallback -', () {
    test(
      'Given a stream with multiple elements '
      'when withFallback is called '
      'then the original elements are emitted and the fallback is not used',
      () async {
        final source = Stream<int>.fromIterable([1, 2, 3]);

        final result = await withFallback(source, -1).toList();

        expect(result, [1, 2, 3]);
      },
    );

    test('Given a stream with a single element '
        'when withFallback is called '
        'then only that element is emitted', () async {
      final source = Stream<int>.fromIterable([42]);

      final result = await withFallback(source, -1).toList();

      expect(result, [42]);
    });

    test('Given an empty stream '
        'when withFallback is called '
        'then the fallback element is emitted', () async {
      final source = Stream<int>.empty();

      final result = await withFallback(source, -1).toList();

      expect(result, [-1]);
    });

    test(
      'Given a stream that emits an error before any event '
      'when withFallback is called '
      'then the error is propagated and the fallback is not emitted',
      () async {
        final source = Stream<int>.error(Exception('boom'));

        await expectLater(
          withFallback(source, -1).toList(),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('Given a stream that emits events and then an error '
        'when withFallback is called '
        'then the events are emitted before the error is propagated', () async {
      final controller = StreamController<int>();
      final emitted = <int>[];
      final completer = Completer<Object>();

      withFallback(
        controller.stream,
        -1,
      ).listen(emitted.add, onError: completer.complete);

      controller
        ..add(1)
        ..add(2)
        ..addError(Exception('boom'));

      final error = await completer.future;

      expect(emitted, [1, 2]);
      expect(error, isA<Exception>());

      await controller.close();
    });
  });

  group('SplitStreams -', () {
    test('Given a source with events of multiple keys '
        'when the streams are collected '
        'then each substream receives only its classified events', () async {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even', 'odd'],
        (e) => e.isEven ? 'even' : 'odd',
        (_) => false,
      );

      final evenFuture = split.getStream('even').toList();
      final oddFuture = split.getStream('odd').toList();

      source
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);
      await source.close();

      expect(await evenFuture, [2, 4]);
      expect(await oddFuture, [1, 3]);
    });

    test('Given an event flagged as the last in its substream '
        'when that event is processed '
        'then the substream is closed after emitting it', () async {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even', 'odd'],
        (e) => e.isEven ? 'even' : 'odd',
        (e) => e == 2,
      );

      final evenFuture = split.getStream('even').toList();
      final oddFuture = split.getStream('odd').toList();

      source
        ..add(1)
        ..add(2)
        ..add(3);
      await source.close();

      expect(await evenFuture, [2]);
      expect(await oddFuture, [1, 3]);
    });

    test('Given a source that completes before all substreams see their last '
        'when the source is done '
        'then all remaining open substreams are closed', () async {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even', 'odd'],
        (e) => e.isEven ? 'even' : 'odd',
        (_) => false,
      );

      final evenFuture = split.getStream('even').toList();
      final oddFuture = split.getStream('odd').toList();

      source.add(1);
      await source.close();

      expect(await evenFuture, isEmpty);
      expect(await oddFuture, [1]);
    });

    test('Given a source that ends with an error '
        'when the error occurs '
        'then it is propagated to all substreams not yet closed', () async {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even', 'odd'],
        (e) => e.isEven ? 'even' : 'odd',
        (_) => false,
      );

      final evenFuture = split.getStream('even').toList();
      final oddFuture = split.getStream('odd').toList();

      source.addError(Exception('boom'));

      await expectLater(evenFuture, throwsA(isA<Exception>()));
      await expectLater(oddFuture, throwsA(isA<Exception>()));

      await source.close();
    });

    test('Given a substream already closed by its last event '
        'when the source ends with an error '
        'then the error is not propagated to the closed substream', () async {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even', 'odd'],
        (e) => e.isEven ? 'even' : 'odd',
        (e) => e == 2,
      );

      final evenFuture = split.getStream('even').toList();
      final oddFuture = split.getStream('odd').toList();

      source.add(2);
      await Future<void>.delayed(Duration.zero);
      source.addError(Exception('boom'));

      expect(await evenFuture, [2]);
      await expectLater(oddFuture, throwsA(isA<Exception>()));

      await source.close();
    });

    test('Given a key that was not registered '
        'when getStream is called for it '
        'then a StateError is thrown', () {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even'],
        (_) => 'even',
        (_) => false,
      );

      expect(() => split.getStream('missing'), throwsA(isA<StateError>()));

      source.close();
    });

    test('Given a classify function that returns an unregistered key '
        'when an event is processed '
        'then a StateError is raised', () async {
      final source = StreamController<int>();
      final errors = <Object>[];

      await runZonedGuarded(() async {
        SplitStreams<String, int>(
          source.stream,
          ['even'],
          (_) => 'unregistered',
          (_) => false,
        );

        source.add(1);
        await source.close();
        await Future<void>.delayed(Duration.zero);
      }, (error, _) => errors.add(error));

      expect(errors, isNotEmpty);
      expect(errors.first, isA<StateError>());
    });

    test('Given a source that is still active '
        'when cancel is called '
        'then the source subscription is cancelled', () async {
      final source = StreamController<int>();
      final split = SplitStreams<String, int>(
        source.stream,
        ['even'],
        (_) => 'even',
        (_) => false,
      );

      await split.cancel();

      expect(source.hasListener, isFalse);

      await source.close();
    });
  });
}

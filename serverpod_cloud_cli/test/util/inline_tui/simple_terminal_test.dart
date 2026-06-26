import 'dart:async';

import 'package:serverpod_cloud_cli/util/inline_tui/src/inline_terminal.dart';
import 'package:test/test.dart';

import '../../../test_utils/mock_stdin.dart';
import '../../../test_utils/mock_stdout.dart';

void main() {
  group('Given a StdioTerminal over a single-subscription source', () {
    late StreamController<List<int>> source;
    late StdioTerminal terminal;

    setUp(() {
      // A non-broadcast controller mirrors stdin, which can only be listened
      // to once.
      source = StreamController<List<int>>();
      terminal = StdioTerminal(inputOverride: source.stream);
    });

    tearDown(() async {
      await terminal.dispose();
      if (!source.isClosed) await source.close();
    });

    test('when input is listened to, cancelled, and listened to again '
        'then it does not throw and still delivers events', () async {
      final firstBatch = <List<int>>[];
      final firstSub = terminal.input.listen(firstBatch.add);
      await pumpEventQueue();
      source.add([65]);
      await pumpEventQueue();
      await firstSub.cancel();

      // Previously this second listen threw
      // "Bad state: Stream has already been listened to".
      final secondBatch = <List<int>>[];
      final secondSub = terminal.input.listen(secondBatch.add);
      await pumpEventQueue();
      source.add([66]);
      await pumpEventQueue();
      await secondSub.cancel();

      expect(firstBatch, [
        [65],
      ]);
      expect(secondBatch, [
        [66],
      ]);
    });

    test('when no component is listening then the source is paused so input is '
        'left for other readers instead of being drained', () async {
      // Access input once to create the (paused) source subscription, but do
      // not keep a listener.
      final firstSub = terminal.input.listen((_) {});
      await pumpEventQueue();
      await firstSub.cancel();

      // Bytes arriving while nothing is listening must not be consumed and
      // discarded; with the source paused they remain buffered for the next
      // listener (mirroring how the real stdin keeps bytes available for a
      // synchronous read in between components).
      source.add([67]);
      await pumpEventQueue();

      final batch = <List<int>>[];
      final secondSub = terminal.input.listen(batch.add);
      await pumpEventQueue();
      await secondSub.cancel();

      expect(batch, [
        [67],
      ]);
    });

    test('when input is accessed multiple times then the source is listened to '
        'only once', () async {
      final sub1 = terminal.input.listen((_) {});
      await pumpEventQueue();
      await sub1.cancel();
      final sub2 = terminal.input.listen((_) {});
      await pumpEventQueue();
      await sub2.cancel();

      // A second subscription directly on the single-subscription source would
      // throw if the terminal had re-listened to it.
      expect(() => source.stream.listen((_) {}), throwsStateError);
    });
  });

  group('Given a StdioTerminal with injected stdin/stdout', () {
    test(
      'when both stdin and stdout are terminals then hasTerminal is true',
      () {
        final terminal = StdioTerminal(
          stdinOverride: _FakeStdin(hasTerminal: true),
          stdoutOverride: MockStdout(),
        );

        expect(terminal.hasTerminal, isTrue);
      },
    );

    test('when stdin is not a terminal then hasTerminal is false', () {
      final terminal = StdioTerminal(
        stdinOverride: _FakeStdin(hasTerminal: false),
        stdoutOverride: MockStdout(),
      );

      expect(terminal.hasTerminal, isFalse);
    });
  });

  group('Given a disposed StdioTerminal', () {
    test(
      'when the source emits done then dispose completes without error',
      () async {
        final source = StreamController<List<int>>();
        final terminal = StdioTerminal(inputOverride: source.stream);

        final sub = terminal.input.listen((_) {});
        await pumpEventQueue();
        await sub.cancel();

        await expectLater(terminal.dispose(), completes);
        await source.close();
      },
    );
  });
}

/// A [MockStdin] whose [hasTerminal] can be controlled by tests.
class _FakeStdin extends MockStdin {
  @override
  bool hasTerminal;

  _FakeStdin({required this.hasTerminal}) : super(const []);
}

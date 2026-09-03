import 'dart:async';

import 'package:ground_control_client/src/streams/reconnect_stream.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:test/test.dart';

void main() {
  group('reconnectStream -', () {
    test('Given a retryable stream disconnect '
        'when the next connection succeeds '
        'then events continue from the last emitted event', () async {
      var connectionCount = 0;
      final receivedLastEvents = <int?>[];

      Stream<int> connect(int? lastEvent) async* {
        connectionCount++;
        receivedLastEvents.add(lastEvent);
        if (connectionCount == 1) {
          yield 1;
          yield 2;
          throw const WebSocketClosedException();
        }
        yield 3;
      }

      final result = await reconnectStream(
        connect,
        shouldRetry: isRetryableMethodStreamDisconnect,
        retryDelay: Duration.zero,
      ).toList();

      expect(result, [1, 2, 3]);
      expect(receivedLastEvents, [null, 2]);
    });

    test('Given retryable failures before and after a successful yield '
        'when the retry limit applies '
        'then the consecutive retry count resets after the yield', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) async* {
        connectionCount++;
        if (connectionCount <= 2) {
          throw StateError('connection closed');
        }
        if (connectionCount == 3) {
          yield 1;
          throw StateError('connection closed');
        }
        yield 2;
      }

      final result = await reconnectStream(
        connect,
        shouldRetry: (error) => error is StateError,
        maxRetries: 2,
        retryDelay: Duration.zero,
      ).toList();

      expect(result, [1, 2]);
    });

    test('Given a non-retryable stream failure '
        'when the failure occurs '
        'then the error is propagated without reconnecting', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) async* {
        connectionCount++;
        throw ArgumentError('invalid stream');
      }

      await expectLater(
        reconnectStream(
          connect,
          shouldRetry: (error) => error is StateError,
          retryDelay: Duration.zero,
        ).toList(),
        throwsA(isA<ArgumentError>()),
      );
      expect(connectionCount, 1);
    });

    test('Given opening a method stream is rejected '
        'when reconnectStream receives the error '
        'then the connection is not retried', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) {
        connectionCount++;
        return Stream.error(
          const OpenMethodStreamException(
            OpenMethodStreamResponseType.authenticationFailed,
          ),
        );
      }

      await expectLater(
        reconnectStream(
          connect,
          shouldRetry: isRetryableMethodStreamDisconnect,
          retryDelay: Duration.zero,
        ).toList(),
        throwsA(isA<OpenMethodStreamException>()),
      );
      expect(connectionCount, 1);
    });

    test('Given connect throws a non-retryable error synchronously '
        'when reconnectStream listens '
        'then the error is propagated without reconnecting', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) {
        connectionCount++;
        throw ArgumentError('invalid stream');
      }

      await expectLater(
        reconnectStream(
          connect,
          shouldRetry: (error) => error is StateError,
          retryDelay: Duration.zero,
        ).toList(),
        throwsA(isA<ArgumentError>()),
      );
      expect(connectionCount, 1);
    });

    test('Given connect throws a retryable error synchronously '
        'when the next connection succeeds '
        'then reconnectStream opens another connection', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) {
        connectionCount++;
        if (connectionCount == 1) {
          throw StateError('connection closed');
        }
        return Stream.value(42);
      }

      final result = await reconnectStream(
        connect,
        shouldRetry: (error) => error is StateError,
        retryDelay: Duration.zero,
      ).toList();

      expect(result, [42]);
      expect(connectionCount, 2);
    });

    test('Given consecutive retryable stream failures '
        'when the retry limit is exhausted '
        'then the final error is propagated', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) async* {
        connectionCount++;
        throw StateError('connection closed');
      }

      await expectLater(
        reconnectStream(
          connect,
          shouldRetry: (error) => error is StateError,
          maxRetries: 2,
          retryDelay: Duration.zero,
        ).toList(),
        throwsA(isA<StateError>()),
      );
      expect(connectionCount, 3);
    });

    test('Given a retry delay '
        'when the subscriber cancels during the delay '
        'then no further connection is opened', () async {
      var connectionCount = 0;

      Stream<int> connect(int? _) async* {
        connectionCount++;
        throw StateError('connection closed');
      }

      final subscription = reconnectStream(
        connect,
        shouldRetry: (error) => error is StateError,
        maxRetries: 5,
        retryDelay: const Duration(milliseconds: 20),
      ).listen((_) {}, onError: (_, _) {});

      await pumpEventQueue();
      await subscription.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(connectionCount, 1);
    });
  });
}

import 'dart:async';

import 'package:serverpod_client/serverpod_client.dart';

/// Whether [error] represents a method-stream transport disconnect that can
/// be retried by opening a new stream.
bool isRetryableMethodStreamDisconnect(Object error) =>
    error is WebSocketClosedException ||
    error is MethodStreamIdleTimeoutException ||
    error is WebSocketConnectException ||
    error is WebSocketListenException ||
    error is ConnectionClosedException ||
    error is ConnectionAttemptTimedOutException;

/// Recreates a stream after retryable errors, passing the last emitted event
/// to each subsequent connection.
///
/// Cancelling the returned stream cancels the current connection and any
/// pending retry delay.
Stream<T> reconnectStream<T>(
  Stream<T> Function(T? lastEvent) connect, {
  required bool Function(Object error) shouldRetry,
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 2),
}) {
  late final StreamController<T> controller;
  StreamSubscription<T>? inner;
  Timer? retryTimer;
  T? lastEvent;
  var retryCount = 0;
  var isClosed = false;
  late final void Function() connectNow;

  void handleError(Object error, StackTrace stackTrace) {
    if (isClosed || controller.isClosed) {
      return;
    }
    if (!shouldRetry(error) || retryCount >= maxRetries) {
      controller.addError(error, stackTrace);
      controller.close();
      return;
    }
    retryCount++;
    retryTimer?.cancel();
    retryTimer = Timer(retryDelay, connectNow);
  }

  connectNow = () {
    if (isClosed) {
      return;
    }
    late final Stream<T> stream;
    try {
      stream = connect(lastEvent);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return;
    }
    late final StreamSubscription<T> subscription;
    subscription = stream.listen(
      (event) {
        lastEvent = event;
        retryCount = 0;
        if (!controller.isClosed) {
          controller.add(event);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed || controller.isClosed || inner != subscription) {
          return;
        }
        inner = null;
        unawaited(subscription.cancel());
        handleError(error, stackTrace);
      },
      onDone: () {
        if (isClosed || controller.isClosed || inner != subscription) {
          return;
        }
        inner = null;
        controller.close();
      },
    );
    inner = subscription;
  };

  controller = StreamController<T>(
    onListen: connectNow,
    onPause: () => inner?.pause(),
    onResume: () => inner?.resume(),
    onCancel: () async {
      isClosed = true;
      retryTimer?.cancel();
      retryTimer = null;
      final subscription = inner;
      inner = null;
      await subscription?.cancel();
    },
  );

  return controller.stream;
}

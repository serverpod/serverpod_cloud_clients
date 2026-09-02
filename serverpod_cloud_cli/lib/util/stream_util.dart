import 'dart:async';

/// Thrown when a stream wrapped with [cancelOnInterrupt] is cancelled by an
/// interrupt signal.
class StreamInterruptedException implements Exception {}

/// Returns a stream that forwards events from [source] until [interrupt]
/// emits, then cancels [source] and completes with
/// [StreamInterruptedException].
///
/// [interrupt] must be a broadcast stream if the caller wraps more than one
/// source with the same interrupt stream.
Stream<T> cancelOnInterrupt<T>(Stream<T> source, Stream<void> interrupt) {
  StreamSubscription<T>? sourceSubscription;
  StreamSubscription<void>? interruptSubscription;
  final controller = StreamController<T>();
  var interrupted = false;

  controller.onListen = () {
    sourceSubscription = source.listen(
      controller.add,
      onError: controller.addError,
      onDone: () {
        if (!interrupted && !controller.isClosed) {
          controller.close();
        }
      },
    );

    interruptSubscription = interrupt.listen((_) async {
      if (interrupted) {
        return;
      }
      interrupted = true;
      await sourceSubscription?.cancel();
      if (!controller.isClosed) {
        controller.addError(StreamInterruptedException());
        await controller.close();
      }
    });
  };

  controller.onCancel = () async {
    await sourceSubscription?.cancel();
    await interruptSubscription?.cancel();
  };

  return controller.stream;
}

/// Returns a stream that emits the events from the given stream,
/// or the fallback element if the stream is empty.
Stream<T> withFallback<T>(Stream<T> stream, T fallbackElement) async* {
  var isEmpty = true;
  await for (final event in stream) {
    isEmpty = false;
    yield event;
  }
  if (isEmpty) {
    yield fallbackElement;
  }
}

/// Splits a stream into multiple streams based on the classification function.
/// The streams are closed when the last element in the source stream is emitted.
/// If the source stream ends with an error, it is propagated to all streams not
/// yet closed.
class SplitStreams<K, E> {
  final Map<K, StreamController<E>> _controllers = {};
  late final StreamSubscription<E> _sourceSubscription;

  SplitStreams(
    Stream<E> source,
    Iterable<K> keys,
    K Function(E) classify,
    bool Function(E) isLastInSubstream,
  ) {
    for (final key in keys) {
      _controllers[key] = StreamController<E>();
    }

    _sourceSubscription = source.listen(
      (event) {
        final key = classify(event);
        final ctrl = _controllers[key];
        if (ctrl == null) {
          throw StateError('Unknown key: $key');
        }
        ctrl.add(event);
        if (isLastInSubstream(event)) {
          ctrl.close();
        }
      },
      onError: (e, st) {
        for (final ctrl in _controllers.values) {
          if (!ctrl.isClosed) ctrl.addError(e, st);
        }
      },
      onDone: () {
        for (final ctrl in _controllers.values) {
          if (!ctrl.isClosed) ctrl.close();
        }
      },
    );
  }

  Future<void> cancel() => _sourceSubscription.cancel();

  Stream<E> getStream(K key) {
    final ctrl = _controllers[key];
    if (ctrl == null) {
      throw StateError('No such key: $key');
    }
    return ctrl.stream;
  }
}

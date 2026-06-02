import 'dart:async' show StreamController;

/// Returns a stream that emits the events from the given stream,
/// or the fallback element if the stream is empty.
Stream<T> withFallback<T>(
  final Stream<T> stream,
  final T fallbackElement,
) async* {
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

  SplitStreams(
    final Stream<E> source,
    final Iterable<K> keys,
    final K Function(E) classify,
    final bool Function(E) isLastInSubstream,
  ) {
    for (final key in keys) {
      _controllers[key] = StreamController<E>();
    }

    source.listen(
      (final event) {
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
      onError: (final e, final st) {
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

  Stream<E> getStream(final K key) {
    final ctrl = _controllers[key];
    if (ctrl == null) {
      throw StateError('No such key: $key');
    }
    return ctrl.stream;
  }
}

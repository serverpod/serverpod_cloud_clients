import 'output_format.dart';

typedef QualifiedException = ({Exception exception, StackTrace stackTrace});

/// Context for building [OutputWidget] UIs.
/// Carries data when building the widget tree.
class OutputContext {
  final OutputFormat format;

  final Map<Type, Object> _objects;

  OutputContext(this.format, [final Object? object])
    : _objects = {if (object != null) object.runtimeType: object};

  OutputContext.exception(
    final OutputFormat format,
    final Exception exception,
    final StackTrace stackTrace,
  ) : this(format, (exception: exception, stackTrace: stackTrace));

  void put<O extends Object>(final O object) {
    _objects[O] = object;
  }

  O get<O extends Object>() {
    final O? obj = _objects.values.whereType<O>().firstOrNull;
    if (obj == null) {
      throw StateError('Object of type $O not found in context');
    }
    return obj;
  }

  O? find<O extends Object>() {
    return _objects.values.whereType<O>().firstOrNull;
  }
}

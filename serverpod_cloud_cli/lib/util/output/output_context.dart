import 'output_format.dart';

/// Context for building [OutputWidget] UIs.
/// Carries data when building the widget tree.
class OutputContext {
  final OutputFormat format;

  final Object? error;

  final Map<Type, Object> _objects;

  OutputContext(this.format, [final Object? object])
    : _objects = {if (object != null) object.runtimeType: object},
      error = null;

  OutputContext.error(this.format, Object this.error) : _objects = {};

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
}

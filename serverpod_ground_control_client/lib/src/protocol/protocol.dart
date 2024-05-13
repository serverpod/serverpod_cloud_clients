/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'infrastrucutre/database_provider.dart' as _i2;
import 'infrastrucutre/database_resource.dart' as _i3;
import 'project.dart' as _i4;
import 'serverpod_region.dart' as _i5;
export 'infrastrucutre/database_provider.dart';
export 'infrastrucutre/database_resource.dart';
export 'project.dart';
export 'serverpod_region.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.DatabaseProvider) {
      return _i2.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i3.DatabaseResource) {
      return _i3.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i4.Project) {
      return _i4.Project.fromJson(data) as T;
    }
    if (t == _i5.ServerpodRegion) {
      return _i5.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.DatabaseProvider?>()) {
      return (data != null ? _i2.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DatabaseResource?>()) {
      return (data != null ? _i3.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Project?>()) {
      return (data != null ? _i4.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ServerpodRegion?>()) {
      return (data != null ? _i5.ServerpodRegion.fromJson(data) : null) as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.DatabaseProvider) {
      return 'DatabaseProvider';
    }
    if (data is _i3.DatabaseResource) {
      return 'DatabaseResource';
    }
    if (data is _i4.Project) {
      return 'Project';
    }
    if (data is _i5.ServerpodRegion) {
      return 'ServerpodRegion';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'DatabaseProvider') {
      return deserialize<_i2.DatabaseProvider>(data['data']);
    }
    if (data['className'] == 'DatabaseResource') {
      return deserialize<_i3.DatabaseResource>(data['data']);
    }
    if (data['className'] == 'Project') {
      return deserialize<_i4.Project>(data['data']);
    }
    if (data['className'] == 'ServerpodRegion') {
      return deserialize<_i5.ServerpodRegion>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}

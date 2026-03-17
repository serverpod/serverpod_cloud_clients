/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../domains/products/models/database_scaling_info.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

/// Definition of a database size option with its default CU configuration.
abstract class DatabaseSizeInfo implements _i1.SerializableModel {
  DatabaseSizeInfo._({required this.name, this.scaling});

  factory DatabaseSizeInfo({
    required String name,
    _i2.DatabaseScalingInfo? scaling,
  }) = _DatabaseSizeInfoImpl;

  factory DatabaseSizeInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseSizeInfo(
      name: jsonSerialization['name'] as String,
      scaling: jsonSerialization['scaling'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.DatabaseScalingInfo>(
              jsonSerialization['scaling'],
            ),
    );
  }

  /// The name identifier for this database size.
  String name;

  /// Scaling configuration, if this size supports variable CU allocation.
  _i2.DatabaseScalingInfo? scaling;

  /// Returns a shallow copy of this [DatabaseSizeInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseSizeInfo copyWith({String? name, _i2.DatabaseScalingInfo? scaling});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseSizeInfo',
      'name': name,
      if (scaling != null) 'scaling': scaling?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseSizeInfoImpl extends DatabaseSizeInfo {
  _DatabaseSizeInfoImpl({
    required String name,
    _i2.DatabaseScalingInfo? scaling,
  }) : super._(name: name, scaling: scaling);

  /// Returns a shallow copy of this [DatabaseSizeInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseSizeInfo copyWith({String? name, Object? scaling = _Undefined}) {
    return DatabaseSizeInfo(
      name: name ?? this.name,
      scaling: scaling is _i2.DatabaseScalingInfo?
          ? scaling
          : this.scaling?.copyWith(),
    );
  }
}

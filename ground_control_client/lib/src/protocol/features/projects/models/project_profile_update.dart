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
import '../../../domains/capsules/models/compute_size_option.dart' as _i2;
import '../../../features/databases/models/database_size.dart' as _i3;

/// Payload for updating a project profile together with compute scaling and
/// If null is provided for a field, the field is not updated.
abstract class ProjectProfileUpdate implements _i1.SerializableModel {
  ProjectProfileUpdate._({
    this.projectProductId,
    this.size,
    this.minInstances,
    this.maxInstances,
    this.databaseSize,
    this.minCu,
    this.maxCu,
  });

  factory ProjectProfileUpdate({
    String? projectProductId,
    _i2.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    _i3.DatabaseSizeOption? databaseSize,
    double? minCu,
    double? maxCu,
  }) = _ProjectProfileUpdateImpl;

  factory ProjectProfileUpdate.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ProjectProfileUpdate(
      projectProductId: jsonSerialization['projectProductId'] as String?,
      size: jsonSerialization['size'] == null
          ? null
          : _i2.ComputeSizeOption.fromJson(
              (jsonSerialization['size'] as String),
            ),
      minInstances: jsonSerialization['minInstances'] as int?,
      maxInstances: jsonSerialization['maxInstances'] as int?,
      databaseSize: jsonSerialization['databaseSize'] == null
          ? null
          : _i3.DatabaseSizeOption.fromJson(
              (jsonSerialization['databaseSize'] as String),
            ),
      minCu: (jsonSerialization['minCu'] as num?)?.toDouble(),
      maxCu: (jsonSerialization['maxCu'] as num?)?.toDouble(),
    );
  }

  /// The procured project product id to assign to the project.
  String? projectProductId;

  /// Podlet (compute) size for the capsule.
  _i2.ComputeSizeOption? size;

  /// Minimum number of podlet instances.
  int? minInstances;

  /// Maximum number of podlet instances.
  int? maxInstances;

  /// When null, database sizing is not changed.
  _i3.DatabaseSizeOption? databaseSize;

  /// Database compute minimum, when updating database sizing.
  double? minCu;

  /// Database compute maximum, when updating database sizing.
  double? maxCu;

  /// Returns a shallow copy of this [ProjectProfileUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectProfileUpdate copyWith({
    String? projectProductId,
    _i2.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    _i3.DatabaseSizeOption? databaseSize,
    double? minCu,
    double? maxCu,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectProfileUpdate',
      if (projectProductId != null) 'projectProductId': projectProductId,
      if (size != null) 'size': size?.toJson(),
      if (minInstances != null) 'minInstances': minInstances,
      if (maxInstances != null) 'maxInstances': maxInstances,
      if (databaseSize != null) 'databaseSize': databaseSize?.toJson(),
      if (minCu != null) 'minCu': minCu,
      if (maxCu != null) 'maxCu': maxCu,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectProfileUpdateImpl extends ProjectProfileUpdate {
  _ProjectProfileUpdateImpl({
    String? projectProductId,
    _i2.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    _i3.DatabaseSizeOption? databaseSize,
    double? minCu,
    double? maxCu,
  }) : super._(
         projectProductId: projectProductId,
         size: size,
         minInstances: minInstances,
         maxInstances: maxInstances,
         databaseSize: databaseSize,
         minCu: minCu,
         maxCu: maxCu,
       );

  /// Returns a shallow copy of this [ProjectProfileUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectProfileUpdate copyWith({
    Object? projectProductId = _Undefined,
    Object? size = _Undefined,
    Object? minInstances = _Undefined,
    Object? maxInstances = _Undefined,
    Object? databaseSize = _Undefined,
    Object? minCu = _Undefined,
    Object? maxCu = _Undefined,
  }) {
    return ProjectProfileUpdate(
      projectProductId: projectProductId is String?
          ? projectProductId
          : this.projectProductId,
      size: size is _i2.ComputeSizeOption? ? size : this.size,
      minInstances: minInstances is int? ? minInstances : this.minInstances,
      maxInstances: maxInstances is int? ? maxInstances : this.maxInstances,
      databaseSize: databaseSize is _i3.DatabaseSizeOption?
          ? databaseSize
          : this.databaseSize,
      minCu: minCu is double? ? minCu : this.minCu,
      maxCu: maxCu is double? ? maxCu : this.maxCu,
    );
  }
}

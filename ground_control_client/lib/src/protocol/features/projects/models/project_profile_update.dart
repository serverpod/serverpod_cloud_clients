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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/capsules/models/compute_size_option.dart' as _ike5w393;
import '../../../domains/databases/models/database_size.dart' as _its7dxaf;
import '../../../domains/products/models/plan_type.dart' as _iic46wsa;

/// Payload for updating a project profile together with compute scaling and
/// database sizing.
///
/// If null is provided for a field, the field is not updated.
abstract class ProjectProfileUpdate
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ProjectProfileUpdate._({
    this.projectProductId,
    this.planType,
    this.size,
    this.minInstances,
    this.maxInstances,
    this.databaseSize,
    this.minCu,
    this.maxCu,
  });

  factory ProjectProfileUpdate({
    String? projectProductId,
    _iic46wsa.PlanType? planType,
    _ike5w393.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    _its7dxaf.DatabaseSizeOption? databaseSize,
    double? minCu,
    double? maxCu,
  }) = _ProjectProfileUpdateImpl;

  factory ProjectProfileUpdate.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ProjectProfileUpdate(
      projectProductId: jsonSerialization['projectProductId'] as String?,
      planType: jsonSerialization['planType'] == null
          ? null
          : _iic46wsa.PlanType.fromJson(
              (jsonSerialization['planType'] as String),
            ),
      size: jsonSerialization['size'] == null
          ? null
          : _ike5w393.ComputeSizeOption.fromJson(
              (jsonSerialization['size'] as String),
            ),
      minInstances: jsonSerialization['minInstances'] as int?,
      maxInstances: jsonSerialization['maxInstances'] as int?,
      databaseSize: jsonSerialization['databaseSize'] == null
          ? null
          : _its7dxaf.DatabaseSizeOption.fromJson(
              (jsonSerialization['databaseSize'] as String),
            ),
      minCu: (jsonSerialization['minCu'] as num?)?.toDouble(),
      maxCu: (jsonSerialization['maxCu'] as num?)?.toDouble(),
    );
  }

  /// DEPRECATED: This field is ignored. Use planType instead.
  String? projectProductId;

  /// The type of plan to procure for the project.
  /// If null, the existing plan is not changed.
  _iic46wsa.PlanType? planType;

  /// Podlet (compute) size for the capsule.
  /// If null, compute sizing is not changed from the default or current value.
  _ike5w393.ComputeSizeOption? size;

  /// Minimum number of podlet instances.
  int? minInstances;

  /// Maximum number of podlet instances.
  int? maxInstances;

  /// Database size for the capsule.
  /// If null, database sizing is not changed from the default or current value.
  _its7dxaf.DatabaseSizeOption? databaseSize;

  /// Database compute minimum, when updating database sizing.
  double? minCu;

  /// Database compute maximum, when updating database sizing.
  double? maxCu;

  /// Returns a shallow copy of this [ProjectProfileUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProjectProfileUpdate copyWith({
    String? projectProductId,
    _iic46wsa.PlanType? planType,
    _ike5w393.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    _its7dxaf.DatabaseSizeOption? databaseSize,
    double? minCu,
    double? maxCu,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectProfileUpdate',
      if (projectProductId != null) 'projectProductId': projectProductId,
      if (planType != null) 'planType': planType?.toJson(),
      if (size != null) 'size': size?.toJson(),
      if (minInstances != null) 'minInstances': minInstances,
      if (maxInstances != null) 'maxInstances': maxInstances,
      if (databaseSize != null) 'databaseSize': databaseSize?.toJson(),
      if (minCu != null) 'minCu': minCu,
      if (maxCu != null) 'maxCu': maxCu,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectProfileUpdate',
      if (projectProductId != null) 'projectProductId': projectProductId,
      if (planType != null) 'planType': planType?.toJson(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectProfileUpdateImpl extends ProjectProfileUpdate {
  _ProjectProfileUpdateImpl({
    String? projectProductId,
    _iic46wsa.PlanType? planType,
    _ike5w393.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    _its7dxaf.DatabaseSizeOption? databaseSize,
    double? minCu,
    double? maxCu,
  }) : super._(
         projectProductId: projectProductId,
         planType: planType,
         size: size,
         minInstances: minInstances,
         maxInstances: maxInstances,
         databaseSize: databaseSize,
         minCu: minCu,
         maxCu: maxCu,
       );

  /// Returns a shallow copy of this [ProjectProfileUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProjectProfileUpdate copyWith({
    Object? projectProductId = _Undefined,
    Object? planType = _Undefined,
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
      planType: planType is _iic46wsa.PlanType? ? planType : this.planType,
      size: size is _ike5w393.ComputeSizeOption? ? size : this.size,
      minInstances: minInstances is int? ? minInstances : this.minInstances,
      maxInstances: maxInstances is int? ? maxInstances : this.maxInstances,
      databaseSize: databaseSize is _its7dxaf.DatabaseSizeOption?
          ? databaseSize
          : this.databaseSize,
      minCu: minCu is double? ? minCu : this.minCu,
      maxCu: maxCu is double? ? maxCu : this.maxCu,
    );
  }
}

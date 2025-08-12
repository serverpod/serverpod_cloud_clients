/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../domains/capsules/models/capsule.dart' as _i2;

abstract class CapsuleResource implements _i1.SerializableModel {
  CapsuleResource._({
    this.id,
    required this.cloudCapsuleId,
    this.capsule,
    required this.computeSize,
    bool? computeScalingEnabled,
    required this.computeResourceQuota,
  }) : computeScalingEnabled = computeScalingEnabled ?? false;

  factory CapsuleResource({
    int? id,
    required int cloudCapsuleId,
    _i2.Capsule? capsule,
    required String computeSize,
    bool? computeScalingEnabled,
    required String computeResourceQuota,
  }) = _CapsuleResourceImpl;

  factory CapsuleResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapsuleResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as int,
      capsule: jsonSerialization['capsule'] == null
          ? null
          : _i2.Capsule.fromJson(
              (jsonSerialization['capsule'] as Map<String, dynamic>)),
      computeSize: jsonSerialization['computeSize'] as String,
      computeScalingEnabled: jsonSerialization['computeScalingEnabled'] as bool,
      computeResourceQuota: jsonSerialization['computeResourceQuota'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The foreign key to the capsule.
  int cloudCapsuleId;

  /// The capsule this resource config belongs to.
  _i2.Capsule? capsule;

  /// The size of the capsule compute.
  String computeSize;

  /// Flag to enable horizontal scaling for the capsule compute.
  bool computeScalingEnabled;

  /// The resource quota for the capsule compute.
  String computeResourceQuota;

  /// Returns a shallow copy of this [CapsuleResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleResource copyWith({
    int? id,
    int? cloudCapsuleId,
    _i2.Capsule? capsule,
    String? computeSize,
    bool? computeScalingEnabled,
    String? computeResourceQuota,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      if (capsule != null) 'capsule': capsule?.toJson(),
      'computeSize': computeSize,
      'computeScalingEnabled': computeScalingEnabled,
      'computeResourceQuota': computeResourceQuota,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapsuleResourceImpl extends CapsuleResource {
  _CapsuleResourceImpl({
    int? id,
    required int cloudCapsuleId,
    _i2.Capsule? capsule,
    required String computeSize,
    bool? computeScalingEnabled,
    required String computeResourceQuota,
  }) : super._(
          id: id,
          cloudCapsuleId: cloudCapsuleId,
          capsule: capsule,
          computeSize: computeSize,
          computeScalingEnabled: computeScalingEnabled,
          computeResourceQuota: computeResourceQuota,
        );

  /// Returns a shallow copy of this [CapsuleResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleResource copyWith({
    Object? id = _Undefined,
    int? cloudCapsuleId,
    Object? capsule = _Undefined,
    String? computeSize,
    bool? computeScalingEnabled,
    String? computeResourceQuota,
  }) {
    return CapsuleResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      capsule: capsule is _i2.Capsule? ? capsule : this.capsule?.copyWith(),
      computeSize: computeSize ?? this.computeSize,
      computeScalingEnabled:
          computeScalingEnabled ?? this.computeScalingEnabled,
      computeResourceQuota: computeResourceQuota ?? this.computeResourceQuota,
    );
  }
}

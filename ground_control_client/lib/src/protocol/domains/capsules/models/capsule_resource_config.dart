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
    required this.cpuRequest,
    required this.cpuLimit,
    required this.memoryRequest,
    required this.memoryLimit,
    required this.ephemeralStorageRequest,
    required this.ephemeralStorageLimit,
    required this.minInstances,
    required this.maxInstances,
  });

  factory CapsuleResource({
    int? id,
    required int cloudCapsuleId,
    _i2.Capsule? capsule,
    required String cpuRequest,
    required String cpuLimit,
    required String memoryRequest,
    required String memoryLimit,
    required String ephemeralStorageRequest,
    required String ephemeralStorageLimit,
    required int minInstances,
    required int maxInstances,
  }) = _CapsuleResourceImpl;

  factory CapsuleResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapsuleResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as int,
      capsule: jsonSerialization['capsule'] == null
          ? null
          : _i2.Capsule.fromJson(
              (jsonSerialization['capsule'] as Map<String, dynamic>)),
      cpuRequest: jsonSerialization['cpuRequest'] as String,
      cpuLimit: jsonSerialization['cpuLimit'] as String,
      memoryRequest: jsonSerialization['memoryRequest'] as String,
      memoryLimit: jsonSerialization['memoryLimit'] as String,
      ephemeralStorageRequest:
          jsonSerialization['ephemeralStorageRequest'] as String,
      ephemeralStorageLimit:
          jsonSerialization['ephemeralStorageLimit'] as String,
      minInstances: jsonSerialization['minInstances'] as int,
      maxInstances: jsonSerialization['maxInstances'] as int,
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

  /// The CPU request for the capsule,
  /// as millicores for < 1 and as a number for >= 1
  /// Example: "100m" or "1"
  String cpuRequest;

  /// The CPU limit for the capsule.
  /// as millicores for < 1 and as a number for >= 1
  /// Example: "100m" or "1"
  String cpuLimit;

  /// The memory request for the capsule.
  /// Example: "100Mi" or "1Gi"
  String memoryRequest;

  /// The memory limit for the capsule.
  /// Example: "100Mi" or "1Gi"
  String memoryLimit;

  /// The ephemeral storage request for the capsule.
  /// Example: "100Mi" or "1Gi"
  String ephemeralStorageRequest;

  /// The ephemeral storage limit for the capsule.
  /// Example: "100Mi" or "1Gi"
  String ephemeralStorageLimit;

  /// The minimum number of instances for the capsule.
  int minInstances;

  /// The maximum number of instances for the capsule.
  int maxInstances;

  /// Returns a shallow copy of this [CapsuleResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleResource copyWith({
    int? id,
    int? cloudCapsuleId,
    _i2.Capsule? capsule,
    String? cpuRequest,
    String? cpuLimit,
    String? memoryRequest,
    String? memoryLimit,
    String? ephemeralStorageRequest,
    String? ephemeralStorageLimit,
    int? minInstances,
    int? maxInstances,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      if (capsule != null) 'capsule': capsule?.toJson(),
      'cpuRequest': cpuRequest,
      'cpuLimit': cpuLimit,
      'memoryRequest': memoryRequest,
      'memoryLimit': memoryLimit,
      'ephemeralStorageRequest': ephemeralStorageRequest,
      'ephemeralStorageLimit': ephemeralStorageLimit,
      'minInstances': minInstances,
      'maxInstances': maxInstances,
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
    required String cpuRequest,
    required String cpuLimit,
    required String memoryRequest,
    required String memoryLimit,
    required String ephemeralStorageRequest,
    required String ephemeralStorageLimit,
    required int minInstances,
    required int maxInstances,
  }) : super._(
          id: id,
          cloudCapsuleId: cloudCapsuleId,
          capsule: capsule,
          cpuRequest: cpuRequest,
          cpuLimit: cpuLimit,
          memoryRequest: memoryRequest,
          memoryLimit: memoryLimit,
          ephemeralStorageRequest: ephemeralStorageRequest,
          ephemeralStorageLimit: ephemeralStorageLimit,
          minInstances: minInstances,
          maxInstances: maxInstances,
        );

  /// Returns a shallow copy of this [CapsuleResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleResource copyWith({
    Object? id = _Undefined,
    int? cloudCapsuleId,
    Object? capsule = _Undefined,
    String? cpuRequest,
    String? cpuLimit,
    String? memoryRequest,
    String? memoryLimit,
    String? ephemeralStorageRequest,
    String? ephemeralStorageLimit,
    int? minInstances,
    int? maxInstances,
  }) {
    return CapsuleResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      capsule: capsule is _i2.Capsule? ? capsule : this.capsule?.copyWith(),
      cpuRequest: cpuRequest ?? this.cpuRequest,
      cpuLimit: cpuLimit ?? this.cpuLimit,
      memoryRequest: memoryRequest ?? this.memoryRequest,
      memoryLimit: memoryLimit ?? this.memoryLimit,
      ephemeralStorageRequest:
          ephemeralStorageRequest ?? this.ephemeralStorageRequest,
      ephemeralStorageLimit:
          ephemeralStorageLimit ?? this.ephemeralStorageLimit,
      minInstances: minInstances ?? this.minInstances,
      maxInstances: maxInstances ?? this.maxInstances,
    );
  }
}

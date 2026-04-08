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
import '../../../domains/capsules/models/capsule.dart' as _i2;
import '../../../domains/capsules/models/compute_size_option.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

abstract class CapsuleResource implements _i1.SerializableModel {
  CapsuleResource._({
    this.id,
    required this.cloudCapsuleId,
    this.capsule,
    String? computeRequestCpu,
    String? computeRequestMemory,
    String? computeRequestEphemeralStorage,
    String? computeLimitCpu,
    String? computeLimitMemory,
    String? computeLimitEphemeralStorage,
    bool? computeScalingEnabled,
    int? computeScalingMinReplicas,
    int? computeScalingMaxReplicas,
    required this.computeSize,
  }) : computeRequestCpu = computeRequestCpu ?? '250m',
       computeRequestMemory = computeRequestMemory ?? '256Mi',
       computeRequestEphemeralStorage = computeRequestEphemeralStorage ?? '1Gi',
       computeLimitCpu = computeLimitCpu ?? '1',
       computeLimitMemory = computeLimitMemory ?? '256Mi',
       computeLimitEphemeralStorage = computeLimitEphemeralStorage ?? '1Gi',
       computeScalingEnabled = computeScalingEnabled ?? false,
       computeScalingMinReplicas = computeScalingMinReplicas ?? 1,
       computeScalingMaxReplicas = computeScalingMaxReplicas ?? 1;

  factory CapsuleResource({
    int? id,
    required int cloudCapsuleId,
    _i2.Capsule? capsule,
    String? computeRequestCpu,
    String? computeRequestMemory,
    String? computeRequestEphemeralStorage,
    String? computeLimitCpu,
    String? computeLimitMemory,
    String? computeLimitEphemeralStorage,
    bool? computeScalingEnabled,
    int? computeScalingMinReplicas,
    int? computeScalingMaxReplicas,
    required _i3.ComputeSizeOption computeSize,
  }) = _CapsuleResourceImpl;

  factory CapsuleResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapsuleResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as int,
      capsule: jsonSerialization['capsule'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Capsule>(
              jsonSerialization['capsule'],
            ),
      computeRequestCpu: jsonSerialization['computeRequestCpu'] as String?,
      computeRequestMemory:
          jsonSerialization['computeRequestMemory'] as String?,
      computeRequestEphemeralStorage:
          jsonSerialization['computeRequestEphemeralStorage'] as String?,
      computeLimitCpu: jsonSerialization['computeLimitCpu'] as String?,
      computeLimitMemory: jsonSerialization['computeLimitMemory'] as String?,
      computeLimitEphemeralStorage:
          jsonSerialization['computeLimitEphemeralStorage'] as String?,
      computeScalingEnabled: jsonSerialization['computeScalingEnabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['computeScalingEnabled'],
            ),
      computeScalingMinReplicas:
          jsonSerialization['computeScalingMinReplicas'] as int?,
      computeScalingMaxReplicas:
          jsonSerialization['computeScalingMaxReplicas'] as int?,
      computeSize: _i3.ComputeSizeOption.fromJson(
        (jsonSerialization['computeSize'] as String),
      ),
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

  /// The compute request cpu.
  String computeRequestCpu;

  /// The compute request memory.
  String computeRequestMemory;

  /// DEPRECATED (see issue https://linear.app/serverpod/issue/CLD-483/remove-deprecated-fields-from-capsuleresource)
  String computeRequestEphemeralStorage;

  /// The compute limit cpu.
  String computeLimitCpu;

  /// The compute limit memory.
  String computeLimitMemory;

  /// DEPRECATED (see issue https://linear.app/serverpod/issue/CLD-483/remove-deprecated-fields-from-capsuleresource)
  String computeLimitEphemeralStorage;

  /// DEPRECATED (see issue https://linear.app/serverpod/issue/CLD-483/remove-deprecated-fields-from-capsuleresource)
  bool computeScalingEnabled;

  /// The minimum number of compute instances to scale to.
  int computeScalingMinReplicas;

  /// The maximum number of compute instances to scale to.
  int computeScalingMaxReplicas;

  /// The compute size of the capsule.
  _i3.ComputeSizeOption computeSize;

  /// Returns a shallow copy of this [CapsuleResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleResource copyWith({
    int? id,
    int? cloudCapsuleId,
    _i2.Capsule? capsule,
    String? computeRequestCpu,
    String? computeRequestMemory,
    String? computeRequestEphemeralStorage,
    String? computeLimitCpu,
    String? computeLimitMemory,
    String? computeLimitEphemeralStorage,
    bool? computeScalingEnabled,
    int? computeScalingMinReplicas,
    int? computeScalingMaxReplicas,
    _i3.ComputeSizeOption? computeSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleResource',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      if (capsule != null) 'capsule': capsule?.toJson(),
      'computeRequestCpu': computeRequestCpu,
      'computeRequestMemory': computeRequestMemory,
      'computeRequestEphemeralStorage': computeRequestEphemeralStorage,
      'computeLimitCpu': computeLimitCpu,
      'computeLimitMemory': computeLimitMemory,
      'computeLimitEphemeralStorage': computeLimitEphemeralStorage,
      'computeScalingEnabled': computeScalingEnabled,
      'computeScalingMinReplicas': computeScalingMinReplicas,
      'computeScalingMaxReplicas': computeScalingMaxReplicas,
      'computeSize': computeSize.toJson(),
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
    String? computeRequestCpu,
    String? computeRequestMemory,
    String? computeRequestEphemeralStorage,
    String? computeLimitCpu,
    String? computeLimitMemory,
    String? computeLimitEphemeralStorage,
    bool? computeScalingEnabled,
    int? computeScalingMinReplicas,
    int? computeScalingMaxReplicas,
    required _i3.ComputeSizeOption computeSize,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         capsule: capsule,
         computeRequestCpu: computeRequestCpu,
         computeRequestMemory: computeRequestMemory,
         computeRequestEphemeralStorage: computeRequestEphemeralStorage,
         computeLimitCpu: computeLimitCpu,
         computeLimitMemory: computeLimitMemory,
         computeLimitEphemeralStorage: computeLimitEphemeralStorage,
         computeScalingEnabled: computeScalingEnabled,
         computeScalingMinReplicas: computeScalingMinReplicas,
         computeScalingMaxReplicas: computeScalingMaxReplicas,
         computeSize: computeSize,
       );

  /// Returns a shallow copy of this [CapsuleResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleResource copyWith({
    Object? id = _Undefined,
    int? cloudCapsuleId,
    Object? capsule = _Undefined,
    String? computeRequestCpu,
    String? computeRequestMemory,
    String? computeRequestEphemeralStorage,
    String? computeLimitCpu,
    String? computeLimitMemory,
    String? computeLimitEphemeralStorage,
    bool? computeScalingEnabled,
    int? computeScalingMinReplicas,
    int? computeScalingMaxReplicas,
    _i3.ComputeSizeOption? computeSize,
  }) {
    return CapsuleResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      capsule: capsule is _i2.Capsule? ? capsule : this.capsule?.copyWith(),
      computeRequestCpu: computeRequestCpu ?? this.computeRequestCpu,
      computeRequestMemory: computeRequestMemory ?? this.computeRequestMemory,
      computeRequestEphemeralStorage:
          computeRequestEphemeralStorage ?? this.computeRequestEphemeralStorage,
      computeLimitCpu: computeLimitCpu ?? this.computeLimitCpu,
      computeLimitMemory: computeLimitMemory ?? this.computeLimitMemory,
      computeLimitEphemeralStorage:
          computeLimitEphemeralStorage ?? this.computeLimitEphemeralStorage,
      computeScalingEnabled:
          computeScalingEnabled ?? this.computeScalingEnabled,
      computeScalingMinReplicas:
          computeScalingMinReplicas ?? this.computeScalingMinReplicas,
      computeScalingMaxReplicas:
          computeScalingMaxReplicas ?? this.computeScalingMaxReplicas,
      computeSize: computeSize ?? this.computeSize,
    );
  }
}

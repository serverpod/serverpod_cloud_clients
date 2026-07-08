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
import '../../../domains/status/models/capsule_state.dart' as _i2;
import '../../../domains/status/models/capsule_deployment_status.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// The live runtime status of a capsule.
abstract class CapsuleStatus implements _i1.SerializableModel {
  CapsuleStatus._({
    required this.cloudCapsuleId,
    required this.status,
    this.deployment,
  });

  factory CapsuleStatus({
    required String cloudCapsuleId,
    required _i2.CapsuleState status,
    _i3.CapsuleDeploymentStatus? deployment,
  }) = _CapsuleStatusImpl;

  factory CapsuleStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapsuleStatus(
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      status: _i2.CapsuleState.fromJson(
        (jsonSerialization['status'] as String),
      ),
      deployment: jsonSerialization['deployment'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.CapsuleDeploymentStatus>(
              jsonSerialization['deployment'],
            ),
    );
  }

  /// The ID of the capsule.
  String cloudCapsuleId;

  /// The overall runtime state of the capsule.
  /// Mirrors the state of the capsule's deployment.
  _i2.CapsuleState status;

  /// The runtime status of the capsule's deployment.
  /// Absent when no workload is identifiable,
  /// in which case [status] is [CapsuleState.notProvisioned].
  _i3.CapsuleDeploymentStatus? deployment;

  /// Returns a shallow copy of this [CapsuleStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleStatus copyWith({
    String? cloudCapsuleId,
    _i2.CapsuleState? status,
    _i3.CapsuleDeploymentStatus? deployment,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleStatus',
      'cloudCapsuleId': cloudCapsuleId,
      'status': status.toJson(),
      if (deployment != null) 'deployment': deployment?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapsuleStatusImpl extends CapsuleStatus {
  _CapsuleStatusImpl({
    required String cloudCapsuleId,
    required _i2.CapsuleState status,
    _i3.CapsuleDeploymentStatus? deployment,
  }) : super._(
         cloudCapsuleId: cloudCapsuleId,
         status: status,
         deployment: deployment,
       );

  /// Returns a shallow copy of this [CapsuleStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleStatus copyWith({
    String? cloudCapsuleId,
    _i2.CapsuleState? status,
    Object? deployment = _Undefined,
  }) {
    return CapsuleStatus(
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      status: status ?? this.status,
      deployment: deployment is _i3.CapsuleDeploymentStatus?
          ? deployment
          : this.deployment?.copyWith(),
    );
  }
}

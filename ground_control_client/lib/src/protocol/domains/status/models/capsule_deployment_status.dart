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
import '../../../domains/status/models/capsule_revision.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// The runtime status of a capsule's deployment.
abstract class CapsuleDeploymentStatus implements _i1.SerializableModel {
  CapsuleDeploymentStatus._({
    required this.name,
    required this.state,
    this.desiredReplicas,
    this.readyReplicas,
    this.uploadId,
    this.buildId,
    this.incoming,
  });

  factory CapsuleDeploymentStatus({
    required String name,
    required _i2.CapsuleState state,
    int? desiredReplicas,
    int? readyReplicas,
    _i1.UuidValue? uploadId,
    _i1.UuidValue? buildId,
    _i3.CapsuleRevision? incoming,
  }) = _CapsuleDeploymentStatusImpl;

  factory CapsuleDeploymentStatus.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CapsuleDeploymentStatus(
      name: jsonSerialization['name'] as String,
      state: _i2.CapsuleState.fromJson((jsonSerialization['state'] as String)),
      desiredReplicas: jsonSerialization['desiredReplicas'] as int?,
      readyReplicas: jsonSerialization['readyReplicas'] as int?,
      uploadId: jsonSerialization['uploadId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['uploadId']),
      buildId: jsonSerialization['buildId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['buildId']),
      incoming: jsonSerialization['incoming'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.CapsuleRevision>(
              jsonSerialization['incoming'],
            ),
    );
  }

  /// The name of the deployment.
  String name;

  /// The runtime state of the deployment.
  _i2.CapsuleState state;

  /// The number of replicas the deployment wants.
  /// Present whenever the workload exists.
  int? desiredReplicas;

  /// The number of replicas ready to serve.
  /// Present whenever the workload exists.
  int? readyReplicas;

  /// The upload the deployment is currently serving.
  /// Absent when unknown.
  _i1.UuidValue? uploadId;

  /// The build the deployment is currently serving.
  /// Absent when unknown.
  _i1.UuidValue? buildId;

  /// The revision currently being rolled out toward this deployment.
  /// Present only while a rollout is in flight.
  _i3.CapsuleRevision? incoming;

  /// Returns a shallow copy of this [CapsuleDeploymentStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleDeploymentStatus copyWith({
    String? name,
    _i2.CapsuleState? state,
    int? desiredReplicas,
    int? readyReplicas,
    _i1.UuidValue? uploadId,
    _i1.UuidValue? buildId,
    _i3.CapsuleRevision? incoming,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleDeploymentStatus',
      'name': name,
      'state': state.toJson(),
      if (desiredReplicas != null) 'desiredReplicas': desiredReplicas,
      if (readyReplicas != null) 'readyReplicas': readyReplicas,
      if (uploadId != null) 'uploadId': uploadId?.toJson(),
      if (buildId != null) 'buildId': buildId?.toJson(),
      if (incoming != null) 'incoming': incoming?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapsuleDeploymentStatusImpl extends CapsuleDeploymentStatus {
  _CapsuleDeploymentStatusImpl({
    required String name,
    required _i2.CapsuleState state,
    int? desiredReplicas,
    int? readyReplicas,
    _i1.UuidValue? uploadId,
    _i1.UuidValue? buildId,
    _i3.CapsuleRevision? incoming,
  }) : super._(
         name: name,
         state: state,
         desiredReplicas: desiredReplicas,
         readyReplicas: readyReplicas,
         uploadId: uploadId,
         buildId: buildId,
         incoming: incoming,
       );

  /// Returns a shallow copy of this [CapsuleDeploymentStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleDeploymentStatus copyWith({
    String? name,
    _i2.CapsuleState? state,
    Object? desiredReplicas = _Undefined,
    Object? readyReplicas = _Undefined,
    Object? uploadId = _Undefined,
    Object? buildId = _Undefined,
    Object? incoming = _Undefined,
  }) {
    return CapsuleDeploymentStatus(
      name: name ?? this.name,
      state: state ?? this.state,
      desiredReplicas: desiredReplicas is int?
          ? desiredReplicas
          : this.desiredReplicas,
      readyReplicas: readyReplicas is int? ? readyReplicas : this.readyReplicas,
      uploadId: uploadId is _i1.UuidValue? ? uploadId : this.uploadId,
      buildId: buildId is _i1.UuidValue? ? buildId : this.buildId,
      incoming: incoming is _i3.CapsuleRevision?
          ? incoming
          : this.incoming?.copyWith(),
    );
  }
}

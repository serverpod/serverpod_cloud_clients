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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/status/models/capsule_status.dart' as _iyq6x507;
import '../../../features/status/models/deploy_attempt_summary.dart'
    as _ich2tv6j;

/// The live runtime status of a capsule, enriched with summaries of the
/// deploy attempts behind the serving and incoming revisions.
abstract class CapsuleRuntimeStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CapsuleRuntimeStatus._({
    required this.status,
    this.serving,
    this.incoming,
    this.latestAttempt,
  });

  factory CapsuleRuntimeStatus({
    required _iyq6x507.CapsuleStatus status,
    _ich2tv6j.DeployAttemptSummary? serving,
    _ich2tv6j.DeployAttemptSummary? incoming,
    _ich2tv6j.DeployAttemptSummary? latestAttempt,
  }) = _CapsuleRuntimeStatusImpl;

  factory CapsuleRuntimeStatus.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CapsuleRuntimeStatus(
      status: _iod2a87h.Protocol().deserialize<_iyq6x507.CapsuleStatus>(
        jsonSerialization['status'],
      ),
      serving: jsonSerialization['serving'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ich2tv6j.DeployAttemptSummary>(
              jsonSerialization['serving'],
            ),
      incoming: jsonSerialization['incoming'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ich2tv6j.DeployAttemptSummary>(
              jsonSerialization['incoming'],
            ),
      latestAttempt: jsonSerialization['latestAttempt'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ich2tv6j.DeployAttemptSummary>(
              jsonSerialization['latestAttempt'],
            ),
    );
  }

  /// The live runtime status of the capsule.
  _iyq6x507.CapsuleStatus status;

  /// The deploy attempt behind the revision the deployment is serving.
  /// Absent when the serving revision cannot be matched to a known
  /// deploy attempt.
  _ich2tv6j.DeployAttemptSummary? serving;

  /// The deploy attempt behind the revision being rolled out toward the
  /// deployment. Present only while a rollout is in flight and the
  /// revision can be matched to a known deploy attempt.
  _ich2tv6j.DeployAttemptSummary? incoming;

  /// The capsule's most recent deploy attempt, when it is not the attempt
  /// behind the serving or incoming revision — an attempt that is still
  /// building, or one that ended without reaching the deployment.
  _ich2tv6j.DeployAttemptSummary? latestAttempt;

  /// Returns a shallow copy of this [CapsuleRuntimeStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CapsuleRuntimeStatus copyWith({
    _iyq6x507.CapsuleStatus? status,
    _ich2tv6j.DeployAttemptSummary? serving,
    _ich2tv6j.DeployAttemptSummary? incoming,
    _ich2tv6j.DeployAttemptSummary? latestAttempt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleRuntimeStatus',
      'status': status.toJson(),
      if (serving != null) 'serving': serving?.toJson(),
      if (incoming != null) 'incoming': incoming?.toJson(),
      if (latestAttempt != null) 'latestAttempt': latestAttempt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CapsuleRuntimeStatus',
      'status': status.toJsonForProtocol(),
      if (serving != null) 'serving': serving?.toJsonForProtocol(),
      if (incoming != null) 'incoming': incoming?.toJsonForProtocol(),
      if (latestAttempt != null)
        'latestAttempt': latestAttempt?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapsuleRuntimeStatusImpl extends CapsuleRuntimeStatus {
  _CapsuleRuntimeStatusImpl({
    required _iyq6x507.CapsuleStatus status,
    _ich2tv6j.DeployAttemptSummary? serving,
    _ich2tv6j.DeployAttemptSummary? incoming,
    _ich2tv6j.DeployAttemptSummary? latestAttempt,
  }) : super._(
         status: status,
         serving: serving,
         incoming: incoming,
         latestAttempt: latestAttempt,
       );

  /// Returns a shallow copy of this [CapsuleRuntimeStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CapsuleRuntimeStatus copyWith({
    _iyq6x507.CapsuleStatus? status,
    Object? serving = _Undefined,
    Object? incoming = _Undefined,
    Object? latestAttempt = _Undefined,
  }) {
    return CapsuleRuntimeStatus(
      status: status ?? this.status.copyWith(),
      serving: serving is _ich2tv6j.DeployAttemptSummary?
          ? serving
          : this.serving?.copyWith(),
      incoming: incoming is _ich2tv6j.DeployAttemptSummary?
          ? incoming
          : this.incoming?.copyWith(),
      latestAttempt: latestAttempt is _ich2tv6j.DeployAttemptSummary?
          ? latestAttempt
          : this.latestAttempt?.copyWith(),
    );
  }
}

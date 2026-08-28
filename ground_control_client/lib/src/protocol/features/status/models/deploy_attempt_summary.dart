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
import '../../../domains/status/models/deploy_progress_status.dart'
    as _izk8c25p;
import '../../../domains/users/models/user.dart' as _ijl94k1v;

/// Display summary of a deploy attempt, for presenting the deployment
/// behind a capsule revision without the full attempt aggregate.
abstract class DeployAttemptSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DeployAttemptSummary._({
    required this.attemptId,
    this.status,
    this.commitHash,
    this.commitMessage,
    this.branch,
    this.deployedBy,
    required this.startedAt,
    this.endedAt,
  });

  factory DeployAttemptSummary({
    required _isc.UuidValue attemptId,
    _izk8c25p.DeployProgressStatus? status,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _ijl94k1v.User? deployedBy,
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _DeployAttemptSummaryImpl;

  factory DeployAttemptSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DeployAttemptSummary(
      attemptId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['attemptId'],
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _izk8c25p.DeployProgressStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      commitHash: jsonSerialization['commitHash'] as String?,
      commitMessage: jsonSerialization['commitMessage'] as String?,
      branch: jsonSerialization['branch'] as String?,
      deployedBy: jsonSerialization['deployedBy'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ijl94k1v.User>(
              jsonSerialization['deployedBy'],
            ),
      startedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
    );
  }

  /// The ID of the deploy attempt.
  _isc.UuidValue attemptId;

  /// The overall progress status of the deploy attempt.
  _izk8c25p.DeployProgressStatus? status;

  /// Short git commit hash, if provided by the client at deploy time.
  String? commitHash;

  /// First line of the git commit message, if provided by the client at deploy time.
  String? commitMessage;

  /// Git branch the deploy was triggered from, if provided by the client at deploy time.
  String? branch;

  /// The user who triggered the deploy, if known.
  _ijl94k1v.User? deployedBy;

  /// The timestamp of the start of the deploy attempt.
  DateTime startedAt;

  /// The timestamp of the end of the deploy attempt.
  DateTime? endedAt;

  /// Returns a shallow copy of this [DeployAttemptSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DeployAttemptSummary copyWith({
    _isc.UuidValue? attemptId,
    _izk8c25p.DeployProgressStatus? status,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _ijl94k1v.User? deployedBy,
    DateTime? startedAt,
    DateTime? endedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeployAttemptSummary',
      'attemptId': attemptId.toJson(),
      if (status != null) 'status': status?.toJson(),
      if (commitHash != null) 'commitHash': commitHash,
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (deployedBy != null) 'deployedBy': deployedBy?.toJson(),
      'startedAt': startedAt.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeployAttemptSummary',
      'attemptId': attemptId.toJson(),
      if (status != null) 'status': status?.toJson(),
      if (commitHash != null) 'commitHash': commitHash,
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (deployedBy != null) 'deployedBy': deployedBy?.toJsonForProtocol(),
      'startedAt': startedAt.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeployAttemptSummaryImpl extends DeployAttemptSummary {
  _DeployAttemptSummaryImpl({
    required _isc.UuidValue attemptId,
    _izk8c25p.DeployProgressStatus? status,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _ijl94k1v.User? deployedBy,
    required DateTime startedAt,
    DateTime? endedAt,
  }) : super._(
         attemptId: attemptId,
         status: status,
         commitHash: commitHash,
         commitMessage: commitMessage,
         branch: branch,
         deployedBy: deployedBy,
         startedAt: startedAt,
         endedAt: endedAt,
       );

  /// Returns a shallow copy of this [DeployAttemptSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DeployAttemptSummary copyWith({
    _isc.UuidValue? attemptId,
    Object? status = _Undefined,
    Object? commitHash = _Undefined,
    Object? commitMessage = _Undefined,
    Object? branch = _Undefined,
    Object? deployedBy = _Undefined,
    DateTime? startedAt,
    Object? endedAt = _Undefined,
  }) {
    return DeployAttemptSummary(
      attemptId: attemptId ?? this.attemptId,
      status: status is _izk8c25p.DeployProgressStatus? ? status : this.status,
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      commitMessage: commitMessage is String?
          ? commitMessage
          : this.commitMessage,
      branch: branch is String? ? branch : this.branch,
      deployedBy: deployedBy is _ijl94k1v.User?
          ? deployedBy
          : this.deployedBy?.copyWith(),
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
    );
  }
}

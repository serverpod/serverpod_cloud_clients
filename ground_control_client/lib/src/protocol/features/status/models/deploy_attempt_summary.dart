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
import '../../../domains/status/models/deploy_progress_status.dart' as _i2;
import '../../../domains/users/models/user.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Display summary of a deploy attempt, for presenting the deployment
/// behind a capsule revision without the full attempt aggregate.
abstract class DeployAttemptSummary implements _i1.SerializableModel {
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
    required _i1.UuidValue attemptId,
    _i2.DeployProgressStatus? status,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _i3.User? deployedBy,
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _DeployAttemptSummaryImpl;

  factory DeployAttemptSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DeployAttemptSummary(
      attemptId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['attemptId'],
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.DeployProgressStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      commitHash: jsonSerialization['commitHash'] as String?,
      commitMessage: jsonSerialization['commitMessage'] as String?,
      branch: jsonSerialization['branch'] as String?,
      deployedBy: jsonSerialization['deployedBy'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.User>(
              jsonSerialization['deployedBy'],
            ),
      startedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
    );
  }

  /// The ID of the deploy attempt.
  _i1.UuidValue attemptId;

  /// The overall progress status of the deploy attempt.
  _i2.DeployProgressStatus? status;

  /// Short git commit hash, if provided by the client at deploy time.
  String? commitHash;

  /// First line of the git commit message, if provided by the client at deploy time.
  String? commitMessage;

  /// Git branch the deploy was triggered from, if provided by the client at deploy time.
  String? branch;

  /// The user who triggered the deploy, if known.
  _i3.User? deployedBy;

  /// The timestamp of the start of the deploy attempt.
  DateTime startedAt;

  /// The timestamp of the end of the deploy attempt.
  DateTime? endedAt;

  /// Returns a shallow copy of this [DeployAttemptSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeployAttemptSummary copyWith({
    _i1.UuidValue? attemptId,
    _i2.DeployProgressStatus? status,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _i3.User? deployedBy,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeployAttemptSummaryImpl extends DeployAttemptSummary {
  _DeployAttemptSummaryImpl({
    required _i1.UuidValue attemptId,
    _i2.DeployProgressStatus? status,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _i3.User? deployedBy,
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
  @_i1.useResult
  @override
  DeployAttemptSummary copyWith({
    _i1.UuidValue? attemptId,
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
      status: status is _i2.DeployProgressStatus? ? status : this.status,
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      commitMessage: commitMessage is String?
          ? commitMessage
          : this.commitMessage,
      branch: branch is String? ? branch : this.branch,
      deployedBy: deployedBy is _i3.User?
          ? deployedBy
          : this.deployedBy?.copyWith(),
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
    );
  }
}

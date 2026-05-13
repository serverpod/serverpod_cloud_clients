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
import '../../../domains/status/models/deploy_attempt_stage.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Represents a deployment attempt and its shared metadata.
///
/// This is the parent of [DeployAttemptStage]: each attempt has 0..n stages
/// (upload/build/deploy/service). Metadata that is shared across all stages —
/// commit info, deployer, runtime versions — lives here so it is stored once
/// per attempt instead of being duplicated on each stage row.
abstract class DeployAttempt implements _i1.SerializableModel {
  DeployAttempt._({
    this.id,
    required this.cloudCapsuleId,
    required this.attemptId,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.statusInfo,
    this.commitHash,
    this.commitMessage,
    this.branch,
    this.deployedBy,
    this.serverpodVersion,
    this.dartVersion,
    this.stages,
  });

  factory DeployAttempt({
    int? id,
    required String cloudCapsuleId,
    required String attemptId,
    required _i2.DeployProgressStatus status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
    String? commitHash,
    String? commitMessage,
    String? branch,
    String? deployedBy,
    String? serverpodVersion,
    String? dartVersion,
    List<_i3.DeployAttemptStage>? stages,
  }) = _DeployAttemptImpl;

  factory DeployAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttempt(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      attemptId: jsonSerialization['attemptId'] as String,
      status: _i2.DeployProgressStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      statusInfo: jsonSerialization['statusInfo'] as String?,
      commitHash: jsonSerialization['commitHash'] as String?,
      commitMessage: jsonSerialization['commitMessage'] as String?,
      branch: jsonSerialization['branch'] as String?,
      deployedBy: jsonSerialization['deployedBy'] as String?,
      serverpodVersion: jsonSerialization['serverpodVersion'] as String?,
      dartVersion: jsonSerialization['dartVersion'] as String?,
      stages: jsonSerialization['stages'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.DeployAttemptStage>>(
              jsonSerialization['stages'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The ID of the capsule of this deployment.
  String cloudCapsuleId;

  /// The ID of this deploy attempt.
  /// Unique together with [cloudCapsuleId].
  String attemptId;

  /// The current overall status of this attempt.
  /// Derived from the stages but cached here for efficient list queries.
  _i2.DeployProgressStatus status;

  /// When the deploy attempt was first registered (upload start).
  DateTime? startedAt;

  /// When the deploy attempt reached a terminal status.
  DateTime? endedAt;

  /// Optional user-readable information about the current overall status.
  String? statusInfo;

  /// Short git commit hash (e.g. "8f3c1ab"), if provided by the client at deploy time.
  String? commitHash;

  /// First line of the git commit message, if provided by the client at deploy time.
  String? commitMessage;

  /// Git branch the deploy was triggered from, if provided by the client at deploy time.
  String? branch;

  /// Display name / handle of the user who triggered this deploy, if known.
  String? deployedBy;

  /// Serverpod version constraint of the deployed project (pub semver constraint).
  String? serverpodVersion;

  /// Dart SDK version used to build the project, if known.
  String? dartVersion;

  /// The stages of this deploy attempt — fetched via the relation.
  List<_i3.DeployAttemptStage>? stages;

  /// Returns a shallow copy of this [DeployAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeployAttempt copyWith({
    int? id,
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
    String? commitHash,
    String? commitMessage,
    String? branch,
    String? deployedBy,
    String? serverpodVersion,
    String? dartVersion,
    List<_i3.DeployAttemptStage>? stages,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeployAttempt',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'attemptId': attemptId,
      'status': status.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      if (statusInfo != null) 'statusInfo': statusInfo,
      if (commitHash != null) 'commitHash': commitHash,
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (deployedBy != null) 'deployedBy': deployedBy,
      if (serverpodVersion != null) 'serverpodVersion': serverpodVersion,
      if (dartVersion != null) 'dartVersion': dartVersion,
      if (stages != null)
        'stages': stages?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeployAttemptImpl extends DeployAttempt {
  _DeployAttemptImpl({
    int? id,
    required String cloudCapsuleId,
    required String attemptId,
    required _i2.DeployProgressStatus status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
    String? commitHash,
    String? commitMessage,
    String? branch,
    String? deployedBy,
    String? serverpodVersion,
    String? dartVersion,
    List<_i3.DeployAttemptStage>? stages,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         attemptId: attemptId,
         status: status,
         startedAt: startedAt,
         endedAt: endedAt,
         statusInfo: statusInfo,
         commitHash: commitHash,
         commitMessage: commitMessage,
         branch: branch,
         deployedBy: deployedBy,
         serverpodVersion: serverpodVersion,
         dartVersion: dartVersion,
         stages: stages,
       );

  /// Returns a shallow copy of this [DeployAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeployAttempt copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
    Object? statusInfo = _Undefined,
    Object? commitHash = _Undefined,
    Object? commitMessage = _Undefined,
    Object? branch = _Undefined,
    Object? deployedBy = _Undefined,
    Object? serverpodVersion = _Undefined,
    Object? dartVersion = _Undefined,
    Object? stages = _Undefined,
  }) {
    return DeployAttempt(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      attemptId: attemptId ?? this.attemptId,
      status: status ?? this.status,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      commitMessage: commitMessage is String?
          ? commitMessage
          : this.commitMessage,
      branch: branch is String? ? branch : this.branch,
      deployedBy: deployedBy is String? ? deployedBy : this.deployedBy,
      serverpodVersion: serverpodVersion is String?
          ? serverpodVersion
          : this.serverpodVersion,
      dartVersion: dartVersion is String? ? dartVersion : this.dartVersion,
      stages: stages is List<_i3.DeployAttemptStage>?
          ? stages
          : this.stages?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

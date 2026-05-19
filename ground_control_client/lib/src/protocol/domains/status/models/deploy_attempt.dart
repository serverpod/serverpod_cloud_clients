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
import '../../../domains/status/models/deploy_attempt_stage.dart' as _i4;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i5;

/// Represents the status information of a deployment attempt.
abstract class DeployAttempt implements _i1.SerializableModel {
  DeployAttempt._({
    _i1.UuidValue? id,
    required this.cloudCapsuleId,
    this.attemptId,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.imageName,
    required this.serverpodVersion,
    required this.dartVersion,
    required this.commitHash,
    required this.commitMessage,
    required this.branch,
    required this.deployedById,
    this.deployedBy,
    this.stages,
    this.statusInfo,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory DeployAttempt({
    _i1.UuidValue? id,
    required String cloudCapsuleId,
    String? attemptId,
    required _i2.DeployProgressStatus? status,
    required DateTime? startedAt,
    required DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageName,
    required String? serverpodVersion,
    required String? dartVersion,
    required String? commitHash,
    required String? commitMessage,
    required String? branch,
    required int? deployedById,
    _i3.User? deployedBy,
    List<_i4.DeployAttemptStage>? stages,
    String? statusInfo,
  }) = _DeployAttemptImpl;

  factory DeployAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttempt(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      attemptId: jsonSerialization['attemptId'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.DeployProgressStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      imageName: jsonSerialization['imageName'] as String?,
      serverpodVersion: jsonSerialization['serverpodVersion'] as String?,
      dartVersion: jsonSerialization['dartVersion'] as String?,
      commitHash: jsonSerialization['commitHash'] as String?,
      commitMessage: jsonSerialization['commitMessage'] as String?,
      branch: jsonSerialization['branch'] as String?,
      deployedById: jsonSerialization['deployedById'] as int?,
      deployedBy: jsonSerialization['deployedBy'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.User>(
              jsonSerialization['deployedBy'],
            ),
      stages: jsonSerialization['stages'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i4.DeployAttemptStage>>(
              jsonSerialization['stages'],
            ),
      statusInfo: jsonSerialization['statusInfo'] as String?,
    );
  }

  /// The ID of this deploy attempt.
  _i1.UuidValue id;

  /// The ID of the capsule of this deployment.
  String cloudCapsuleId;

  /// Deprecated use id instead
  String? attemptId;

  /// The current status of this deployment.
  _i2.DeployProgressStatus? status;

  /// The timestamp of the start of the deployment attempt.
  DateTime? startedAt;

  /// The timestamp of the end of the deployment attempt.
  DateTime? endedAt;

  /// The timestamps of the deployment attempt.
  DateTime createdAt;

  /// The timestamp of the last update to the deployment attempt.
  DateTime updatedAt;

  /// The name of the image produced by the deployment attempt.
  String? imageName;

  /// The Serverpod version of the deployment attempt.
  String? serverpodVersion;

  /// The Dart version (image tag) the deployment was built with.
  /// Populated from the dartImageTag parameter at upload time.
  String? dartVersion;

  String? commitHash;

  /// First line of the git commit message, if provided by the client at deploy time.
  String? commitMessage;

  /// Git branch the deploy was triggered from, if provided by the client at deploy time.
  String? branch;

  /// The ID of the user who triggered this deploy.
  int? deployedById;

  /// Display name / handle of the user who triggered this deploy, if known.
  _i3.User? deployedBy;

  /// The stages of the deployment attempt.
  List<_i4.DeployAttemptStage>? stages;

  /// Optionally contains user-readable information about the current status of this attempt.
  String? statusInfo;

  /// Returns a shallow copy of this [DeployAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeployAttempt copyWith({
    _i1.UuidValue? id,
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageName,
    String? serverpodVersion,
    String? dartVersion,
    String? commitHash,
    String? commitMessage,
    String? branch,
    int? deployedById,
    _i3.User? deployedBy,
    List<_i4.DeployAttemptStage>? stages,
    String? statusInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeployAttempt',
      'id': id.toJson(),
      'cloudCapsuleId': cloudCapsuleId,
      if (attemptId != null) 'attemptId': attemptId,
      if (status != null) 'status': status?.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (imageName != null) 'imageName': imageName,
      if (serverpodVersion != null) 'serverpodVersion': serverpodVersion,
      if (dartVersion != null) 'dartVersion': dartVersion,
      if (commitHash != null) 'commitHash': commitHash,
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (deployedById != null) 'deployedById': deployedById,
      if (deployedBy != null) 'deployedBy': deployedBy?.toJson(),
      if (stages != null)
        'stages': stages?.toJson(valueToJson: (v) => v.toJson()),
      if (statusInfo != null) 'statusInfo': statusInfo,
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
    _i1.UuidValue? id,
    required String cloudCapsuleId,
    String? attemptId,
    required _i2.DeployProgressStatus? status,
    required DateTime? startedAt,
    required DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageName,
    required String? serverpodVersion,
    required String? dartVersion,
    required String? commitHash,
    required String? commitMessage,
    required String? branch,
    required int? deployedById,
    _i3.User? deployedBy,
    List<_i4.DeployAttemptStage>? stages,
    String? statusInfo,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         attemptId: attemptId,
         status: status,
         startedAt: startedAt,
         endedAt: endedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         imageName: imageName,
         serverpodVersion: serverpodVersion,
         dartVersion: dartVersion,
         commitHash: commitHash,
         commitMessage: commitMessage,
         branch: branch,
         deployedById: deployedById,
         deployedBy: deployedBy,
         stages: stages,
         statusInfo: statusInfo,
       );

  /// Returns a shallow copy of this [DeployAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeployAttempt copyWith({
    _i1.UuidValue? id,
    String? cloudCapsuleId,
    Object? attemptId = _Undefined,
    Object? status = _Undefined,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? imageName = _Undefined,
    Object? serverpodVersion = _Undefined,
    Object? dartVersion = _Undefined,
    Object? commitHash = _Undefined,
    Object? commitMessage = _Undefined,
    Object? branch = _Undefined,
    Object? deployedById = _Undefined,
    Object? deployedBy = _Undefined,
    Object? stages = _Undefined,
    Object? statusInfo = _Undefined,
  }) {
    return DeployAttempt(
      id: id ?? this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      attemptId: attemptId is String? ? attemptId : this.attemptId,
      status: status is _i2.DeployProgressStatus? ? status : this.status,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageName: imageName is String? ? imageName : this.imageName,
      serverpodVersion: serverpodVersion is String?
          ? serverpodVersion
          : this.serverpodVersion,
      dartVersion: dartVersion is String? ? dartVersion : this.dartVersion,
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      commitMessage: commitMessage is String?
          ? commitMessage
          : this.commitMessage,
      branch: branch is String? ? branch : this.branch,
      deployedById: deployedById is int? ? deployedById : this.deployedById,
      deployedBy: deployedBy is _i3.User?
          ? deployedBy
          : this.deployedBy?.copyWith(),
      stages: stages is List<_i4.DeployAttemptStage>?
          ? stages
          : this.stages?.map((e0) => e0.copyWith()).toList(),
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
    );
  }
}

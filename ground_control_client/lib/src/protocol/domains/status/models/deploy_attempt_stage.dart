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
import '../../../domains/status/models/deploy_attempt.dart' as _i2;
import '../../../domains/status/models/deploy_stage_type.dart' as _i3;
import '../../../domains/status/models/deploy_progress_status.dart' as _i4;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i5;

/// Represents the status information of a stage in a deployment attempt.
abstract class DeployAttemptStage implements _i1.SerializableModel {
  DeployAttemptStage._({
    this.id,
    required this.cloudCapsuleId,
    required this.deployAttemptId,
    this.deploymentAttempt,
    this.externalId,
    required this.stageType,
    this.buildId,
    required this.stageStatus,
    this.startedAt,
    this.endedAt,
    required this.attemptId,
    this.stageInfo,
    this.serverpodVersionConstraint,
    this.imageName,
    this.statusInfo,
  });

  factory DeployAttemptStage({
    int? id,
    required String cloudCapsuleId,
    required _i1.UuidValue deployAttemptId,
    _i2.DeployAttempt? deploymentAttempt,
    String? externalId,
    required _i3.DeployStageType stageType,
    String? buildId,
    required _i4.DeployProgressStatus stageStatus,
    DateTime? startedAt,
    DateTime? endedAt,
    required String attemptId,
    String? stageInfo,
    String? serverpodVersionConstraint,
    String? imageName,
    String? statusInfo,
  }) = _DeployAttemptStageImpl;

  factory DeployAttemptStage.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttemptStage(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      deployAttemptId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['deployAttemptId'],
      ),
      deploymentAttempt: jsonSerialization['deploymentAttempt'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.DeployAttempt>(
              jsonSerialization['deploymentAttempt'],
            ),
      externalId: jsonSerialization['externalId'] as String?,
      stageType: _i3.DeployStageType.fromJson(
        (jsonSerialization['stageType'] as String),
      ),
      buildId: jsonSerialization['buildId'] as String?,
      stageStatus: _i4.DeployProgressStatus.fromJson(
        (jsonSerialization['stageStatus'] as String),
      ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      attemptId: jsonSerialization['attemptId'] as String,
      stageInfo: jsonSerialization['stageInfo'] as String?,
      serverpodVersionConstraint:
          jsonSerialization['serverpodVersionConstraint'] as String?,
      imageName: jsonSerialization['imageName'] as String?,
      statusInfo: jsonSerialization['statusInfo'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The ID of the capsule of this deployment.
  String cloudCapsuleId;

  /// The ID of the deploy attempt this stage belongs to.
  _i1.UuidValue deployAttemptId;

  /// The deployment attempt this stage belongs to.
  _i2.DeployAttempt? deploymentAttempt;

  /// The external ID of the stage, if any.
  String? externalId;

  /// The type of this stage.
  /// Unique within the deployment attempt.
  _i3.DeployStageType stageType;

  /// The build ID of the deploy attempt that this stage belongs to, if known.
  /// Deprecated: use externalId instead.
  String? buildId;

  /// The current / last known status of this stage.
  _i4.DeployProgressStatus stageStatus;

  /// The timestamp of the start of the stage.
  DateTime? startedAt;

  /// The timestamp of the end of the stage.
  DateTime? endedAt;

  /// TODO REMOVE ALL FIELDS BELOW ###
  /// ---------------------------- ###
  /// The ID of the deploy attempt.
  /// Deprecated: use deployAttemptId instead.
  String attemptId;

  /// which is immutable i.e. independent of the status.
  /// This should be a human-readable string.
  String? stageInfo;

  /// The Serverpod version constraint used by tenant's project.
  /// It is pub semantic versioning constraint, passed from CLI on deploy.
  /// Deprecated: use deployAttempt.serverpodVersion instead.
  String? serverpodVersionConstraint;

  /// The name of the image produced by the build stage, if known.
  /// Deprecated: use deployAttempt.imageName instead.
  String? imageName;

  /// Optionally contains user-readable information about the current status of this stage.
  /// Deprecated: still persisted during the transition; will be removed in a
  /// future migration once callers have moved off it.
  String? statusInfo;

  /// Returns a shallow copy of this [DeployAttemptStage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeployAttemptStage copyWith({
    int? id,
    String? cloudCapsuleId,
    _i1.UuidValue? deployAttemptId,
    _i2.DeployAttempt? deploymentAttempt,
    String? externalId,
    _i3.DeployStageType? stageType,
    String? buildId,
    _i4.DeployProgressStatus? stageStatus,
    DateTime? startedAt,
    DateTime? endedAt,
    String? attemptId,
    String? stageInfo,
    String? serverpodVersionConstraint,
    String? imageName,
    String? statusInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeployAttemptStage',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'deployAttemptId': deployAttemptId.toJson(),
      if (deploymentAttempt != null)
        'deploymentAttempt': deploymentAttempt?.toJson(),
      if (externalId != null) 'externalId': externalId,
      'stageType': stageType.toJson(),
      if (buildId != null) 'buildId': buildId,
      'stageStatus': stageStatus.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'attemptId': attemptId,
      if (stageInfo != null) 'stageInfo': stageInfo,
      if (serverpodVersionConstraint != null)
        'serverpodVersionConstraint': serverpodVersionConstraint,
      if (imageName != null) 'imageName': imageName,
      if (statusInfo != null) 'statusInfo': statusInfo,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeployAttemptStageImpl extends DeployAttemptStage {
  _DeployAttemptStageImpl({
    int? id,
    required String cloudCapsuleId,
    required _i1.UuidValue deployAttemptId,
    _i2.DeployAttempt? deploymentAttempt,
    String? externalId,
    required _i3.DeployStageType stageType,
    String? buildId,
    required _i4.DeployProgressStatus stageStatus,
    DateTime? startedAt,
    DateTime? endedAt,
    required String attemptId,
    String? stageInfo,
    String? serverpodVersionConstraint,
    String? imageName,
    String? statusInfo,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         deployAttemptId: deployAttemptId,
         deploymentAttempt: deploymentAttempt,
         externalId: externalId,
         stageType: stageType,
         buildId: buildId,
         stageStatus: stageStatus,
         startedAt: startedAt,
         endedAt: endedAt,
         attemptId: attemptId,
         stageInfo: stageInfo,
         serverpodVersionConstraint: serverpodVersionConstraint,
         imageName: imageName,
         statusInfo: statusInfo,
       );

  /// Returns a shallow copy of this [DeployAttemptStage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeployAttemptStage copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    _i1.UuidValue? deployAttemptId,
    Object? deploymentAttempt = _Undefined,
    Object? externalId = _Undefined,
    _i3.DeployStageType? stageType,
    Object? buildId = _Undefined,
    _i4.DeployProgressStatus? stageStatus,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
    String? attemptId,
    Object? stageInfo = _Undefined,
    Object? serverpodVersionConstraint = _Undefined,
    Object? imageName = _Undefined,
    Object? statusInfo = _Undefined,
  }) {
    return DeployAttemptStage(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      deployAttemptId: deployAttemptId ?? this.deployAttemptId,
      deploymentAttempt: deploymentAttempt is _i2.DeployAttempt?
          ? deploymentAttempt
          : this.deploymentAttempt?.copyWith(),
      externalId: externalId is String? ? externalId : this.externalId,
      stageType: stageType ?? this.stageType,
      buildId: buildId is String? ? buildId : this.buildId,
      stageStatus: stageStatus ?? this.stageStatus,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      attemptId: attemptId ?? this.attemptId,
      stageInfo: stageInfo is String? ? stageInfo : this.stageInfo,
      serverpodVersionConstraint: serverpodVersionConstraint is String?
          ? serverpodVersionConstraint
          : this.serverpodVersionConstraint,
      imageName: imageName is String? ? imageName : this.imageName,
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
    );
  }
}

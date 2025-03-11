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
import '../../../domains/status/models/deploy_stage_type.dart' as _i2;
import '../../../domains/status/models/deploy_progress_status.dart' as _i3;

/// Represents the status information of a stage in a deployment attempt.
abstract class DeployAttemptStage implements _i1.SerializableModel {
  DeployAttemptStage._({
    this.id,
    required this.cloudCapsuleId,
    required this.attemptId,
    required this.stageType,
    this.stageInfo,
    this.buildId,
    required this.stageStatus,
    this.startedAt,
    this.endedAt,
    this.statusInfo,
  });

  factory DeployAttemptStage({
    int? id,
    required String cloudCapsuleId,
    required String attemptId,
    required _i2.DeployStageType stageType,
    String? stageInfo,
    String? buildId,
    required _i3.DeployProgressStatus stageStatus,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
  }) = _DeployAttemptStageImpl;

  factory DeployAttemptStage.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttemptStage(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      attemptId: jsonSerialization['attemptId'] as String,
      stageType: _i2.DeployStageType.fromJson(
          (jsonSerialization['stageType'] as String)),
      stageInfo: jsonSerialization['stageInfo'] as String?,
      buildId: jsonSerialization['buildId'] as String?,
      stageStatus: _i3.DeployProgressStatus.fromJson(
          (jsonSerialization['stageStatus'] as String)),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      statusInfo: jsonSerialization['statusInfo'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The ID of the capsule of this deployment.
  String cloudCapsuleId;

  /// The ID of the deploy attempt.
  String attemptId;

  /// The type of this stage.
  /// Unique within the deployment attempt.
  _i2.DeployStageType stageType;

  /// Optional information about the stage,
  /// which is immutable i.e. independent of the status.
  /// This should be a human-readable string.
  String? stageInfo;

  /// The build ID of the deploy attempt that this stage belongs to, if known.
  String? buildId;

  /// The current / last known status of this stage.
  _i3.DeployProgressStatus stageStatus;

  DateTime? startedAt;

  DateTime? endedAt;

  /// Optionally contains user-readable information about the current status of this stage.
  String? statusInfo;

  /// Returns a shallow copy of this [DeployAttemptStage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeployAttemptStage copyWith({
    int? id,
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployStageType? stageType,
    String? stageInfo,
    String? buildId,
    _i3.DeployProgressStatus? stageStatus,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'attemptId': attemptId,
      'stageType': stageType.toJson(),
      if (stageInfo != null) 'stageInfo': stageInfo,
      if (buildId != null) 'buildId': buildId,
      'stageStatus': stageStatus.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
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
    required String attemptId,
    required _i2.DeployStageType stageType,
    String? stageInfo,
    String? buildId,
    required _i3.DeployProgressStatus stageStatus,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
  }) : super._(
          id: id,
          cloudCapsuleId: cloudCapsuleId,
          attemptId: attemptId,
          stageType: stageType,
          stageInfo: stageInfo,
          buildId: buildId,
          stageStatus: stageStatus,
          startedAt: startedAt,
          endedAt: endedAt,
          statusInfo: statusInfo,
        );

  /// Returns a shallow copy of this [DeployAttemptStage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeployAttemptStage copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployStageType? stageType,
    Object? stageInfo = _Undefined,
    Object? buildId = _Undefined,
    _i3.DeployProgressStatus? stageStatus,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
    Object? statusInfo = _Undefined,
  }) {
    return DeployAttemptStage(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      attemptId: attemptId ?? this.attemptId,
      stageType: stageType ?? this.stageType,
      stageInfo: stageInfo is String? ? stageInfo : this.stageInfo,
      buildId: buildId is String? ? buildId : this.buildId,
      stageStatus: stageStatus ?? this.stageStatus,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
    );
  }
}

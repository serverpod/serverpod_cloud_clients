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
import '../status/deploy_stage_type.dart' as _i2;
import '../status/deploy_progress_status.dart' as _i3;

/// Represents the status information of a stage in a deployment attempt.
abstract class DeployAttemptStage implements _i1.SerializableModel {
  DeployAttemptStage._({
    this.id,
    required this.cloudEnvironmentId,
    required this.attemptId,
    required this.stageType,
    this.stageInfo,
    this.externalId,
    required this.stageStatus,
    DateTime? createTime,
    this.startTime,
    this.endTime,
    this.statusInfo,
  }) : createTime = createTime ?? DateTime.now();

  factory DeployAttemptStage({
    int? id,
    required String cloudEnvironmentId,
    required String attemptId,
    required _i2.DeployStageType stageType,
    String? stageInfo,
    String? externalId,
    required _i3.DeployProgressStatus stageStatus,
    DateTime? createTime,
    DateTime? startTime,
    DateTime? endTime,
    String? statusInfo,
  }) = _DeployAttemptStageImpl;

  factory DeployAttemptStage.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttemptStage(
      id: jsonSerialization['id'] as int?,
      cloudEnvironmentId: jsonSerialization['cloudEnvironmentId'] as String,
      attemptId: jsonSerialization['attemptId'] as String,
      stageType: _i2.DeployStageType.fromJson(
          (jsonSerialization['stageType'] as String)),
      stageInfo: jsonSerialization['stageInfo'] as String?,
      externalId: jsonSerialization['externalId'] as String?,
      stageStatus: _i3.DeployProgressStatus.fromJson(
          (jsonSerialization['stageStatus'] as String)),
      createTime:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createTime']),
      startTime: jsonSerialization['startTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startTime']),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      statusInfo: jsonSerialization['statusInfo'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The ID of the environment of this deployment.
  String cloudEnvironmentId;

  /// The ID of the deploy attempt.
  String attemptId;

  /// The type of this stage.
  /// Unique within the deployment attempt.
  _i2.DeployStageType stageType;

  /// Optional information about the stage,
  /// which is immutable i.e. independent of the status.
  /// This should be a human-readable string.
  String? stageInfo;

  /// If this stage corresponds to an external entity/operation instance,
  /// this field identifies it.
  String? externalId;

  /// The current / last known status of this stage.
  _i3.DeployProgressStatus stageStatus;

  DateTime createTime;

  DateTime? startTime;

  DateTime? endTime;

  /// Optionally contains user-readable information about the current status of this stage.
  String? statusInfo;

  DeployAttemptStage copyWith({
    int? id,
    String? cloudEnvironmentId,
    String? attemptId,
    _i2.DeployStageType? stageType,
    String? stageInfo,
    String? externalId,
    _i3.DeployProgressStatus? stageStatus,
    DateTime? createTime,
    DateTime? startTime,
    DateTime? endTime,
    String? statusInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cloudEnvironmentId': cloudEnvironmentId,
      'attemptId': attemptId,
      'stageType': stageType.toJson(),
      if (stageInfo != null) 'stageInfo': stageInfo,
      if (externalId != null) 'externalId': externalId,
      'stageStatus': stageStatus.toJson(),
      'createTime': createTime.toJson(),
      if (startTime != null) 'startTime': startTime?.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
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
    required String cloudEnvironmentId,
    required String attemptId,
    required _i2.DeployStageType stageType,
    String? stageInfo,
    String? externalId,
    required _i3.DeployProgressStatus stageStatus,
    DateTime? createTime,
    DateTime? startTime,
    DateTime? endTime,
    String? statusInfo,
  }) : super._(
          id: id,
          cloudEnvironmentId: cloudEnvironmentId,
          attemptId: attemptId,
          stageType: stageType,
          stageInfo: stageInfo,
          externalId: externalId,
          stageStatus: stageStatus,
          createTime: createTime,
          startTime: startTime,
          endTime: endTime,
          statusInfo: statusInfo,
        );

  @override
  DeployAttemptStage copyWith({
    Object? id = _Undefined,
    String? cloudEnvironmentId,
    String? attemptId,
    _i2.DeployStageType? stageType,
    Object? stageInfo = _Undefined,
    Object? externalId = _Undefined,
    _i3.DeployProgressStatus? stageStatus,
    DateTime? createTime,
    Object? startTime = _Undefined,
    Object? endTime = _Undefined,
    Object? statusInfo = _Undefined,
  }) {
    return DeployAttemptStage(
      id: id is int? ? id : this.id,
      cloudEnvironmentId: cloudEnvironmentId ?? this.cloudEnvironmentId,
      attemptId: attemptId ?? this.attemptId,
      stageType: stageType ?? this.stageType,
      stageInfo: stageInfo is String? ? stageInfo : this.stageInfo,
      externalId: externalId is String? ? externalId : this.externalId,
      stageStatus: stageStatus ?? this.stageStatus,
      createTime: createTime ?? this.createTime,
      startTime: startTime is DateTime? ? startTime : this.startTime,
      endTime: endTime is DateTime? ? endTime : this.endTime,
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
    );
  }
}

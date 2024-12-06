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
import '../status/deploy_progress_status.dart' as _i2;

/// Represents the status information of a deployment attempt.
abstract class DeployAttempt implements _i1.SerializableModel {
  DeployAttempt._({
    required this.cloudEnvironmentId,
    required this.attemptId,
    required this.status,
    this.startTime,
    this.endTime,
    this.statusInfo,
  });

  factory DeployAttempt({
    required String cloudEnvironmentId,
    required String attemptId,
    required _i2.DeployProgressStatus status,
    DateTime? startTime,
    DateTime? endTime,
    String? statusInfo,
  }) = _DeployAttemptImpl;

  factory DeployAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttempt(
      cloudEnvironmentId: jsonSerialization['cloudEnvironmentId'] as String,
      attemptId: jsonSerialization['attemptId'] as String,
      status: _i2.DeployProgressStatus.fromJson(
          (jsonSerialization['status'] as String)),
      startTime: jsonSerialization['startTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startTime']),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      statusInfo: jsonSerialization['statusInfo'] as String?,
    );
  }

  /// The ID of the environment of this deployment.
  String cloudEnvironmentId;

  /// The ID of this deploy attempt.
  String attemptId;

  /// The current status of this deployment.
  _i2.DeployProgressStatus status;

  DateTime? startTime;

  DateTime? endTime;

  /// Optionally contains user-readable information about the current status of this attempt.
  String? statusInfo;

  DeployAttempt copyWith({
    String? cloudEnvironmentId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    String? statusInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'cloudEnvironmentId': cloudEnvironmentId,
      'attemptId': attemptId,
      'status': status.toJson(),
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

class _DeployAttemptImpl extends DeployAttempt {
  _DeployAttemptImpl({
    required String cloudEnvironmentId,
    required String attemptId,
    required _i2.DeployProgressStatus status,
    DateTime? startTime,
    DateTime? endTime,
    String? statusInfo,
  }) : super._(
          cloudEnvironmentId: cloudEnvironmentId,
          attemptId: attemptId,
          status: status,
          startTime: startTime,
          endTime: endTime,
          statusInfo: statusInfo,
        );

  @override
  DeployAttempt copyWith({
    String? cloudEnvironmentId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    Object? startTime = _Undefined,
    Object? endTime = _Undefined,
    Object? statusInfo = _Undefined,
  }) {
    return DeployAttempt(
      cloudEnvironmentId: cloudEnvironmentId ?? this.cloudEnvironmentId,
      attemptId: attemptId ?? this.attemptId,
      status: status ?? this.status,
      startTime: startTime is DateTime? ? startTime : this.startTime,
      endTime: endTime is DateTime? ? endTime : this.endTime,
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
    );
  }
}

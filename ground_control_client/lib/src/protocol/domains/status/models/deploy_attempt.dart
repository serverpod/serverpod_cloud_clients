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
import '../../../domains/status/models/deploy_progress_status.dart' as _i2;

/// Represents the status information of a deployment attempt.
abstract class DeployAttempt implements _i1.SerializableModel {
  DeployAttempt._({
    required this.cloudCapsuleId,
    required this.attemptId,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.statusInfo,
  });

  factory DeployAttempt({
    required String cloudCapsuleId,
    required String attemptId,
    required _i2.DeployProgressStatus status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
  }) = _DeployAttemptImpl;

  factory DeployAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployAttempt(
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      attemptId: jsonSerialization['attemptId'] as String,
      status: _i2.DeployProgressStatus.fromJson(
          (jsonSerialization['status'] as String)),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      statusInfo: jsonSerialization['statusInfo'] as String?,
    );
  }

  /// The ID of the capsule of this deployment.
  String cloudCapsuleId;

  /// The ID of this deploy attempt.
  String attemptId;

  /// The current status of this deployment.
  _i2.DeployProgressStatus status;

  DateTime? startedAt;

  DateTime? endedAt;

  /// Optionally contains user-readable information about the current status of this attempt.
  String? statusInfo;

  /// Returns a shallow copy of this [DeployAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeployAttempt copyWith({
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'cloudCapsuleId': cloudCapsuleId,
      'attemptId': attemptId,
      'status': status.toJson(),
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

class _DeployAttemptImpl extends DeployAttempt {
  _DeployAttemptImpl({
    required String cloudCapsuleId,
    required String attemptId,
    required _i2.DeployProgressStatus status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? statusInfo,
  }) : super._(
          cloudCapsuleId: cloudCapsuleId,
          attemptId: attemptId,
          status: status,
          startedAt: startedAt,
          endedAt: endedAt,
          statusInfo: statusInfo,
        );

  /// Returns a shallow copy of this [DeployAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeployAttempt copyWith({
    String? cloudCapsuleId,
    String? attemptId,
    _i2.DeployProgressStatus? status,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
    Object? statusInfo = _Undefined,
  }) {
    return DeployAttempt(
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      attemptId: attemptId ?? this.attemptId,
      status: status ?? this.status,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      statusInfo: statusInfo is String? ? statusInfo : this.statusInfo,
    );
  }
}

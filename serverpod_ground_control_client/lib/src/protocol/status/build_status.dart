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

/// Represents the status information of a build.
abstract class BuildStatus implements _i1.SerializableModel {
  BuildStatus._({
    required this.cloudProjectId,
    required this.cloudEnvironmentId,
    required this.buildId,
    required this.status,
    this.startTime,
    this.finishTime,
    this.info,
  });

  factory BuildStatus({
    required String cloudProjectId,
    required String cloudEnvironmentId,
    required String buildId,
    required String status,
    DateTime? startTime,
    DateTime? finishTime,
    String? info,
  }) = _BuildStatusImpl;

  factory BuildStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return BuildStatus(
      cloudProjectId: jsonSerialization['cloudProjectId'] as String,
      cloudEnvironmentId: jsonSerialization['cloudEnvironmentId'] as String,
      buildId: jsonSerialization['buildId'] as String,
      status: jsonSerialization['status'] as String,
      startTime: jsonSerialization['startTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startTime']),
      finishTime: jsonSerialization['finishTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['finishTime']),
      info: jsonSerialization['info'] as String?,
    );
  }

  /// The ID of the tenant project this build status is from.
  String cloudProjectId;

  /// The ID of the environment this build status is from.
  String cloudEnvironmentId;

  /// The ID of the build.
  String buildId;

  /// The status of the build, e.g. SUCCESS, TIMEOUT, CANCELLED, FAILURE.
  String status;

  DateTime? startTime;

  DateTime? finishTime;

  /// If build status is not SUCCESS this field contains information about
  /// the current step in progress or which step failed and why.
  String? info;

  BuildStatus copyWith({
    String? cloudProjectId,
    String? cloudEnvironmentId,
    String? buildId,
    String? status,
    DateTime? startTime,
    DateTime? finishTime,
    String? info,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'cloudProjectId': cloudProjectId,
      'cloudEnvironmentId': cloudEnvironmentId,
      'buildId': buildId,
      'status': status,
      if (startTime != null) 'startTime': startTime?.toJson(),
      if (finishTime != null) 'finishTime': finishTime?.toJson(),
      if (info != null) 'info': info,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BuildStatusImpl extends BuildStatus {
  _BuildStatusImpl({
    required String cloudProjectId,
    required String cloudEnvironmentId,
    required String buildId,
    required String status,
    DateTime? startTime,
    DateTime? finishTime,
    String? info,
  }) : super._(
          cloudProjectId: cloudProjectId,
          cloudEnvironmentId: cloudEnvironmentId,
          buildId: buildId,
          status: status,
          startTime: startTime,
          finishTime: finishTime,
          info: info,
        );

  @override
  BuildStatus copyWith({
    String? cloudProjectId,
    String? cloudEnvironmentId,
    String? buildId,
    String? status,
    Object? startTime = _Undefined,
    Object? finishTime = _Undefined,
    Object? info = _Undefined,
  }) {
    return BuildStatus(
      cloudProjectId: cloudProjectId ?? this.cloudProjectId,
      cloudEnvironmentId: cloudEnvironmentId ?? this.cloudEnvironmentId,
      buildId: buildId ?? this.buildId,
      status: status ?? this.status,
      startTime: startTime is DateTime? ? startTime : this.startTime,
      finishTime: finishTime is DateTime? ? finishTime : this.finishTime,
      info: info is String? ? info : this.info,
    );
  }
}

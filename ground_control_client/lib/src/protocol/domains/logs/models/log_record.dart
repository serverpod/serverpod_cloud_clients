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

/// Represents a log record (entry).
abstract class LogRecord implements _i1.SerializableModel {
  LogRecord._({
    required this.cloudProjectId,
    required this.cloudCapsuleId,
    required this.recordId,
    required this.timestamp,
    this.severity,
    required this.content,
  });

  factory LogRecord({
    required String cloudProjectId,
    required String cloudCapsuleId,
    required String recordId,
    required DateTime timestamp,
    String? severity,
    required String content,
  }) = _LogRecordImpl;

  factory LogRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return LogRecord(
      cloudProjectId: jsonSerialization['cloudProjectId'] as String,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      recordId: jsonSerialization['recordId'] as String,
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
      severity: jsonSerialization['severity'] as String?,
      content: jsonSerialization['content'] as String,
    );
  }

  /// The ID of the project this log record is from.
  String cloudProjectId;

  /// The ID of the capsule this log record is from.
  String cloudCapsuleId;

  /// The ID of this log record.
  String recordId;

  /// The timestamp of the log record.
  DateTime timestamp;

  /// The severity level of the log record.
  String? severity;

  /// The log message content. May be a string or a string-encoded JSON object.
  String content;

  /// Returns a shallow copy of this [LogRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LogRecord copyWith({
    String? cloudProjectId,
    String? cloudCapsuleId,
    String? recordId,
    DateTime? timestamp,
    String? severity,
    String? content,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'cloudProjectId': cloudProjectId,
      'cloudCapsuleId': cloudCapsuleId,
      'recordId': recordId,
      'timestamp': timestamp.toJson(),
      if (severity != null) 'severity': severity,
      'content': content,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LogRecordImpl extends LogRecord {
  _LogRecordImpl({
    required String cloudProjectId,
    required String cloudCapsuleId,
    required String recordId,
    required DateTime timestamp,
    String? severity,
    required String content,
  }) : super._(
          cloudProjectId: cloudProjectId,
          cloudCapsuleId: cloudCapsuleId,
          recordId: recordId,
          timestamp: timestamp,
          severity: severity,
          content: content,
        );

  /// Returns a shallow copy of this [LogRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LogRecord copyWith({
    String? cloudProjectId,
    String? cloudCapsuleId,
    String? recordId,
    DateTime? timestamp,
    Object? severity = _Undefined,
    String? content,
  }) {
    return LogRecord(
      cloudProjectId: cloudProjectId ?? this.cloudProjectId,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      recordId: recordId ?? this.recordId,
      timestamp: timestamp ?? this.timestamp,
      severity: severity is String? ? severity : this.severity,
      content: content ?? this.content,
    );
  }
}

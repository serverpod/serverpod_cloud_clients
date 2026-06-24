import 'package:ground_control_client/ground_control_client.dart';

class LogRecordBuilder {
  String _cloudProjectId;
  String _cloudCapsuleId;
  UuidValue _deployAttemptId;
  String? _serverInstanceId;
  String _recordId;
  DateTime _timestamp;
  String? _severity;
  String _content;

  LogRecordBuilder()
    : _cloudProjectId = 'test-project-id',
      _cloudCapsuleId = 'test-project-id',
      _deployAttemptId = UuidValue.raw('00000000-0000-4000-8000-000000000000'),
      _serverInstanceId = 'server-instance-1',
      _recordId = Uuid().v4(),
      _timestamp = DateTime.now(),
      _severity = 'INFO',
      _content = 'test-log-record-message';

  /// Sets the cloud project and capsule IDs to the same value.
  LogRecordBuilder withCloudIds(final String cloudId) {
    _cloudProjectId = cloudId;
    _cloudCapsuleId = cloudId;
    return this;
  }

  LogRecordBuilder withCloudProjectId(final String cloudProjectId) {
    _cloudProjectId = cloudProjectId;
    return this;
  }

  LogRecordBuilder withCloudCapsuleId(final String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  LogRecordBuilder withDeployAttemptId(final UuidValue deployAttemptId) {
    _deployAttemptId = deployAttemptId;
    return this;
  }

  LogRecordBuilder withServerInstanceId(final String? serverInstanceId) {
    _serverInstanceId = serverInstanceId;
    return this;
  }

  LogRecordBuilder withRecordId(final String recordId) {
    _recordId = recordId;
    return this;
  }

  LogRecordBuilder withTimestamp(final DateTime timestamp) {
    _timestamp = timestamp;
    return this;
  }

  LogRecordBuilder withSeverity(final String? severity) {
    _severity = severity;
    return this;
  }

  LogRecordBuilder withContent(final String content) {
    _content = content;
    return this;
  }

  LogRecord build() {
    return LogRecord(
      cloudProjectId: _cloudProjectId,
      cloudCapsuleId: _cloudCapsuleId,
      deployAttemptId: _deployAttemptId,
      serverInstanceId: _serverInstanceId,
      recordId: _recordId,
      timestamp: _timestamp,
      severity: _severity,
      content: _content,
    );
  }
}

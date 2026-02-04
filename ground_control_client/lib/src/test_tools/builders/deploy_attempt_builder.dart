import 'package:ground_control_client/ground_control_client.dart';

class DeployAttemptBuilder {
  String _cloudCapsuleId;
  String _attemptId;
  DeployProgressStatus _status;
  DateTime? _startedAt;
  DateTime? _endedAt;
  String? _statusInfo;

  DeployAttemptBuilder()
    : _cloudCapsuleId = 'test-capsule-id',
      _attemptId = 'test-attempt-id',
      _status = DeployProgressStatus.awaiting,
      _startedAt = DateTime.now(),
      _endedAt = null,
      _statusInfo = null;

  DeployAttemptBuilder withCloudCapsuleId(final String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  DeployAttemptBuilder withAttemptId(final String attemptId) {
    _attemptId = attemptId;
    return this;
  }

  DeployAttemptBuilder withStatus(final DeployProgressStatus status) {
    _status = status;
    return this;
  }

  DeployAttemptBuilder withStartedAt(final DateTime? startedAt) {
    _startedAt = startedAt;
    return this;
  }

  DeployAttemptBuilder withEndedAt(final DateTime? endedAt) {
    _endedAt = endedAt;
    return this;
  }

  DeployAttemptBuilder withStatusInfo(final String? statusInfo) {
    _statusInfo = statusInfo;
    return this;
  }

  DeployAttempt build() {
    return DeployAttempt(
      cloudCapsuleId: _cloudCapsuleId,
      attemptId: _attemptId,
      status: _status,
      startedAt: _startedAt,
      endedAt: _endedAt,
      statusInfo: _statusInfo,
    );
  }
}

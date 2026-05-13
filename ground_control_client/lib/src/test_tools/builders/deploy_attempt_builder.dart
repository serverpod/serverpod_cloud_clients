import 'package:ground_control_client/ground_control_client.dart';

class DeployAttemptBuilder {
  String _cloudCapsuleId;
  String _attemptId;
  DeployProgressStatus _status;
  DateTime? _startedAt;
  DateTime? _endedAt;
  String? _statusInfo;
  String? _commitHash;
  String? _commitMessage;
  String? _branch;
  String? _deployedBy;
  String? _serverpodVersion;
  String? _dartVersion;
  List<DeployAttemptStage>? _stages;

  DeployAttemptBuilder()
    : _cloudCapsuleId = 'test-capsule-id',
      _attemptId = 'test-attempt-id',
      _status = DeployProgressStatus.awaiting,
      _startedAt = DateTime.now(),
      _endedAt = null,
      _statusInfo = null,
      _commitHash = null,
      _commitMessage = null,
      _branch = null,
      _deployedBy = null,
      _serverpodVersion = null,
      _dartVersion = null,
      _stages = null;

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

  DeployAttemptBuilder withCommitHash(final String? commitHash) {
    _commitHash = commitHash;
    return this;
  }

  DeployAttemptBuilder withCommitMessage(final String? commitMessage) {
    _commitMessage = commitMessage;
    return this;
  }

  DeployAttemptBuilder withBranch(final String? branch) {
    _branch = branch;
    return this;
  }

  DeployAttemptBuilder withDeployedBy(final String? deployedBy) {
    _deployedBy = deployedBy;
    return this;
  }

  DeployAttemptBuilder withServerpodVersion(final String? serverpodVersion) {
    _serverpodVersion = serverpodVersion;
    return this;
  }

  DeployAttemptBuilder withDartVersion(final String? dartVersion) {
    _dartVersion = dartVersion;
    return this;
  }

  DeployAttemptBuilder withStages(final List<DeployAttemptStage>? stages) {
    _stages = stages;
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
      commitHash: _commitHash,
      commitMessage: _commitMessage,
      branch: _branch,
      deployedBy: _deployedBy,
      serverpodVersion: _serverpodVersion,
      dartVersion: _dartVersion,
      stages: _stages,
    );
  }
}

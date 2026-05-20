import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class DeployAttemptBuilder {
  String _cloudCapsuleId;
  String _attemptId;
  DeployProgressStatus? _status;
  String? _statusInfo;
  String? _serverpodVersion;
  String? _dartVersion;
  String? _commitHash;
  String? _commitMessage;
  String? _branch;
  User? _deployedBy;
  List<DeployAttemptStage>? _stages;
  DateTime? _startedAt;
  DateTime? _endedAt;

  DeployAttemptBuilder()
    : _cloudCapsuleId = 'test-capsule-id',
      _attemptId = 'test-attempt-id',
      _statusInfo = null,
      _serverpodVersion = '3.5.0',
      _dartVersion = '3.11',
      _commitHash = '279d40t5',
      _commitMessage = 'feat: My awesome new feature',
      _branch = 'main',
      _deployedBy = UserBuilder().build() {
    _stages = [
      DeployAttemptStageBuilder()
          .withBuildStageSuccess()
          .withAttemptId(_attemptId.toString())
          .build(),
    ];
  }

  DeployAttemptBuilder withSuccessfulDeployment() {
    _stages = [
      DeployAttemptStageBuilder()
          .withUploadStageSuccess()
          .withAttemptId(_attemptId.toString())
          .build(),
      DeployAttemptStageBuilder()
          .withBuildStageSuccess()
          .withAttemptId(_attemptId.toString())
          .build(),
      DeployAttemptStageBuilder()
          .withDeployStageSuccess()
          .withAttemptId(_attemptId.toString())
          .build(),
    ];
    return this;
  }

  DeployAttemptBuilder withFailedDeployment() {
    _stages = [
      DeployAttemptStageBuilder()
          .withUploadStageSuccess()
          .withAttemptId(_attemptId.toString())
          .build(),
      DeployAttemptStageBuilder()
          .withBuildStageSuccess()
          .withAttemptId(_attemptId.toString())
          .build(),
      DeployAttemptStageBuilder()
          .withDeployStageFailure()
          .withAttemptId(_attemptId.toString())
          .build(),
    ];
    return this;
  }

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

  DeployAttemptBuilder withStatusInfo(final String? statusInfo) {
    _statusInfo = statusInfo;
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

  DeployAttemptBuilder withDeployedBy(final User? deployedBy) {
    _deployedBy = deployedBy;
    return this;
  }

  DeployAttemptBuilder withStages(final List<DeployAttemptStage> stages) {
    _stages = stages;
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

  DeployAttempt build() {
    final status = _stages?.last.stageStatus;

    return DeployAttempt(
      id: Uuid().v4obj(),
      cloudCapsuleId: _cloudCapsuleId,
      attemptId: _attemptId,
      status: _status ?? status,
      startedAt: _startedAt ?? _stages?.first.startedAt,
      endedAt: _endedAt ?? _stages?.last.endedAt,
      statusInfo: _statusInfo,
      serverpodVersion: _serverpodVersion,
      dartVersion: _dartVersion,
      commitHash: _commitHash,
      commitMessage: _commitMessage,
      branch: _branch,
      deployedById: _deployedBy?.id,
      deployedBy: _deployedBy,
      stages: _stages
          ?.map(
            (final e) => e.copyWith(
              attemptId: _attemptId,
              cloudCapsuleId: _cloudCapsuleId,
            ),
          )
          .toList(),
    );
  }
}

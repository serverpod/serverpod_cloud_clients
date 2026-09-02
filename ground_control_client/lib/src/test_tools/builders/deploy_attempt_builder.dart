import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class DeployAttemptBuilder {
  String _cloudCapsuleId;
  UuidValue _attemptId;
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
      _attemptId = Uuid().v4obj(),
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
          .withAttemptId(_attemptId)
          .build(),
    ];
  }

  DeployAttemptBuilder withSuccessfulDeployment() {
    _stages = [
      DeployAttemptStageBuilder()
          .withUploadStageSuccess()
          .withAttemptId(_attemptId)
          .build(),
      DeployAttemptStageBuilder()
          .withBuildStageSuccess()
          .withAttemptId(_attemptId)
          .build(),
      DeployAttemptStageBuilder()
          .withDeployStageSuccess()
          .withAttemptId(_attemptId)
          .build(),
    ];
    return this;
  }

  DeployAttemptBuilder withFailedDeployment() {
    _stages = [
      DeployAttemptStageBuilder()
          .withUploadStageSuccess()
          .withAttemptId(_attemptId)
          .build(),
      DeployAttemptStageBuilder()
          .withBuildStageSuccess()
          .withAttemptId(_attemptId)
          .build(),
      DeployAttemptStageBuilder()
          .withDeployStageFailure()
          .withAttemptId(_attemptId)
          .build(),
    ];
    return this;
  }

  DeployAttemptBuilder withCloudCapsuleId(String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  DeployAttemptBuilder withAttemptId(UuidValue attemptId) {
    _attemptId = attemptId;
    return this;
  }

  DeployAttemptBuilder withStatus(DeployProgressStatus status) {
    _status = status;
    return this;
  }

  DeployAttemptBuilder withStatusInfo(String? statusInfo) {
    _statusInfo = statusInfo;
    return this;
  }

  DeployAttemptBuilder withServerpodVersion(String? serverpodVersion) {
    _serverpodVersion = serverpodVersion;
    return this;
  }

  DeployAttemptBuilder withDartVersion(String? dartVersion) {
    _dartVersion = dartVersion;
    return this;
  }

  DeployAttemptBuilder withCommitHash(String? commitHash) {
    _commitHash = commitHash;
    return this;
  }

  DeployAttemptBuilder withCommitMessage(String? commitMessage) {
    _commitMessage = commitMessage;
    return this;
  }

  DeployAttemptBuilder withBranch(String? branch) {
    _branch = branch;
    return this;
  }

  DeployAttemptBuilder withDeployedBy(User? deployedBy) {
    _deployedBy = deployedBy;
    return this;
  }

  DeployAttemptBuilder withStages(List<DeployAttemptStage> stages) {
    _stages = stages;
    return this;
  }

  DeployAttemptBuilder withStartedAt(DateTime? startedAt) {
    _startedAt = startedAt;
    return this;
  }

  DeployAttemptBuilder withEndedAt(DateTime? endedAt) {
    _endedAt = endedAt;
    return this;
  }

  DeployAttempt build() {
    final status = _stages?.last.stageStatus;

    return DeployAttempt(
      id: Uuid().v4obj(),
      cloudCapsuleId: _cloudCapsuleId,
      attemptId: _attemptId.toString(),
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
            (e) => e.copyWith(
              attemptId: _attemptId,
              cloudCapsuleId: _cloudCapsuleId,
            ),
          )
          .toList(),
    );
  }
}

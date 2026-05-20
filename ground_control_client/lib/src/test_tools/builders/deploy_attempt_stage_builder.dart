import 'package:ground_control_client/ground_control_client.dart';

class DeployAttemptStageBuilder {
  String _cloudCapsuleId;
  String _attemptId;
  DeployStageType _stageType;
  DeployProgressStatus _stageStatus;
  String? _stageInfo;
  String? _serverpodVersionConstraint;
  String? _buildId;
  String? _imageName;
  String? _statusInfo;
  DateTime? _startedAt;
  DateTime? _endedAt;
  String? _externalId;

  DeployAttemptStageBuilder()
    : _cloudCapsuleId = 'test-capsule-id',
      _attemptId = 'test-attempt-id',
      _stageType = DeployStageType.upload,
      _stageStatus = DeployProgressStatus.awaiting,
      _stageInfo = null,
      _serverpodVersionConstraint = null,
      _buildId = null,
      _externalId = null,
      _imageName = null,
      _statusInfo = null,
      _startedAt = DateTime.now(),
      _endedAt = null;

  DeployAttemptStageBuilder withUploadStageSuccess() {
    _stageType = DeployStageType.upload;
    _stageStatus = DeployProgressStatus.success;
    _startedAt = DateTime.now();
    _endedAt = DateTime.now().add(Duration(seconds: 16));
    return this;
  }

  DeployAttemptStageBuilder withBuildStageSuccess() {
    _stageType = DeployStageType.build;
    _stageStatus = DeployProgressStatus.success;
    _startedAt = DateTime.now();
    _endedAt = DateTime.now().add(Duration(seconds: 95));
    _externalId = 'test-build-id';
    _buildId = 'test-build-id';
    _imageName = 'test-image-name';
    return this;
  }

  DeployAttemptStageBuilder withDeployStageSuccess() {
    _stageType = DeployStageType.deploy;
    _stageStatus = DeployProgressStatus.success;
    _startedAt = DateTime.now();
    _endedAt = DateTime.now().add(Duration(seconds: 24));
    return this;
  }

  DeployAttemptStageBuilder withDeployStageFailure() {
    _stageType = DeployStageType.deploy;
    _stageStatus = DeployProgressStatus.failure;
    _startedAt = DateTime.now();
    _endedAt = DateTime.now().add(Duration(seconds: 24));
    return this;
  }

  DeployAttemptStageBuilder withCloudCapsuleId(final String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  DeployAttemptStageBuilder withAttemptId(final String attemptId) {
    _attemptId = attemptId;
    return this;
  }

  DeployAttemptStageBuilder withStageType(final DeployStageType stageType) {
    _stageType = stageType;
    return this;
  }

  DeployAttemptStageBuilder withStageStatus(
    final DeployProgressStatus stageStatus,
  ) {
    _stageStatus = stageStatus;
    if (stageStatus == DeployProgressStatus.success ||
        stageStatus == DeployProgressStatus.failure) {
      _endedAt ??= DateTime.now();
    }
    return this;
  }

  DeployAttemptStageBuilder withStageInfo(final String? stageInfo) {
    _stageInfo = stageInfo;
    return this;
  }

  DeployAttemptStageBuilder withServerpodVersionConstraint(
    final String? serverpodVersionConstraint,
  ) {
    _serverpodVersionConstraint = serverpodVersionConstraint;
    return this;
  }

  DeployAttemptStageBuilder withBuildId(final String? buildId) {
    _buildId = buildId;
    _externalId = buildId;
    return this;
  }

  DeployAttemptStageBuilder withImageName(final String? imageName) {
    _imageName = imageName;
    return this;
  }

  DeployAttemptStageBuilder withStatusInfo(final String? statusInfo) {
    _statusInfo = statusInfo;
    return this;
  }

  DeployAttemptStageBuilder withStartedAt(final DateTime? startedAt) {
    _startedAt = startedAt;
    return this;
  }

  DeployAttemptStageBuilder withEndedAt(final DateTime? endedAt) {
    _endedAt = endedAt;
    return this;
  }

  DeployAttemptStage build() {
    return DeployAttemptStage(
      cloudCapsuleId: _cloudCapsuleId,
      attemptId: _attemptId,
      stageType: _stageType,
      stageStatus: _stageStatus,
      stageInfo: _stageInfo,
      serverpodVersionConstraint: _serverpodVersionConstraint,
      buildId: _buildId,
      imageName: _imageName,
      statusInfo: _statusInfo,
      startedAt: _startedAt,
      endedAt: _endedAt,
      externalId: _externalId,
    );
  }
}

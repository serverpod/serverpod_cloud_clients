import 'package:ground_control_client/ground_control_client.dart';

import 'user_builder.dart';

/// Builds an [AppBuildSummary]. The default is a succeeded iOS build.
class AppBuildSummaryBuilder {
  UuidValue _id;
  AppPlatform _platform;
  AppBuildStatus _status;
  int? _queuePosition;
  String? _versionName;
  String? _buildNumber;
  String? _message;
  User? _requestedBy;
  String? _commitHash;
  String? _commitMessage;
  String? _branch;
  UuidValue? _deployAttemptId;
  DateTime _createdAt;
  DateTime? _startedAt;
  DateTime? _endedAt;

  AppBuildSummaryBuilder()
    : _id = Uuid().v4obj(),
      _platform = AppPlatform.ios,
      _status = AppBuildStatus.succeeded,
      _versionName = '1.4.2',
      _buildNumber = '37',
      _requestedBy = UserBuilder().build(),
      _commitHash = '279d40t5',
      _commitMessage = 'feat: My awesome new feature',
      _branch = 'main',
      _createdAt = DateTime.now().subtract(const Duration(minutes: 12)),
      _startedAt = DateTime.now().subtract(const Duration(minutes: 11)),
      _endedAt = DateTime.now().subtract(const Duration(minutes: 2));

  AppBuildSummaryBuilder withQueued({int position = 1}) {
    _status = AppBuildStatus.queued;
    _queuePosition = position;
    _buildNumber = null;
    _startedAt = null;
    _endedAt = null;
    return this;
  }

  AppBuildSummaryBuilder withWaiting() {
    _status = AppBuildStatus.waiting;
    _buildNumber = null;
    _endedAt = null;
    return this;
  }

  AppBuildSummaryBuilder withRunning() {
    _status = AppBuildStatus.running;
    _buildNumber = null;
    _endedAt = null;
    return this;
  }

  AppBuildSummaryBuilder withFailed([String message = 'Build step failed']) {
    _status = AppBuildStatus.failed;
    _buildNumber = null;
    _message = message;
    return this;
  }

  AppBuildSummaryBuilder withCancelled() {
    _status = AppBuildStatus.cancelled;
    _buildNumber = null;
    return this;
  }

  AppBuildSummaryBuilder withId(UuidValue id) {
    _id = id;
    return this;
  }

  AppBuildSummaryBuilder withPlatform(AppPlatform platform) {
    _platform = platform;
    return this;
  }

  AppBuildSummaryBuilder withVersionName(String? versionName) {
    _versionName = versionName;
    return this;
  }

  AppBuildSummaryBuilder withBuildNumber(String? buildNumber) {
    _buildNumber = buildNumber;
    return this;
  }

  AppBuildSummaryBuilder withRequestedBy(User? requestedBy) {
    _requestedBy = requestedBy;
    return this;
  }

  AppBuildSummaryBuilder withCommit({
    String? hash,
    String? message,
    String? branch,
  }) {
    _commitHash = hash;
    _commitMessage = message;
    _branch = branch;
    return this;
  }

  AppBuildSummaryBuilder withDeployAttemptId(UuidValue? deployAttemptId) {
    _deployAttemptId = deployAttemptId;
    return this;
  }

  AppBuildSummaryBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  AppBuildSummary build() {
    return AppBuildSummary(
      id: _id,
      platform: _platform,
      status: _status,
      queuePosition: _queuePosition,
      versionName: _versionName,
      buildNumber: _buildNumber,
      message: _message,
      requestedBy: _requestedBy,
      commitHash: _commitHash,
      commitMessage: _commitMessage,
      branch: _branch,
      deployAttemptId: _deployAttemptId,
      createdAt: _createdAt,
      startedAt: _startedAt,
      endedAt: _endedAt,
    );
  }
}

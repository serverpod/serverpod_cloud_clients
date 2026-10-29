import 'package:ground_control_client/ground_control_client.dart';

import 'user_builder.dart';

class AppBuildSummaryBuilder {
  UuidValue _id = const Uuid().v4obj();
  UuidValue _uploadId = const Uuid().v4obj();
  AppPlatform _platform = AppPlatform.ios;
  AppBuildStatus _status = AppBuildStatus.succeeded;
  String? _versionName = '1.4.2';
  String? _buildNumber = '37';
  String? _message;
  User? _requestedBy = UserBuilder().build();
  String? _commitHash = '279d40f5';
  String? _commitMessage = 'Add wishlist screen';
  String? _branch = 'main';
  DateTime _createdAt = DateTime.now().subtract(const Duration(minutes: 12));
  DateTime? _startedAt = DateTime.now().subtract(const Duration(minutes: 11));
  DateTime? _endedAt = DateTime.now().subtract(const Duration(minutes: 2));

  AppBuildSummaryBuilder withId(UuidValue id) {
    _id = id;
    return this;
  }

  AppBuildSummaryBuilder withUploadId(UuidValue uploadId) {
    _uploadId = uploadId;
    return this;
  }

  AppBuildSummaryBuilder withPlatform(AppPlatform platform) {
    _platform = platform;
    return this;
  }

  AppBuildSummaryBuilder withStatus(AppBuildStatus status) {
    _status = status;
    return this;
  }

  AppBuildSummaryBuilder withMessage(String? message) {
    _message = message;
    return this;
  }

  AppBuildSummaryBuilder withRequestedBy(User? requestedBy) {
    _requestedBy = requestedBy;
    return this;
  }

  AppBuildSummaryBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  AppBuildSummary build() {
    return AppBuildSummary(
      id: _id,
      uploadId: _uploadId,
      platform: _platform,
      status: _status,
      versionName: _versionName,
      buildNumber: _buildNumber,
      message: _message,
      requestedBy: _requestedBy,
      commitHash: _commitHash,
      commitMessage: _commitMessage,
      branch: _branch,
      createdAt: _createdAt,
      startedAt: _startedAt,
      endedAt: _endedAt,
    );
  }
}

import 'package:ground_control_client/ground_control_client.dart';

import 'app_build_output.dart';

/// An app upload with the builds made from it, as listed by `app list`.
class AppUploadRow implements SerializableModel {
  final UuidValue uploadId;

  /// The app version the builds were made with.
  final String? versionName;

  /// The platforms the upload was built for, in [AppPlatform] order.
  final List<AppPlatform> platforms;

  /// The status of the builds as one.
  final AppBuildStatus status;

  /// When the upload was requested.
  final DateTime createdAt;

  /// The builds made from the upload, in [AppPlatform] order.
  final List<AppBuildSummary> builds;

  const AppUploadRow({
    required this.uploadId,
    required this.versionName,
    required this.platforms,
    required this.status,
    required this.createdAt,
    required this.builds,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      'uploadId': uploadId,
      'versionName': versionName,
      'platforms': platforms,
      'status': status,
      'createdAt': createdAt,
      'builds': builds.map(appBuildOutput).toList(),
    };
  }
}

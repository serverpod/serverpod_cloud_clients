import 'package:serverpod_cloud_cli/persistent_storage/scloud_settings.dart';

abstract class ContextOperations {
  static Future<Map<String, Object?>> getProjectContext(
    final ScloudSettings settings,
  ) async {
    return {'projectContext': await settings.projectContext};
  }

  static Future<Map<String, Object?>> setProjectContext(
    final ScloudSettings settings, {
    required final String projectId,
  }) async {
    await settings.setProjectContext(projectId);
    return {'projectId': projectId};
  }

  static Future<void> unsetProjectContext(final ScloudSettings settings) {
    return settings.setProjectContext(null);
  }
}

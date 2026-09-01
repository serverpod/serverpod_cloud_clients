import 'package:serverpod_cloud_cli/persistent_storage/scloud_settings.dart';

abstract class SettingsOperations {
  static Future<Map<String, Object?>> getSettings(
    final ScloudSettings settings,
  ) async {
    return {'analytics': await settings.enableAnalytics};
  }

  static Future<Map<String, Object?>> setAnalytics(
    final ScloudSettings settings, {
    required final bool analytics,
  }) async {
    await settings.setEnableAnalytics(analytics);
    return {'analytics': analytics};
  }
}

import 'package:serverpod_cloud_cli/persistent_storage/scloud_settings.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

enum CliSetting { analytics }

abstract class SettingsOperations {
  static Future<List<Map<String, Object?>>> listSettingsOperation(
    final ScloudSettings settings,
  ) async {
    return [
      {
        'name': CliSetting.analytics.name,
        'value': await settings.enableAnalytics,
      },
    ];
  }

  static Future<Map<String, Object?>> setSetting(
    final ScloudSettings settings, {
    required final String name,
    required final String value,
  }) async {
    switch (_parseName(name)) {
      case CliSetting.analytics:
        final parsed = bool.tryParse(value, caseSensitive: false);
        if (parsed == null) {
          throw FailureException(
            error: 'The analytics setting requires a boolean value.',
            hint: 'Use "true" or "false".',
          );
        }
        await settings.setEnableAnalytics(parsed);
        return {'name': name, 'value': parsed};
    }
  }

  static Future<Map<String, Object?>> unsetSetting(
    final ScloudSettings settings, {
    required final String name,
  }) async {
    switch (_parseName(name)) {
      case CliSetting.analytics:
        await settings.setEnableAnalytics(null);
        return {'name': name};
    }
  }

  static CliSetting _parseName(final String name) {
    for (final setting in CliSetting.values) {
      if (setting.name == name) {
        return setting;
      }
    }

    throw FailureException(
      error: 'Unknown setting "$name".',
      hint:
          'Available settings: '
          '${CliSetting.values.map((final setting) => setting.name).join(', ')}.',
    );
  }
}

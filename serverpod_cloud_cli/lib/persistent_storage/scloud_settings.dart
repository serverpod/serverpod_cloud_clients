import 'models/scloud_settings_data.dart';
import 'resource_manager.dart';

class ScloudSettings {
  final String _localCloudStorageDirectory;

  ServerpodCloudSettingsData? _cachedSettings;

  ScloudSettings({required final String localStoragePath})
    : _localCloudStorageDirectory = localStoragePath;

  Future<ServerpodCloudSettingsData> _fetchSettings() async {
    final settings = _cachedSettings;
    if (settings != null) {
      return settings;
    }

    final loadedSettings = await ResourceManager.tryLoadSettings(
      localStoragePath: _localCloudStorageDirectory,
    );
    if (loadedSettings != null) {
      return loadedSettings;
    }

    return ServerpodCloudSettingsData();
  }

  Future<void> _storeSettings(final ServerpodCloudSettingsData settings) async {
    await ResourceManager.storeSettings(
      settings: settings,
      localStoragePath: _localCloudStorageDirectory,
    );
  }

  /// Returns the current setting for _enable analytics_.
  /// Returns `null` if not set.
  Future<bool?> get enableAnalytics async {
    final settings = await _fetchSettings();
    return settings.enableAnalytics;
  }

  /// Sets _enable analytics_.
  Future<void> setEnableAnalytics(final bool enableAnalytics) async {
    final settings = await _fetchSettings();
    if (settings.enableAnalytics == enableAnalytics) {
      return;
    }
    settings.enableAnalytics = enableAnalytics;
    await _storeSettings(settings);
  }
}

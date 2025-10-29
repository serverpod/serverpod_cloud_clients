import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:uuid/uuid.dart';

import 'models/scloud_settings_data.dart';

abstract class ResourceManager {
  /// The directory where Serverpod tools store local data.
  static Directory get _localStorageDirectory =>
      Directory(p.join(LocalStorageManager.homeDirectory.path, '.serverpod'));

  /// The directory where Serverpod Cloud CLI stores its local data.
  static Directory get localCloudStorageDirectory =>
      Directory(p.join(_localStorageDirectory.path, 'cloud'));

  /// Gets a persistent, anonymous id for the current user.
  /// This method is copied from serverpod CLI.
  static String get uniqueUserId {
    const uuidFilePath = 'uuid';
    try {
      final userIdFile =
          File(p.join(_localStorageDirectory.path, uuidFilePath));
      final userId = userIdFile.readAsStringSync();
      return userId;
    } catch (e) {
      // Failed to read userId from file, it's probably not created.
    }
    final userId = const Uuid().v4();
    try {
      final userIdFile =
          File(p.join(_localStorageDirectory.path, uuidFilePath));
      userIdFile.createSync(recursive: true);
      userIdFile.writeAsStringSync(userId);
    } finally {}

    return userId;
  }

  static Future<void> removeServerpodCloudAuthData({
    required final String localStoragePath,
  }) async {
    try {
      await LocalStorageManager.removeFile(
        fileName: ResourceManagerConstants.serverpodCloudAuthFilePath,
        localStoragePath: localStoragePath,
      );
    } on DeleteException catch (e) {
      throw Exception(
        'Failed to remove serverpod cloud data. error: ${e.error}',
      );
    }
  }

  static Future<void> storeServerpodCloudAuthData({
    required final ServerpodCloudAuthData authData,
    required final String localStoragePath,
  }) async {
    try {
      await LocalStorageManager.storeJsonFile(
        fileName: ResourceManagerConstants.serverpodCloudAuthFilePath,
        json: authData.toJson(),
        localStoragePath: localStoragePath,
      );
    } on CreateException catch (e) {
      throw Exception(
        'Failed to store serverpod cloud data. error: ${e.error}',
      );
    } on SerializationException catch (e) {
      throw Exception(
        'Failed to store serverpod cloud data. error: ${e.error}',
      );
    } on WriteException catch (e) {
      throw Exception(
        'Failed to store serverpod cloud data. error: ${e.error}',
      );
    }
  }

  static Future<ServerpodCloudAuthData?> tryFetchServerpodCloudAuthData({
    required final String localStoragePath,
    required final CommandLogger logger,
  }) async {
    try {
      final authData = await LocalStorageManager.tryFetchAndDeserializeJsonFile(
        fileName: ResourceManagerConstants.serverpodCloudAuthFilePath,
        localStoragePath: localStoragePath,
        fromJson: ServerpodCloudAuthData.fromJson,
      );
      if (authData != null) {
        return authData;
      }
    } on ReadException catch (_) {
      logger.error(
          'Could not read file ${ResourceManagerConstants.serverpodCloudAuthFilePath}.',
          hint:
              'Please check that the Serverpod Cloud CLI has the correct permissions to '
              'read the file. If the problem persists, try deleting the file.');
      return null;
    } on DeserializationException catch (_) {
      return null;
    }

    // Transparently migrate old local auth data to new file path.
    // TODO: Remove this code when users have had time to run scloud which
    // automatically executes this.
    return await _tryMigrateAuthData(localStoragePath: localStoragePath);
  }

  static Future<ServerpodCloudAuthData?> _tryMigrateAuthData({
    required final String localStoragePath,
  }) async {
    const oldServerpodCloudStorageDir = '.serverpod_cloud';
    const oldServerpodCloudDataFilePath = 'serverpod_cloud_data.yaml';

    final oldAuthDirPath = p.join(
      LocalStorageManager.homeDirectory.path,
      oldServerpodCloudStorageDir,
    );

    // try to read the auth data from the old location
    final authData = await LocalStorageManager.tryFetchAndDeserializeJsonFile(
      localStoragePath: oldAuthDirPath,
      fileName: oldServerpodCloudDataFilePath,
      fromJson: ServerpodCloudAuthData.fromJson,
    );
    if (authData == null) {
      return null;
    }

    // store the auth data to the new location
    await storeServerpodCloudAuthData(
      authData: authData,
      localStoragePath: localStoragePath,
    );

    // remove the old file
    await LocalStorageManager.removeFile(
      localStoragePath: oldAuthDirPath,
      fileName: oldServerpodCloudDataFilePath,
    );

    return authData;
  }

  static Future<void> storeLatestCliVersion({
    required final CommandLogger logger,
    required final PackageVersionData cliVersionData,
    String? localStoragePath,
  }) async {
    localStoragePath ??= localCloudStorageDirectory.path;

    try {
      await LocalStorageManager.storeJsonFile(
        fileName: ResourceManagerConstants.latestVersionFilePath,
        json: cliVersionData.toJson(),
        localStoragePath: localStoragePath,
      );
    } catch (e) {
      // Ignore since users can't do anything about it.
      logger.debug(
        'Failed to store latest cli version to file: $e',
      );
    }
  }

  static Future<PackageVersionData?> tryFetchLatestCliVersion({
    String? localStoragePath,
    required final CommandLogger logger,
  }) async {
    localStoragePath ??= localCloudStorageDirectory.path;

    void deleteFile(final File file) {
      try {
        file.deleteSync();
      } catch (e) {
        // Ignore since users can't do anything about it.
        logger.debug(
          'Failed to store latest cli version to file: $e',
        );
      }
    }

    try {
      return await LocalStorageManager.tryFetchAndDeserializeJsonFile(
        fileName: ResourceManagerConstants.latestVersionFilePath,
        localStoragePath: localStoragePath,
        fromJson: PackageVersionData.fromJson,
      );
    } on ReadException catch (e) {
      deleteFile(e.file);
    } on DeserializationException catch (e) {
      deleteFile(e.file);
    }

    return null;
  }

  static Future<void> storeSettings({
    required final ServerpodCloudSettingsData settings,
    required final String localStoragePath,
  }) async {
    try {
      await LocalStorageManager.storeJsonFile(
        fileName: ResourceManagerConstants.settingsFilePath,
        json: settings.toJson(),
        localStoragePath: localStoragePath,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to store settings.');
    }
  }

  static Future<ServerpodCloudSettingsData?> tryLoadSettings({
    required final String localStoragePath,
  }) async {
    try {
      return await LocalStorageManager.tryFetchAndDeserializeJsonFile(
        fileName: ResourceManagerConstants.settingsFilePath,
        localStoragePath: localStoragePath,
        fromJson: ServerpodCloudSettingsData.fromJson,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to load settings.');
    }
  }
}

abstract class ResourceManagerConstants {
  static const serverpodCloudAuthFilePath = 'serverpod_cloud_auth.json';
  static const latestVersionFilePath = 'latest_cli_version.json';
  static const settingsFilePath = 'settings.json';
}

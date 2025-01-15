import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';

abstract class ResourceManager {
  static Directory get localStorageDirectory => Directory(
      p.join(LocalStorageManager.homeDirectory.path, '.serverpod_cloud'));

  static Future<void> removeServerpodCloudData({
    required final String localStoragePath,
  }) async {
    try {
      await LocalStorageManager.removeFile(
        fileName: ResourceManagerConstants.serverpodCloudDataFilePath,
        localStoragePath: localStoragePath,
      );
    } on DeleteException catch (e) {
      throw Exception(
        'Failed to remove serverpod cloud data. error: ${e.error}',
      );
    }
  }

  static Future<void> storeServerpodCloudData({
    required final ServerpodCloudData cloudData,
    required final String localStoragePath,
  }) async {
    try {
      await LocalStorageManager.storeJsonFile(
        fileName: ResourceManagerConstants.serverpodCloudDataFilePath,
        json: cloudData.toJson(),
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

  static Future<ServerpodCloudData?> tryFetchServerpodCloudData({
    required final String localStoragePath,
    required final CommandLogger logger,
  }) async {
    try {
      return await LocalStorageManager.tryFetchAndDeserializeJsonFile(
        fileName: ResourceManagerConstants.serverpodCloudDataFilePath,
        localStoragePath: localStoragePath,
        fromJson: ServerpodCloudData.fromJson,
      );
    } on ReadException catch (_) {
      logger.error(
          'Could not read file at location ${ResourceManagerConstants.serverpodCloudDataFilePath}.',
          hint:
              'Please check that the Serverpod Cloud CLI has the correct permissions to '
              'read the file. If the problem persists, try deleting the file.');
      return null;
    } on DeserializationException catch (_) {
      return null;
    }
  }

  static Future<void> storeLatestCliVersion({
    required final CommandLogger logger,
    required final PackageVersionData cliVersionData,
    String? localStoragePath,
  }) async {
    localStoragePath ??= localStorageDirectory.path;

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
    localStoragePath ??= localStorageDirectory.path;

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
}

abstract class ResourceManagerConstants {
  static const serverpodCloudDataFilePath = 'serverpod_cloud_data.yaml';
  static const latestVersionFilePath = 'latest_cli_version.json';
}

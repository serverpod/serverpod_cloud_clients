import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
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
    required final Logger logger,
  }) async {
    void deleteFile(final File file) {
      try {
        file.deleteSync();
      } catch (deleteError) {
        logger.warning(
          'Failed to delete stored serverpod cloud data file. Error: $deleteError',
        );
      }
    }

    try {
      return await LocalStorageManager.tryFetchAndDeserializeJsonFile(
        fileName: ResourceManagerConstants.serverpodCloudDataFilePath,
        localStoragePath: localStoragePath,
        fromJson: ServerpodCloudData.fromJson,
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
}

import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  final logger = VoidLogger();
  group('ServerpodCloudData: ', () {
    final testCacheFolderPath = p.join(
      'test_integration',
      const Uuid().v4(),
    );

    tearDown(() {
      final directory = Directory(testCacheFolderPath);
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    test(
        'Given cloud data when doing storage roundtrip then cloud data values are preserved.',
        () async {
      final storedArtefact = ServerpodCloudData('my-token');

      await ResourceManager.storeServerpodCloudData(
        cloudData: storedArtefact,
        localStoragePath: testCacheFolderPath,
      );

      final fetchedArtefact = await ResourceManager.tryFetchServerpodCloudData(
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );

      expect(fetchedArtefact?.token, storedArtefact.token);
    });

    test(
        'Given cloud data on disk when removing cloud data then file is deleted.',
        () async {
      final storedArtefact = ServerpodCloudData('my-token');

      await ResourceManager.storeServerpodCloudData(
        cloudData: storedArtefact,
        localStoragePath: testCacheFolderPath,
      );

      await ResourceManager.removeServerpodCloudData(
        localStoragePath: testCacheFolderPath,
      );

      final serverpodCloudDataFile = File(p.join(
        testCacheFolderPath,
        ResourceManagerConstants.serverpodCloudDataFilePath,
      ));
      expect(serverpodCloudDataFile.existsSync(), isFalse);
    });

    group('Given corrupt cloud data on disk ', () {
      late File file;
      setUp(() async {
        file = File(p.join(testCacheFolderPath,
            ResourceManagerConstants.serverpodCloudDataFilePath));
        file.createSync(recursive: true);
        file.writeAsStringSync(
            'This is corrupted content and :will not be :parsed as json');
      });

      test('when fetching file from disk then null is returned.', () async {
        final cloudData = await ResourceManager.tryFetchServerpodCloudData(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );

        expect(cloudData, isNull);
      });

      test('when fetching from disk then file is deleted.', () async {
        try {
          await ResourceManager.tryFetchServerpodCloudData(
            logger: logger,
            localStoragePath: testCacheFolderPath,
          );
        } catch (_) {}

        expect(file.existsSync(), isFalse);
      });
    });
  });
}

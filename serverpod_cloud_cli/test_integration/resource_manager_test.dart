import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  final commandLogger = CommandLogger(VoidLogger());

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

  group('ServerpodCloudData: ', () {
    test(
        'Given cloud data when doing storage roundtrip then cloud data values are preserved.',
        () async {
      final storedArtefact = ServerpodCloudData('my-token');

      await ResourceManager.storeServerpodCloudData(
        cloudData: storedArtefact,
        localStoragePath: testCacheFolderPath,
      );

      final fetchedArtefact = await ResourceManager.tryFetchServerpodCloudData(
        logger: commandLogger,
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
          logger: commandLogger,
          localStoragePath: testCacheFolderPath,
        );

        expect(cloudData, isNull);
      });
    });

    group('Given valid file path when storing latest cli version', () {
      late DateTime validUntil;
      setUp(() async {
        validUntil = DateTime.now().add(Duration(days: 1));
        await ResourceManager.storeLatestCliVersion(
          cliVersionData: PackageVersionData(Version(1, 2, 3), validUntil),
          localStoragePath: testCacheFolderPath,
          logger: commandLogger,
        );
      });

      test('then is stored with version and valid_until fields', () async {
        final file =
            File(p.join(testCacheFolderPath, 'latest_cli_version.json'));
        expect(file.existsSync(), isTrue);
        expect(
          file.readAsStringSync(),
          '''{
  "version": "1.2.3",
  "valid_until": ${validUntil.millisecondsSinceEpoch}
}''',
        );
      });
    });

    test(
        'Given invalid file path '
        'when storing latest cli version '
        'then fails silently and completes', () async {
      await expectLater(
        ResourceManager.storeLatestCliVersion(
          cliVersionData: PackageVersionData(Version(1, 2, 3), DateTime.now()),
          localStoragePath: '/invalid123/path',
          logger: commandLogger,
        ),
        completes,
      );
    });

    group('Given valid file exists at path ', () {
      late final DateTime validUntil;
      setUp(() {
        validUntil = DateTime.now().add(Duration(days: 1));
        final file =
            File(p.join(testCacheFolderPath, 'latest_cli_version.json'));
        file.createSync(recursive: true);

        file.writeAsStringSync('''{
  "version": "1.2.3",
  "valid_until": ${validUntil.millisecondsSinceEpoch}
}''');
      });

      test(
          'when fetching latest cli version '
          'then returns deserialized object', () async {
        final versionData = await ResourceManager.tryFetchLatestCliVersion(
          localStoragePath: testCacheFolderPath,
          logger: commandLogger,
        );

        expect(versionData, isNotNull);
        expect(versionData!.version, Version(1, 2, 3));
        expect(
          versionData.validUntil.millisecondsSinceEpoch,
          validUntil.millisecondsSinceEpoch,
        );
      });
    });

    group(
        'Given corrupt file exists at path '
        'when fetching latest cli version', () {
      late final Future cliVersionFuture;
      late final File file;
      setUpAll(() {
        file = File(p.join(testCacheFolderPath, 'latest_cli_version.json'));
        file.createSync(recursive: true);

        file.writeAsStringSync('abc123');

        cliVersionFuture = ResourceManager.tryFetchLatestCliVersion(
          localStoragePath: testCacheFolderPath,
          logger: commandLogger,
        );
      });

      test('then returns null', () async {
        await expectLater(cliVersionFuture, completion(isNull));
      });

      test('then deletes file', () async {
        await cliVersionFuture;
        expect(file.existsSync(), isFalse);
      });
    });
  });
}

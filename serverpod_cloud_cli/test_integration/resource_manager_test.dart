import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/scloud_settings_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  final commandLogger = CommandLogger(VoidLogger());

  final testCacheFolderPath = p.join('test_integration', const Uuid().v4());

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
        final storedArtefact = ServerpodCloudAuthData('my-token');

        await ResourceManager.storeServerpodCloudAuthData(
          authData: storedArtefact,
          localStoragePath: testCacheFolderPath,
        );

        final fetchedArtefact =
            await ResourceManager.tryFetchServerpodCloudAuthData(
              logger: commandLogger,
              localStoragePath: testCacheFolderPath,
            );

        expect(fetchedArtefact?.token, storedArtefact.token);
      },
    );

    test(
      'Given cloud data on disk when removing cloud data then file is deleted.',
      () async {
        final storedArtefact = ServerpodCloudAuthData('my-token');

        await ResourceManager.storeServerpodCloudAuthData(
          authData: storedArtefact,
          localStoragePath: testCacheFolderPath,
        );

        await ResourceManager.removeServerpodCloudAuthData(
          localStoragePath: testCacheFolderPath,
        );

        final serverpodCloudDataFile = File(
          p.join(
            testCacheFolderPath,
            ResourceManagerConstants.serverpodCloudAuthFilePath,
          ),
        );
        expect(serverpodCloudDataFile.existsSync(), isFalse);
      },
    );

    group('Given corrupt cloud data on disk ', () {
      late File file;
      setUp(() async {
        file = File(
          p.join(
            testCacheFolderPath,
            ResourceManagerConstants.serverpodCloudAuthFilePath,
          ),
        );
        file.createSync(recursive: true);
        file.writeAsStringSync(
          'This is corrupted content and :will not be :parsed as json',
        );
      });

      test('when fetching file from disk then null is returned.', () async {
        final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
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
        final file = File(
          p.join(testCacheFolderPath, 'latest_cli_version.json'),
        );
        expect(file.existsSync(), isTrue);
        expect(file.readAsStringSync(), '''{
  "version": "1.2.3",
  "valid_until": ${validUntil.millisecondsSinceEpoch}
}''');
      });
    });

    test('Given invalid file path '
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
        final file = File(
          p.join(testCacheFolderPath, 'latest_cli_version.json'),
        );
        file.createSync(recursive: true);

        file.writeAsStringSync('''{
  "version": "1.2.3",
  "valid_until": ${validUntil.millisecondsSinceEpoch}
}''');
      });

      test('when fetching latest cli version '
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

    group('Given corrupt file exists at path '
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

  group('Given settings', () {
    test(
      'with no set values '
      'when doing storage roundtrip then null values are preserved.',
      () async {
        final storedSettings = ServerpodCloudSettingsData();

        await ResourceManager.storeSettings(
          settings: storedSettings,
          localStoragePath: testCacheFolderPath,
        );

        final fetchedSettings = await ResourceManager.tryLoadSettings(
          localStoragePath: testCacheFolderPath,
        );

        expect(fetchedSettings, isNotNull);
        expect(fetchedSettings?.enableAnalytics, isNull);
      },
    );

    test(
      'with a set value '
      'when doing storage roundtrip then settings values are preserved.',
      () async {
        final storedSettings = ServerpodCloudSettingsData()
          ..enableAnalytics = true;

        await ResourceManager.storeSettings(
          settings: storedSettings,
          localStoragePath: testCacheFolderPath,
        );

        final fetchedSettings = await ResourceManager.tryLoadSettings(
          localStoragePath: testCacheFolderPath,
        );

        expect(fetchedSettings, isNotNull);
        expect(fetchedSettings?.enableAnalytics, true);
      },
    );

    test('when storing with invalid file path '
        'then FailureException is thrown', () async {
      final storedSettings = ServerpodCloudSettingsData()
        ..enableAnalytics = true;

      final invalidPath = Platform.isWindows
          ? 'C:\\invalid:path'
          : '/invalid_path';
      expect(
        () => ResourceManager.storeSettings(
          settings: storedSettings,
          localStoragePath: invalidPath,
        ),
        throwsA(isA<FailureException>()),
      );
    });

    test('when storing then file has correct JSON structure', () async {
      final storedSettings = ServerpodCloudSettingsData()
        ..enableAnalytics = false;

      await ResourceManager.storeSettings(
        settings: storedSettings,
        localStoragePath: testCacheFolderPath,
      );

      final file = File(
        p.join(testCacheFolderPath, ResourceManagerConstants.settingsFilePath),
      );
      expect(file.existsSync(), isTrue);
      expect(
        file.readAsStringSync(),
        equals(r'''
{
  "enable_analytics": false
}'''),
      );
    });
  });

  group('Given corrupt settings file on disk ', () {
    late File file;
    setUp(() async {
      file = File(
        p.join(testCacheFolderPath, ResourceManagerConstants.settingsFilePath),
      );
      file.createSync(recursive: true);
      file.writeAsStringSync(
        'This is corrupted content and will not be parsed as json',
      );
    });

    test(
      'when fetching file from disk then FailureException is thrown.',
      () async {
        expect(
          () => ResourceManager.tryLoadSettings(
            localStoragePath: testCacheFolderPath,
          ),
          throwsA(isA<FailureException>()),
        );
      },
    );
  });
}

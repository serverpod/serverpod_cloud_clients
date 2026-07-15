import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/persistent_storage/models/scloud_settings_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/persistent_storage/scloud_settings.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  late String testFolderPath;

  setUp(() async {
    await d.dir('test_integration').create();
    testFolderPath = p.join(d.sandbox, 'test_integration');
  });

  group('Given no settings file exists', () {
    test('when getting enableAnalytics then null is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      final result = await settings.enableAnalytics;

      expect(result, isNull);
    });

    test(
      'when setting enableAnalytics to true then settings file is created',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(true);

        final expected = d.file(
          ResourceManagerConstants.settingsFilePath,
          isNotEmpty,
        );
        await expectLater(expected.validate(testFolderPath), completes);
      },
    );

    test(
      'when setting enableAnalytics to true then value can be retrieved',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(true);
        final result = await settings.enableAnalytics;

        expect(result, isTrue);
      },
    );

    test(
      'when setting enableAnalytics to false then value can be retrieved',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(false);
        final result = await settings.enableAnalytics;

        expect(result, isFalse);
      },
    );
  });

  group('Given settings file exists with null enableAnalytics', () {
    setUp(() async {
      await ResourceManager.storeSettings(
        settings: ServerpodCloudSettingsData(),
        localStoragePath: testFolderPath,
      );
    });

    test('when getting enableAnalytics then null is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      final result = await settings.enableAnalytics;

      expect(result, isNull);
    });

    test(
      'when setting enableAnalytics to true then value is stored and retrieved',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(true);
        final result = await settings.enableAnalytics;

        expect(result, isTrue);
      },
    );
  });

  group('Given settings file exists with enableAnalytics set to true', () {
    setUp(() async {
      final storedSettings = ServerpodCloudSettingsData()
        ..enableAnalytics = true;
      await ResourceManager.storeSettings(
        settings: storedSettings,
        localStoragePath: testFolderPath,
      );
    });

    test('when getting enableAnalytics then true is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      final result = await settings.enableAnalytics;

      expect(result, isTrue);
    });

    test(
      'when setting enableAnalytics to false then value is updated and retrieved',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(false);
        final result = await settings.enableAnalytics;

        expect(result, isFalse);
      },
    );

    test(
      'when setting enableAnalytics to the same value then no write occurs',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);
        final file = File(
          p.join(testFolderPath, ResourceManagerConstants.settingsFilePath),
        );
        final originalModifiedTime = file.lastModifiedSync();

        await settings.setEnableAnalytics(true);

        expect(file.lastModifiedSync(), equals(originalModifiedTime));
      },
    );
  });

  group('Given settings file exists with enableAnalytics set to false', () {
    setUp(() async {
      final storedSettings = ServerpodCloudSettingsData()
        ..enableAnalytics = false;
      await ResourceManager.storeSettings(
        settings: storedSettings,
        localStoragePath: testFolderPath,
      );
    });

    test('when getting enableAnalytics then false is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      final result = await settings.enableAnalytics;

      expect(result, isFalse);
    });

    test(
      'when setting enableAnalytics to true then value is updated and retrieved',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(true);
        final result = await settings.enableAnalytics;

        expect(result, isTrue);
      },
    );

    test(
      'when setting enableAnalytics to the same value then no write occurs',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);
        final file = File(
          p.join(testFolderPath, ResourceManagerConstants.settingsFilePath),
        );
        final originalModifiedTime = file.lastModifiedSync();

        await settings.setEnableAnalytics(false);

        expect(file.lastModifiedSync(), equals(originalModifiedTime));
      },
    );
  });

  group('Given ScloudSettings instance with cached data', () {
    late ScloudSettings settings;

    setUp(() async {
      settings = ScloudSettings(localStoragePath: testFolderPath);
      await settings.setEnableAnalytics(true);
    });

    test(
      'when getting enableAnalytics multiple times then cached value is returned',
      () async {
        final firstGet = await settings.enableAnalytics;
        final secondGet = await settings.enableAnalytics;
        final thirdGet = await settings.enableAnalytics;

        expect(firstGet, isTrue);
        expect(secondGet, isTrue);
        expect(thirdGet, isTrue);
      },
    );

    test('when updating enableAnalytics then cache is updated', () async {
      final initialValue = await settings.enableAnalytics;

      await settings.setEnableAnalytics(false);
      final updatedValue = await settings.enableAnalytics;

      expect(initialValue, isTrue);
      expect(updatedValue, isFalse);
    });
  });

  group('Given no settings file exists for project context', () {
    test('when getting projectContext then null is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      final result = await settings.projectContext;

      expect(result, isNull);
    });

    test('when setting projectContext then settings file is created', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      await settings.setProjectContext('my-project');

      final expected = d.file(
        ResourceManagerConstants.settingsFilePath,
        isNotEmpty,
      );
      await expectLater(expected.validate(testFolderPath), completes);
    });

    test('when setting projectContext then value can be retrieved', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      await settings.setProjectContext('my-project');
      final result = await settings.projectContext;

      expect(result, equals('my-project'));
    });

    test(
      'when clearing projectContext then no settings file is written',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setProjectContext(null);

        final expected = d.nothing(ResourceManagerConstants.settingsFilePath);
        await expectLater(expected.validate(testFolderPath), completes);
      },
    );
  });

  group('Given settings file exists with projectContext set', () {
    setUp(() async {
      final storedSettings = ServerpodCloudSettingsData()
        ..projectContext = 'my-project';
      await ResourceManager.storeSettings(
        settings: storedSettings,
        localStoragePath: testFolderPath,
      );
    });

    test('when getting projectContext then the value is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      final result = await settings.projectContext;

      expect(result, equals('my-project'));
    });

    test('when loading settings synchronously then the value is returned', () {
      final result = ResourceManager.tryLoadSettingsSync(
        localStoragePath: testFolderPath,
      );

      expect(result?.projectContext, equals('my-project'));
    });

    test(
      'when setting projectContext to another value then it is updated',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setProjectContext('other-project');
        final result = await settings.projectContext;

        expect(result, equals('other-project'));
      },
    );

    test('when clearing projectContext then null is returned', () async {
      final settings = ScloudSettings(localStoragePath: testFolderPath);

      await settings.setProjectContext(null);
      final result = await settings.projectContext;

      expect(result, isNull);

      final directLoad = await ResourceManager.tryLoadSettings(
        localStoragePath: testFolderPath,
      );
      expect(directLoad?.projectContext, isNull);
    });

    test(
      'when setting enableAnalytics then projectContext is preserved',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(true);

        final directLoad = await ResourceManager.tryLoadSettings(
          localStoragePath: testFolderPath,
        );
        expect(directLoad?.projectContext, equals('my-project'));
        expect(directLoad?.enableAnalytics, isTrue);
      },
    );
  });

  group('Given no settings file exists for sync loading', () {
    test('when loading settings synchronously then null is returned', () {
      final result = ResourceManager.tryLoadSettingsSync(
        localStoragePath: testFolderPath,
      );

      expect(result, isNull);
    });
  });

  group('Given multiple set operations', () {
    test(
      'when setting different values sequentially then final value is persisted',
      () async {
        final settings = ScloudSettings(localStoragePath: testFolderPath);

        await settings.setEnableAnalytics(true);
        await settings.setEnableAnalytics(false);
        await settings.setEnableAnalytics(true);

        final result = await settings.enableAnalytics;
        expect(result, isTrue);

        final directLoad = await ResourceManager.tryLoadSettings(
          localStoragePath: testFolderPath,
        );
        expect(directLoad?.enableAnalytics, isTrue);
      },
    );
  });

  group('Given settings file on disk', () {
    setUp(() async {
      final storedSettings = ServerpodCloudSettingsData()
        ..enableAnalytics = true;
      await ResourceManager.storeSettings(
        settings: storedSettings,
        localStoragePath: testFolderPath,
      );
    });

    test(
      'when creating new ScloudSettings instance then cached value matches disk',
      () async {
        final firstSettings = ScloudSettings(localStoragePath: testFolderPath);
        final secondSettings = ScloudSettings(localStoragePath: testFolderPath);

        final firstValue = await firstSettings.enableAnalytics;
        final secondValue = await secondSettings.enableAnalytics;

        expect(firstValue, isTrue);
        expect(secondValue, isTrue);
      },
    );

    test(
      'when creating two instances and updating one then both reflect the change',
      () async {
        final firstSettings = ScloudSettings(localStoragePath: testFolderPath);
        final secondSettings = ScloudSettings(localStoragePath: testFolderPath);

        await firstSettings.setEnableAnalytics(false);

        final firstValue = await firstSettings.enableAnalytics;
        final secondValue = await secondSettings.enableAnalytics;

        expect(firstValue, isFalse);
        expect(secondValue, isFalse);
      },
    );
  });
}

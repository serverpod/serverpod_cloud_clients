import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  final logger = CommandLogger(VoidLogger());
  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  tearDown(() async {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });
  group('Given stored cloud data', () {
    late String testKey;
    setUp(() async {
      testKey = 'my-key-${const Uuid().v4()}';
      final cloudData = ServerpodCloudAuthData(testKey);
      await ResourceManager.storeServerpodCloudAuthData(
        authData: cloudData,
        localStoragePath: testCacheFolderPath,
      );
    });

    test('when getting the authentication key then the key is returned.',
        () async {
      final keyManager = CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );

      await expectLater(keyManager.get(), completion(testKey));
    });

    group('when storing a new authentication key', () {
      late String newKey;
      late CliAuthenticationKeyManager keyManager;
      setUp(() async {
        keyManager = CliAuthenticationKeyManager(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );
        newKey = 'new-key-${const Uuid().v4()}';
        await keyManager.put(newKey);
      });

      test('then new key is returned from the `get` method.', () async {
        await expectLater(keyManager.get(), completion(newKey));
      });

      test('then new key is stored on disk.', () async {
        final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
          localStoragePath: testCacheFolderPath,
          logger: logger,
        );

        expect(cloudData?.token, newKey);
      });
    });

    group('when removing the authentication key', () {
      late CliAuthenticationKeyManager keyManager;
      setUp(() async {
        keyManager = CliAuthenticationKeyManager(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );

        await keyManager.remove();
      });

      test('then the key is removed from the key manager.', () async {
        await expectLater(keyManager.get(), completion(isNull));
      });

      test('then key is removed from disk.', () async {
        final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
          localStoragePath: testCacheFolderPath,
          logger: logger,
        );

        expect(cloudData, isNull);
      });
    });
  });

  test(
      'Given no stored cloud data when getting the authentication key then no key is returned.',
      () async {
    final keyManager = CliAuthenticationKeyManager(
      logger: logger,
      localStoragePath: testCacheFolderPath,
    );

    await expectLater(keyManager.get(), completion(isNull));
  });

  group('Given no stored cloud data when storing an authentication key', () {
    late CliAuthenticationKeyManager keyManager;
    late String key;
    setUp(() async {
      keyManager = CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );
      key = 'my-key-${const Uuid().v4()}';
      await keyManager.put(key);
    });

    test('then the key is stored on disk.', () async {
      final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: testCacheFolderPath,
        logger: logger,
      );

      expect(cloudData?.token, key);
    });

    test('then the key can be retrieved from the key manager.', () async {
      await expectLater(keyManager.get(), completion(key));
    });
  });

  test(
      'Given no stored cloud data when removing the authentication key then no exception is thrown',
      () async {
    final keyManager = CliAuthenticationKeyManager(
      logger: logger,
      localStoragePath: testCacheFolderPath,
    );

    await expectLater(keyManager.remove(), completes);
  });

  group('Given cloud data is passed in constructor', () {
    late String testKey;
    late CliAuthenticationKeyManager keyManager;
    setUp(() async {
      testKey = 'my-key-${const Uuid().v4()}';
      final cloudData = ServerpodCloudAuthData(testKey);
      keyManager = CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: testCacheFolderPath,
        cloudDataOverride: cloudData,
      );
    });

    test('when getting the authentication key then the stored key is returned.',
        () async {
      await expectLater(keyManager.get(), completion(testKey));
    });

    test('when getting the authentication key then no key is stored on disk.',
        () async {
      await keyManager.get();
      final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: testCacheFolderPath,
        logger: logger,
      );

      expect(cloudData, isNull);
    });

    test(
        'when storing a new authentication key then the key is stored on disk.',
        () async {
      final newKey = 'new-key-${const Uuid().v4()}';
      await keyManager.put(newKey);

      final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: testCacheFolderPath,
        logger: logger,
      );

      expect(cloudData?.token, newKey);
    });
  });
}

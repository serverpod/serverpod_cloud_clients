import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_user_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  late ClientMock client;
  late CloudCliCommandRunner cli;
  late String settingsDir;

  setUp(() async {
    logger.clear();
    client = ClientMock(authKeyProvider: InMemoryKeyManager.authenticated());
    cli = CloudCliCommandRunner.create(
      logger: logger,
      serviceProvider: CloudCliServiceProvider(
        apiClientFactory: (globalCfg) => client,
      ),
      onAnalyticsEvent: (event, properties, {userAuthId}) {},
      enableAnalyticsForAllEnvs: true,
    );

    await d.dir('settings_dir').create();
    settingsDir = p.join(d.sandbox, 'settings_dir');
  });

  group('Given a logged in user whose stored data has no user auth id', () {
    setUp(() async {
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData('1'),
        localStoragePath: settingsDir,
      );
    });

    group('and the API returns the stored user', () {
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async =>
              UserBuilder().withId(1).withUserAuthId('user-auth-id').build(),
        );
      });

      test('when running a command with analytics'
          ' then the user auth id is stored', () async {
        await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

        expect(_storedUserData(settingsDir)?.userAuthId, 'user-auth-id');
      });

      test('when running a command with analytics'
          ' then the stored cloud user id is kept', () async {
        await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

        expect(_storedUserData(settingsDir)?.id, '1');
      });

      test('when running a command without analytics'
          ' then the user is not fetched', () async {
        await cli.run([
          '--config-dir',
          settingsDir,
          'version',
          '--no-analytics',
        ]);

        verifyNever(() => client.users.readUser());
      });

      test('when running a command without analytics'
          ' then no user auth id is stored', () async {
        await cli.run([
          '--config-dir',
          settingsDir,
          'version',
          '--no-analytics',
        ]);

        expect(_storedUserData(settingsDir)?.userAuthId, isNull);
      });
    });

    group('and the API returns another user', () {
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async =>
              UserBuilder().withId(2).withUserAuthId('user-auth-id').build(),
        );
      });

      test('when running a command with analytics'
          ' then no user auth id is stored', () async {
        await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

        expect(_storedUserData(settingsDir)?.userAuthId, isNull);
      });
    });

    group('and fetching the user never completes', () {
      setUp(() {
        when(
          () => client.users.readUser(),
        ).thenAnswer((_) => Completer<User>().future);
      });

      test('when running a command with analytics'
          ' then the command completes', () async {
        await expectLater(
          cli.run(['--config-dir', settingsDir, 'version', '--analytics']),
          completes,
        );
      });
    });

    group('and fetching the user fails', () {
      setUp(() {
        when(
          () => client.users.readUser(),
        ).thenThrow(Exception('Connection refused'));
      });

      test('when running a command with analytics'
          ' then the command completes', () async {
        await expectLater(
          cli.run(['--config-dir', settingsDir, 'version', '--analytics']),
          completes,
        );
      });

      test('when running a command with analytics'
          ' then no user auth id is stored', () async {
        await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

        expect(_storedUserData(settingsDir)?.userAuthId, isNull);
      });
    });
  });

  group('Given stored user data without a user auth id and no login', () {
    setUp(() async {
      client = ClientMock();
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData('1'),
        localStoragePath: settingsDir,
      );
    });

    test('when running a command with analytics'
        ' then the user is not fetched', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

      verifyNever(() => client.users.readUser());
    });
  });

  group('Given a logged in user with no stored user data', () {
    test('when running a command with analytics'
        ' then the user is not fetched', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

      verifyNever(() => client.users.readUser());
    });
  });

  group('Given a logged in user whose stored data has a user auth id', () {
    setUp(() async {
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData('1', userAuthId: 'user-auth-id'),
        localStoragePath: settingsDir,
      );
    });

    test('when running a command with analytics'
        ' then the user is not fetched', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

      verifyNever(() => client.users.readUser());
    });
  });
}

ServerpodCloudUserData? _storedUserData(String settingsDir) =>
    ResourceManager.tryFetchServerpodCloudUserDataSync(
      localStoragePath: settingsDir,
    );

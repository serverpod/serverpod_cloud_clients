import 'dart:async';
import 'dart:io';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );

  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  final testCacheFolderPath = p.join('test_integration', const Uuid().v4());

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
    reset(client.authWithAuth);
  });

  test(
    'Given logout command when instantiated then does not require login',
    () {
      expect(CloudLogoutCommand(logger: logger).requireLogin, isFalse);
    },
  );

  group(
    'Given stored credentials and logoutDevice endpoint method returning true',
    () {
      setUp(() async {
        await ResourceManager.storeServerpodCloudAuthData(
          authData: ServerpodCloudAuthData('my-token'),
          localStoragePath: testCacheFolderPath,
        );

        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenAnswer((final _) async => true);
      });

      group('when logging out the current session', () {
        late Future runLogoutCommand;
        setUp(() {
          runLogoutCommand = cli.run([
            'auth',
            'logout',
            '--config-dir',
            testCacheFolderPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(runLogoutCommand, completes);
        });

        test('then the stored credentials are removed', () async {
          await runLogoutCommand;

          final cloudData =
              await ResourceManager.tryFetchServerpodCloudAuthData(
                localStoragePath: testCacheFolderPath,
                logger: logger,
              );

          expect(cloudData, isNull);
        });

        test('then logoutDevice is called', () async {
          await runLogoutCommand;

          verify(
            () => client.authWithAuth.logoutDevice(authTokenId: null),
          ).called(1);
        });

        test('then a "logged out" message is logged', () async {
          await runLogoutCommand;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully logged out from Serverpod cloud.',
            ),
          );
        });
      });

      group('when logging out a specific token', () {
        late Future runLogoutCommand;
        setUp(() {
          runLogoutCommand = cli.run([
            'auth',
            'logout',
            '--token-id',
            'my-token',
            '--config-dir',
            testCacheFolderPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(runLogoutCommand, completes);
        });

        test('then the stored credentials are removed', () async {
          await runLogoutCommand;

          final cloudData =
              await ResourceManager.tryFetchServerpodCloudAuthData(
                localStoragePath: testCacheFolderPath,
                logger: logger,
              );

          expect(cloudData, isNull);
        });

        test('then logoutDevice is called with token ID', () async {
          await runLogoutCommand;

          verify(
            () => client.authWithAuth.logoutDevice(authTokenId: 'my-token'),
          ).called(1);
        });

        test('then a "logged out" message is logged', () async {
          await runLogoutCommand;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully logged out from Serverpod cloud.',
            ),
          );
        });
      });
    },
  );

  group(
    'Given stored credentials and logoutDevice endpoint method returning false',
    () {
      setUp(() async {
        await ResourceManager.storeServerpodCloudAuthData(
          authData: ServerpodCloudAuthData('my-token'),
          localStoragePath: testCacheFolderPath,
        );

        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenAnswer((final _) async => false);
      });

      group('when logging out the current session', () {
        late Future runLogoutCommand;
        setUp(() {
          runLogoutCommand = cli.run([
            'auth',
            'logout',
            '--config-dir',
            testCacheFolderPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(runLogoutCommand, completes);
        });

        test('then the stored credentials are removed', () async {
          await runLogoutCommand;

          final cloudData =
              await ResourceManager.tryFetchServerpodCloudAuthData(
                localStoragePath: testCacheFolderPath,
                logger: logger,
              );

          expect(cloudData, isNull);
        });

        test('then logoutDevice is called', () async {
          await runLogoutCommand;

          verify(
            () => client.authWithAuth.logoutDevice(authTokenId: null),
          ).called(1);
        });

        test('then a "logged out" message is logged', () async {
          await runLogoutCommand;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully logged out from Serverpod cloud.',
            ),
          );
        });
      });

      group('when logging out a specific token', () {
        late Future runLogoutCommand;
        setUp(() {
          runLogoutCommand = cli.run([
            'auth',
            'logout',
            '--token-id',
            'my-token',
            '--config-dir',
            testCacheFolderPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(runLogoutCommand, completes);
        });

        test('then the stored credentials are not removed', () async {
          await runLogoutCommand;

          final cloudData =
              await ResourceManager.tryFetchServerpodCloudAuthData(
                localStoragePath: testCacheFolderPath,
                logger: logger,
              );

          expect(cloudData, isNotNull);
        });

        test('then logoutDevice is called with token ID', () async {
          await runLogoutCommand;

          verify(
            () => client.authWithAuth.logoutDevice(authTokenId: 'my-token'),
          ).called(1);
        });

        test('then a "logged out" message is logged', () async {
          await runLogoutCommand;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully logged out the selected sessions.',
            ),
          );
        });
      });
    },
  );

  group(
    'Given stored credentials and succeeding logoutAll endpoint method',
    () {
      setUp(() async {
        await ResourceManager.storeServerpodCloudAuthData(
          authData: ServerpodCloudAuthData('my-token'),
          localStoragePath: testCacheFolderPath,
        );

        when(
          () => client.authWithAuth.logoutAll(),
        ).thenAnswer((final _) async {});
      });

      group('when logging out all sessions', () {
        late Future runLogoutCommand;
        setUp(() {
          runLogoutCommand = cli.run([
            'auth',
            'logout',
            '--all',
            '--config-dir',
            testCacheFolderPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(runLogoutCommand, completes);
        });

        test('then the stored credentials are removed', () async {
          await runLogoutCommand;

          final cloudData =
              await ResourceManager.tryFetchServerpodCloudAuthData(
                localStoragePath: testCacheFolderPath,
                logger: logger,
              );

          expect(cloudData, isNull);
        });

        test('then logoutAll is called', () async {
          await runLogoutCommand;

          verify(() => client.authWithAuth.logoutAll()).called(1);
        });

        test('then a "logged out" message is logged', () async {
          await runLogoutCommand;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully logged out from Serverpod cloud.',
            ),
          );
        });
      });
    },
  );

  group(
    'Given stored credentials and failing logoutDevice endpoint method',
    () {
      setUp(() async {
        await ResourceManager.storeServerpodCloudAuthData(
          authData: ServerpodCloudAuthData('my-token'),
          localStoragePath: testCacheFolderPath,
        );

        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenThrow(Exception('Server error'));
      });

      group('when logging out', () {
        late Future runLogoutCommand;
        setUp(() {
          runLogoutCommand = cli.run([
            'auth',
            'logout',
            '--config-dir',
            testCacheFolderPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(runLogoutCommand, completes);
        });

        test('then the stored credentials are removed', () async {
          await runLogoutCommand;

          final cloudData =
              await ResourceManager.tryFetchServerpodCloudAuthData(
                localStoragePath: testCacheFolderPath,
                logger: logger,
              );

          expect(cloudData, isNull);
        });

        test('then logoutDevice is called', () async {
          await runLogoutCommand;

          verify(
            () => client.authWithAuth.logoutDevice(authTokenId: null),
          ).called(1);
        });

        test('then a "logged out" message is logged', () async {
          await runLogoutCommand;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully logged out from Serverpod cloud.',
            ),
          );
        });
      });
    },
  );

  test(
    'Given no stored credentials when logging out then the command completes with no stored credentials log.',
    () async {
      final runLogoutCommand = cli.run([
        'auth',
        'logout',
        '--config-dir',
        testCacheFolderPath,
      ]);

      await expectLater(runLogoutCommand, completes);

      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first,
        equalsInfoCall(message: 'No stored Serverpod Cloud credentials found.'),
      );
    },
  );
}

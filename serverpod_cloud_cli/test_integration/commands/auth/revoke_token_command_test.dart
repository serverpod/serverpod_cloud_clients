import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show NotFoundException;
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_user_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

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

  late String testConfigDirPath;

  setUp(() async {
    await d.dir('config_dir').create();
    testConfigDirPath = p.join(d.sandbox, 'config_dir');
  });

  tearDown(() {
    logger.clear();
    reset(client.authWithAuth);
  });

  test(
    'Given auth revoke-token command when instantiated then requires login',
    () {
      expect(CloudRevokeTokenCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given stored credentials', () {
    setUp(() async {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData('my-token'),
        localStoragePath: testConfigDirPath,
      );
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData('test-cloud-user-id'),
        localStoragePath: testConfigDirPath,
      );
    });

    group('when revoking a token that is not the current session', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenAnswer((final _) async => false);

        commandResult = cli.run([
          'auth',
          'revoke-token',
          'other-token',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the stored credentials are not removed', () async {
        await commandResult;

        final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
          localStoragePath: testConfigDirPath,
          logger: logger,
        );

        expect(cloudData, isNotNull);
      });

      test('then logoutDevice is called with the token ID', () async {
        await commandResult;

        verify(
          () => client.authWithAuth.logoutDevice(authTokenId: 'other-token'),
        ).called(1);
      });

      test('then a success message is logged', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully logged out the selected sessions.',
          ),
        );
      });
    });

    group('when revoking the current session token', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenAnswer((final _) async => true);

        commandResult = cli.run([
          'auth',
          'revoke-token',
          'my-token',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the stored credentials are removed', () async {
        await commandResult;

        final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
          localStoragePath: testConfigDirPath,
          logger: logger,
        );

        expect(cloudData, isNull);
      });

      test('then the stored cloud user data is removed', () async {
        await commandResult;

        final cloudUserData =
            ResourceManager.tryFetchServerpodCloudUserDataSync(
              localStoragePath: testConfigDirPath,
            );

        expect(cloudUserData, isNull);
      });

      test('then logoutDevice is called with the token ID', () async {
        await commandResult;

        verify(
          () => client.authWithAuth.logoutDevice(authTokenId: 'my-token'),
        ).called(1);
      });

      test('then a logged out message is logged', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully logged out from Serverpod cloud.',
          ),
        );
      });
    });

    group('when revoking a token that does not exist', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenThrow(NotFoundException(message: 'Invalid auth token ID'));

        commandResult = cli.run([
          'auth',
          'revoke-token',
          'missing-token',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        await commandResult.catchError((final _) {});

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(message: 'Invalid auth token ID'),
        );
      });

      test('then the stored credentials are not removed', () async {
        await commandResult.catchError((final _) {});

        final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
          localStoragePath: testConfigDirPath,
          logger: logger,
        );

        expect(cloudData, isNotNull);
      });
    });

    group('when the revoke request fails', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.authWithAuth.logoutDevice(
            authTokenId: any(named: 'authTokenId'),
          ),
        ).thenThrow(Exception('Server error'));

        commandResult = cli.run([
          'auth',
          'revoke-token',
          'my-token',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        await commandResult.catchError((final _) {});

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'Failed to revoke token',
            exception: Exception('Server error'),
          ),
        );
      });
    });
  });
}

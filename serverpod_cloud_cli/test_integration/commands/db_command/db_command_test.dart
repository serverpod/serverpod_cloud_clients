import 'dart:async';

import 'package:cli_tools/cli_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:test/test.dart';

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

  tearDown(() async {
    logger.clear();
  });
  const projectId = 'projectId';

  test('Given db connection command when instantiated then requires login', () {
    expect(
      CloudDbConnectionDetailsCommand(logger: logger).requireLogin,
      isTrue,
    );
  });

  test(
    'Given db user create command when instantiated then requires login',
    () {
      expect(CloudDbUserCreateCommand(logger: logger).requireLogin, isTrue);
    },
  );

  test(
    'Given db user reset-password command when instantiated then requires login',
    () {
      expect(
        CloudDbUserResetPasswordCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  test('Given db wipe command when instantiated then requires login', () {
    expect(CloudDbWipeCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing db connection', () {
      setUpAll(() {
        when(
          () => client.database.getConnectionDetails(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['db', 'connection', '--project', projectId]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message:
                'The credentials for this session seem to no longer be valid.',
          ),
        );
      });
    });

    group('when executing db user create', () {
      setUpAll(() {
        when(
          () => client.database.createSuperUser(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: 'wernher',
          ),
        ).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'user',
          'create',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message:
                'The credentials for this session seem to no longer be valid.',
          ),
        );
      });
    });

    group('when executing db user reset-password', () {
      setUpAll(() {
        when(
          () => client.database.resetDatabasePassword(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: 'wernher',
          ),
        ).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'user',
          'reset-password',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message:
                'The credentials for this session seem to no longer be valid.',
          ),
        );
      });
    });

    group('when executing db wipe', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'wipe',
          '--project',
          projectId,
          '--yes',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message:
                'The credentials for this session seem to no longer be valid.',
          ),
        );
      });
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    group('when executing db connection', () {
      final connection = DatabaseConnection(
        host: 'localhost',
        port: 5432,
        name: 'default',
        user: 'wernher',
        requiresSsl: false,
      );

      setUpAll(() {
        when(
          () => client.database.getConnectionDetails(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value(connection));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['db', 'connection', '--project', projectId]);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the connection details', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.single.message.split('\n'),
          containsAllInOrder([
            contains('Connection details:'),
            contains('Host: ${connection.host}'),
            contains('Port: ${connection.port}'),
            contains('Database: ${connection.name}'),
          ]),
        );
        expect(
          logger.successCalls.single.followUp!.split('\n'),
          containsAllInOrder([
            contains(
              'This psql command can be used to connect to the database (it will prompt for the password):',
            ),
            contains(
              'psql "postgresql://${connection.host}/${connection.name}?sslmode=${connection.requiresSsl ? 'require' : 'disable'}" --user <username>',
            ),
          ]),
        );
      });
    });

    group('when executing db user create', () {
      const password = 'von Braun';

      setUpAll(() {
        when(
          () => client.database.createSuperUser(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: 'wernher',
          ),
        ).thenAnswer((final _) async => Future.value(password));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'user',
          'create',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the password', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(logger.successCalls.single.message, '''
DB superuser created. The password is only shown this once:
$password''');
      });
    });

    group('when executing db user reset-password', () {
      const password = 'von Braun';

      setUpAll(() {
        when(
          () => client.database.resetDatabasePassword(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: 'wernher',
          ),
        ).thenAnswer((final _) async => Future.value(password));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'user',
          'reset-password',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the password', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(logger.successCalls.single.message, '''
DB password is reset. The new password is only shown this once:
$password''');
      });
    });

    group('when executing db wipe with --yes', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'wipe',
          '--project',
          projectId,
          '--yes',
        ]);
      });

      tearDown(() {
        // Reset mock call count between tests in this group
        clearInteractions(client.database);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.single.message,
          contains('Database wiped successfully.'),
        );
        expect(
          logger.infoCalls.single.message,
          contains('Redeploy is needed, run: scloud deploy'),
        );
      });

      test('then calls wipeDatabase on client', () async {
        await commandResult;

        verify(
          () => client.database.wipeDatabase(cloudCapsuleId: projectId),
        ).called(1);
      });
    });

    group('when executing db wipe without --yes', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value());
      });

      tearDownAll(() {
        reset(client.database);
      });

      group('and user confirms', () {
        late Future commandResult;
        setUp(() {
          logger.answerNextConfirmWith(true);
          commandResult = cli.run(['db', 'wipe', '--project', projectId]);
        });

        tearDown(() {
          // Reset mock call count between tests in this group
          clearInteractions(client.database);
        });

        test('then succeeds', () async {
          await expectLater(commandResult, completes);
        });

        test('then prompts for confirmation', () async {
          await commandResult;

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first.message,
            contains('Do you want to proceed?'),
          );
        });

        test('then calls wipeDatabase on client', () async {
          await commandResult;

          verify(
            () => client.database.wipeDatabase(cloudCapsuleId: projectId),
          ).called(1);
        });
      });

      group('and user declines', () {
        late Future commandResult;
        setUp(() {
          logger.answerNextConfirmWith(false);
          commandResult = cli.run(['db', 'wipe', '--project', projectId]);
        });

        test('then succeeds without wiping', () async {
          await expectLater(commandResult, completes);
        });

        test('then prompts for confirmation', () async {
          await commandResult;

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first.message,
            contains('Do you want to proceed?'),
          );
        });

        test('then does not call wipeDatabase on client', () async {
          await commandResult;

          verifyNever(
            () => client.database.wipeDatabase(cloudCapsuleId: projectId),
          );
        });

        test('then logs cancellation message', () async {
          await commandResult;

          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.any(
              (final call) => call.message.contains('Database wipe cancelled.'),
            ),
            isTrue,
          );
        });
      });
    });
  });
}

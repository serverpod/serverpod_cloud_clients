import 'dart:async';
import 'dart:convert';

import 'package:cli_tools/cli_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

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
      apiClientFactory: (globalCfg) => client,
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

  test('Given db user list command when instantiated then requires login', () {
    expect(CloudDbUserListCommand(logger: logger).requireLogin, isTrue);
  });

  test(
    'Given db user delete command when instantiated then requires login',
    () {
      expect(CloudDbUserDeleteCommand(logger: logger).requireLogin, isTrue);
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

    group('when executing db user list', () {
      setUpAll(() {
        when(
          () => client.database.listDatabaseUsers(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['db', 'user', 'list', '--project', projectId]);
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

    group('when executing db user delete', () {
      setUpAll(() {
        when(
          () => client.database.deleteDatabaseUser(
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
          'delete',
          'wernher',
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
        ).thenAnswer((_) async => Future.value(connection));
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
        ).thenAnswer((_) async => Future.value(password));
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
        ).thenAnswer((_) async => Future.value(password));
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

    group('when executing db user list', () {
      group('and users exist', () {
        setUpAll(() {
          when(
            () => client.database.listDatabaseUsers(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer(
            (_) async => [
              DatabaseUserBuilder().withUsername('wernher').build(),
              DatabaseUserBuilder()
                  .withUsername('valentina')
                  .withCreatedAt(DateTime.utc(2026, 2, 1, 8, 0))
                  .build(),
            ],
          );
        });

        tearDownAll(() {
          reset(client.database);
        });

        test('then outputs a table with the users', () async {
          await cli.run(['db', 'user', 'list', '--project', projectId]);

          expect(
            logger.lineCalls.map((c) => c.line),
            containsAllInOrder([
              allOf(
                contains('User'),
                contains('Created'),
                contains('Last reset'),
              ),
              contains('wernher'),
              contains('valentina'),
            ]),
          );
        });

        test('then emits a JSON array with the users', () async {
          await cli.run([
            'db',
            'user',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);

          expect(logger.lineCalls, isEmpty);
          expect(logger.rawCalls, hasLength(1));
          final payload = jsonDecode(logger.rawCalls.single.content) as List;
          expect(payload, hasLength(2));
          expect((payload[0] as Map)['username'], 'wernher');
          expect((payload[1] as Map)['username'], 'valentina');
          expect((payload[1] as Map)['createdAt'], '2026-02-01T08:00:00.000Z');
        });

        test('then emits a YAML list with the users', () async {
          await cli.run([
            'db',
            'user',
            'list',
            '--project',
            projectId,
            '--format',
            'yaml',
          ]);

          expect(logger.lineCalls, isEmpty);
          expect(logger.rawCalls, hasLength(1));
          final payload = yamlDecode(logger.rawCalls.single.content) as List;
          expect(payload, hasLength(2));
          expect((payload[0] as Map)['username'], 'wernher');
          expect((payload[1] as Map)['username'], 'valentina');
        });
      });

      group('and no users exist', () {
        setUpAll(() {
          when(
            () => client.database.listDatabaseUsers(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => []);
        });

        tearDownAll(() {
          reset(client.database);
        });

        test('then informs the user and suggests creating one', () async {
          await cli.run(['db', 'user', 'list', '--project', projectId]);

          expect(logger.lineCalls, isEmpty);
          expect(
            logger.infoCalls.any(
              (c) => c.message.contains(
                'No database users found for project "$projectId".',
              ),
            ),
            isTrue,
          );
          expect(
            logger.terminalCommandCalls.any(
              (c) => c.command.contains('scloud db user create'),
            ),
            isTrue,
          );
        });

        test('then emits an empty JSON array', () async {
          await cli.run([
            'db',
            'user',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);

          expect(logger.infoCalls, isEmpty);
          expect(logger.rawCalls, hasLength(1));
          expect(jsonDecode(logger.rawCalls.single.content), isEmpty);
        });
      });
    });

    group('when executing db user list and the database is not found', () {
      setUpAll(() {
        when(
          () => client.database.listDatabaseUsers(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(
          NotFoundException(message: 'Database not found for $projectId'),
        );
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['db', 'user', 'list', '--project', projectId]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs the server message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.first,
          equalsErrorCall(message: 'Database not found for $projectId'),
        );
      });
    });

    group('when executing db user delete', () {
      setUpAll(() {
        when(
          () => client.database.deleteDatabaseUser(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: any(named: 'username'),
          ),
        ).thenAnswer((_) async {});
      });

      tearDownAll(() {
        reset(client.database);
      });

      tearDown(() {
        clearInteractions(client.database);
      });

      test('then deletes with --yes without prompting', () async {
        await cli.run([
          'db',
          'user',
          'delete',
          'wernher',
          '--project',
          projectId,
          '--yes',
        ]);

        expect(logger.confirmCalls, isEmpty);
        verify(
          () => client.database.deleteDatabaseUser(
            cloudCapsuleId: projectId,
            username: 'wernher',
          ),
        ).called(1);
        expect(
          logger.successCalls.single.message,
          'Database user "wernher" deleted.',
        );
      });

      test('then deletes when the user confirms', () async {
        logger.answerNextConfirmWith(true);
        await cli.run([
          'db',
          'user',
          'delete',
          'wernher',
          '--project',
          projectId,
        ]);

        expect(
          logger.confirmCalls.single.message,
          contains('Permanently delete database user "wernher"'),
        );
        verify(
          () => client.database.deleteDatabaseUser(
            cloudCapsuleId: projectId,
            username: 'wernher',
          ),
        ).called(1);
      });

      test('then does not delete when the user declines', () async {
        logger.answerNextConfirmWith(false);
        final result = cli.run([
          'db',
          'user',
          'delete',
          'wernher',
          '--project',
          projectId,
        ]);

        await expectLater(result, throwsA(isA<ExitException>()));
        verifyNever(
          () => client.database.deleteDatabaseUser(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: any(named: 'username'),
          ),
        );
      });

      test('then emits a JSON object with the username', () async {
        await cli.run([
          'db',
          'user',
          'delete',
          'wernher',
          '--project',
          projectId,
          '--yes',
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['username'], 'wernher');
      });

      test('then emits a YAML object with the username', () async {
        await cli.run([
          'db',
          'user',
          'delete',
          'wernher',
          '--project',
          projectId,
          '--yes',
          '--format',
          'yaml',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['username'], 'wernher');
      });
    });

    group('when executing db user delete for the owner user', () {
      setUpAll(() {
        when(
          () => client.database.deleteDatabaseUser(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: 'owner',
          ),
        ).thenThrow(InvalidValueException(message: 'Invalid username owner'));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'user',
          'delete',
          'owner',
          '--project',
          projectId,
          '--yes',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs the server message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.first,
          equalsErrorCall(message: 'Invalid username owner'),
        );
      });
    });

    group('when executing db user delete for an unknown user', () {
      setUpAll(() {
        when(
          () => client.database.deleteDatabaseUser(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            username: 'ghost',
          ),
        ).thenThrow(NotFoundException(message: 'User ghost not found'));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'user',
          'delete',
          'ghost',
          '--project',
          projectId,
          '--yes',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs the server message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.first,
          equalsErrorCall(message: 'User ghost not found'),
        );
      });
    });

    group('when executing db wipe with --yes', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());
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

    group('when executing db wipe with --yes and --format json', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());
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
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON object with the project id', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        expect(jsonDecode(logger.rawCalls.single.content), {
          'projectId': projectId,
        });
      });
    });

    group('when executing db wipe with --yes and --format yaml', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());
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
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML object with the project id', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['projectId'], projectId);
      });
    });

    group('when executing db wipe without --yes', () {
      setUpAll(() {
        when(
          () => client.database.wipeDatabase(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());
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
              (call) => call.message.contains('Database wipe cancelled.'),
            ),
            isTrue,
          );
        });
      });
    });
  });
}

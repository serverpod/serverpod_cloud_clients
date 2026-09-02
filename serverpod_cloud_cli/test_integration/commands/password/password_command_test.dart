import 'dart:async';
import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

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

  test('Given password command when instantiated then requires login', () {
    expect(CloudPasswordCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing password set', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.upsert(
            secrets: any(named: 'secrets'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'password',
          'set',
          'database',
          'value',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });
    });

    group('when executing password unset', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.delete(
            key: any(named: 'key'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'password',
          'unset',
          'database',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });
    });

    group('when executing password list', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());
        when(
          () => client.secrets.listManaged(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run(['password', 'list', '--project', projectId]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });
    });

    group('when executing password list with --format json', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());
        when(
          () => client.secrets.listManaged(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'password',
          'list',
          '--project',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then emits a JSON error for the unauthorized exception', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, isEmpty);
        expect(logger.errorCalls, isNotEmpty);
        final payload = jsonDecode(logger.errorCalls.single.message);
        expect(payload, contains('Failed to list passwords'));
        expect(payload, contains('Unauthorized'));
      });
    });

    group('when executing password list with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());
        when(
          () => client.secrets.listManaged(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'password',
          'list',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then emits a YAML error for the unauthorized exception', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, isEmpty);
        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.single.message,
          contains('Failed to list passwords'),
        );
        expect(logger.errorCalls.single.message, contains('Unauthorized'));
      });
    });
  });

  group('Given authenticated', () {
    group('when executing password set', () {
      group('with value arg', () {
        test('then command completes successfully', () async {
          reset(client);
          when(
            () => client.secrets.upsert(
              secrets: any(named: 'secrets'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          final commandResult = cli.run([
            'password',
            'set',
            'database',
            'value',
            '--project',
            projectId,
          ]);

          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          reset(client);
          when(
            () => client.secrets.upsert(
              secrets: any(named: 'secrets'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          final commandResult = cli.run([
            'password',
            'set',
            'database',
            'value',
            '--project',
            projectId,
          ]);

          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(message: 'Successfully set password "database".'),
          );
          expect(
            logger.terminalCommandCalls.single,
            equalsTerminalCommandCall(
              command: 'scloud deploy',
              message:
                  'The changes will not take effect until your server is '
                  're-deployed.',
            ),
          );
        });
      });

      group('with value file arg', () {
        test('then command completes successfully', () async {
          reset(client);
          when(
            () => client.secrets.upsert(
              secrets: any(named: 'secrets'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          await d.file('value.txt', 'password-value').create();

          final commandResult = cli.run([
            'password',
            'set',
            'database',
            '--from-file',
            p.join(d.sandbox, 'value.txt'),
            '--project',
            projectId,
          ]);

          await expectLater(commandResult, completes);
        });

        test('when file does not exist then throws a UsageException', () async {
          final commandResult = cli.run([
            'password',
            'set',
            'database',
            '--from-file',
            p.join(d.sandbox, 'non-existent.txt'),
            '--project',
            projectId,
          ]);

          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (e) => e.message,
                'message',
                contains('Invalid value for option `from-file`'),
              ),
            ),
          );
        });
      });

      group('with both value arg and value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'password-value').create();

          commandResult = cli.run([
            'password',
            'set',
            'database',
            'value',
            '--from-file',
            p.join(d.sandbox, 'value.txt'),
            '--project',
            projectId,
          ]);
        });

        test('then command throws UsageException', () async {
          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (e) => e.message,
                'message',
                equals(
                  'These options are mutually exclusive: from-file, value.',
                ),
              ),
            ),
          );
        });
      });

      group('with neither value arg nor value file arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
            'set',
            'database',
            '--project',
            projectId,
          ]);
        });

        test('then command throws UsageException', () async {
          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (e) => e.message,
                'message',
                equals(
                  'Option group Value requires one of the options to be provided.',
                ),
              ),
            ),
          );
        });
      });

      group('with serviceSecret and valid length', () {
        late Future commandResult;

        setUp(() async {
          reset(client);
          when(
            () => client.secrets.upsert(
              secrets: any(named: 'secrets'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          commandResult = cli.run([
            'password',
            'set',
            'serviceSecret',
            'a' * 20,
            '--project',
            projectId,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });
      });

      group('with serviceSecret and invalid length', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
            'set',
            'serviceSecret',
            'a' * 19,
            '--project',
            projectId,
          ]);
        });

        test('then throws ErrorExitException', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs validation error', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'Password "serviceSecret": Password must be at least 20 characters long.',
            ),
          );
        });
      });

      group('with serviceSecret and invalid length and --format json', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
            'set',
            'serviceSecret',
            'a' * 19,
            '--project',
            projectId,
            '--format',
            'json',
          ]);
        });

        test('then throws ErrorExitException', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then emits a JSON error for the validation failure', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.lineCalls, isEmpty);
          expect(logger.rawCalls, isEmpty);
          expect(logger.errorCalls, isNotEmpty);
          final payload = jsonDecode(logger.errorCalls.single.message);
          expect(
            payload,
            contains(
              'Password "serviceSecret": Password must be at least 20 characters long.',
            ),
          );
        });
      });

      group('with serviceSecret and invalid length and --format yaml', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
            'set',
            'serviceSecret',
            'a' * 19,
            '--project',
            projectId,
            '--format',
            'yaml',
          ]);
        });

        test('then throws ErrorExitException', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then emits a YAML error for the validation failure', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.lineCalls, isEmpty);
          expect(logger.rawCalls, isEmpty);
          expect(logger.errorCalls, isNotEmpty);
          final payload = yamlDecode(logger.errorCalls.single.message);
          expect(
            payload,
            contains(
              'Password "serviceSecret": Password must be at least 20 characters long.',
            ),
          );
        });
      });

      group('with jwtRefreshTokenHashPepper and valid length', () {
        late Future commandResult;

        setUp(() async {
          reset(client);
          when(
            () => client.secrets.upsert(
              secrets: any(named: 'secrets'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          commandResult = cli.run([
            'password',
            'set',
            'jwtRefreshTokenHashPepper',
            'a' * 10,
            '--project',
            projectId,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });
      });

      group('with jwtRefreshTokenHashPepper and invalid length', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
            'set',
            'jwtRefreshTokenHashPepper',
            'a' * 9,
            '--project',
            projectId,
          ]);
        });

        test('then throws ErrorExitException', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs validation error', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'Password "jwtRefreshTokenHashPepper": Password must be at least 10 characters long.',
            ),
          );
        });
      });
    });

    group('when executing password set with --format json', () {
      late Future commandResult;

      setUp(() async {
        reset(client);
        when(
          () => client.secrets.upsert(
            secrets: any(named: 'secrets'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());

        commandResult = cli.run([
          'password',
          'set',
          'database',
          'value',
          '--project',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON object with the password name', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'name': 'database',
        });
      });
    });

    group('when executing password set with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        reset(client);
        when(
          () => client.secrets.upsert(
            secrets: any(named: 'secrets'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());

        commandResult = cli.run([
          'password',
          'set',
          'database',
          'value',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML object with the password name', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['name'], 'database');
      });
    });

    group('when executing password unset', () {
      group('and confirming prompt', () {
        test('then logs confirm message and calls delete correctly', () async {
          reset(client);
          when(
            () => client.secrets.delete(
              key: any(named: 'key'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          logger.answerNextConfirmWith(true);
          final commandResult = cli.run([
            'password',
            'unset',
            'database',
            '--project',
            projectId,
          ]);

          await expectLater(commandResult, completes);

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to unset the password "database"?',
              defaultValue: false,
            ),
          );
        });

        test('then logs success message', () async {
          reset(client);
          when(
            () => client.secrets.delete(
              key: any(named: 'key'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => Future.value());

          logger.answerNextConfirmWith(true);
          final commandResult = cli.run([
            'password',
            'unset',
            'database',
            '--project',
            projectId,
          ]);

          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully unset password "database".',
            ),
          );
          expect(
            logger.terminalCommandCalls.single,
            equalsTerminalCommandCall(
              command: 'scloud deploy',
              message:
                  'The changes will not take effect until your server is '
                  're-deployed.',
            ),
          );
        });
      });

      group('and rejecting prompt', () {
        late Future commandResult;

        setUp(() async {
          logger.answerNextConfirmWith(false);
          commandResult = cli.run([
            'password',
            'unset',
            'database',
            '--project',
            projectId,
          ]);
        });

        test('then throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs no success message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.successCalls, isEmpty);
        });
      });
    });

    group('when executing password unset with --format json', () {
      late Future commandResult;

      setUp(() async {
        reset(client);
        when(
          () => client.secrets.delete(
            key: any(named: 'key'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'password',
          'unset',
          'database',
          '--project',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<Exception>()));
      });

      test('then logs no confirm message', () async {
        await commandResult.catchError((error) => null);

        expect(logger.confirmCalls, isEmpty);
      });
    });

    group('when executing password unset with --yes and --format json', () {
      late Future commandResult;

      setUp(() async {
        reset(client);
        when(
          () => client.secrets.delete(
            key: any(named: 'key'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'password',
          'unset',
          'database',
          '--project',
          projectId,
          '--format',
          'json',
          '--yes',
        ]);
      });

      test('then emits a JSON object with the password name', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'name': 'database',
        });
      });

      test('then logs no confirm message', () async {
        await commandResult;

        expect(logger.confirmCalls, isEmpty);
      });
    });

    group('when executing password unset with --yes and --format yaml', () {
      late Future commandResult;

      setUp(() async {
        reset(client);
        when(
          () => client.secrets.delete(
            key: any(named: 'key'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((_) async => Future.value());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'password',
          'unset',
          'database',
          '--project',
          projectId,
          '--format',
          'yaml',
          '--yes',
        ]);
      });

      test('then emits a YAML object with the password name', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['name'], 'database');
      });

      test('then logs no confirm message', () async {
        await commandResult;

        expect(logger.confirmCalls, isEmpty);
      });
    });

    group('when executing password list', () {
      group('with user-defined and platform-managed passwords', () {
        late Future commandResult;

        setUp(() async {
          when(() => client.secrets.list(any())).thenAnswer(
            (_) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_serviceSecret',
              'SERVERPOD_PASSWORD_customPassword',
            ]),
          );

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (_) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_emailSecretHashPepper',
            ]),
          );

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then displays passwords organized by category', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          final lines = logger.lineCalls.map((c) => c.line).toList();

          expect(lines, contains('Custom'));
          expect(lines, contains('Services'));
          expect(lines, contains('Auth'));

          expect(lines, contains(contains('database')));
          expect(lines, contains(contains('serviceSecret')));
          expect(lines, contains(contains('customPassword')));
          expect(lines, contains(contains('emailSecretHashPepper')));
        });
      });

      group('with only user-defined passwords', () {
        late Future commandResult;

        setUp(() async {
          when(() => client.secrets.list(any())).thenAnswer(
            (_) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_customPassword',
            ]),
          );

          when(
            () => client.secrets.listManaged(any()),
          ).thenAnswer((_) async => Future.value([]));

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then displays passwords', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          final lines = logger.lineCalls.map((c) => c.line).toList();

          expect(lines, contains(contains('database')));
          expect(lines, contains(contains('customPassword')));
        });
      });

      group('with only platform-managed passwords', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((_) async => Future.value([]));

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (_) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_emailSecretHashPepper',
            ]),
          );

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then displays platform-managed passwords', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          final lines = logger.lineCalls.map((c) => c.line).toList();

          expect(lines, contains(contains('database')));
          expect(lines, contains(contains('emailSecretHashPepper')));
        });
      });

      group('with platform-managed scloudAuthEmailKey', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((_) async => Future.value([]));

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (_) async =>
                Future.value(['SERVERPOD_PASSWORD_scloudAuthEmailKey']),
          );

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then lists scloudAuthEmailKey under Auth', () async {
          await commandResult;

          final lines = logger.lineCalls.map((c) => c.line).toList();

          expect(
            lines,
            containsAllInOrder(['Auth', contains('scloudAuthEmailKey')]),
          );
        });
      });

      group('with no passwords', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((_) async => Future.value([]));

          when(
            () => client.secrets.listManaged(any()),
          ).thenAnswer((_) async => Future.value([]));

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then displays no passwords available', () async {
          await commandResult;

          expect(logger.lineCalls, isEmpty);
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'No passwords available.'),
          );
        });
      });
    });

    group('when executing password list with --format json', () {
      group('with user-defined and platform-managed passwords', () {
        late Future commandResult;

        setUp(() async {
          when(() => client.secrets.list(any())).thenAnswer(
            (_) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_serviceSecret',
              'SERVERPOD_PASSWORD_customPassword',
            ]),
          );

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (_) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_emailSecretHashPepper',
            ]),
          );

          commandResult = cli.run([
            'password',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);
        });

        test('then emits a JSON list of passwords', () async {
          await commandResult;

          expect(logger.lineCalls, isEmpty);
          final payload = jsonDecode(logger.rawCalls.single.content) as List;
          expect(payload, hasLength(4));

          final custom = payload[0] as Map;
          expect(custom['name'], 'customPassword');
          expect(custom['category'], 'custom');
          expect(custom['status'], 'SET (User)');
          expect(custom['isPlatformManaged'], isFalse);
          expect(custom['isUserSet'], isTrue);

          final database = payload[1] as Map;
          expect(database['name'], 'database');
          expect(database['category'], 'services');
          expect(database['status'], 'SET (User)');
          expect(database['isPlatformManaged'], isTrue);
          expect(database['isUserSet'], isTrue);

          final serviceSecret = payload[2] as Map;
          expect(serviceSecret['name'], 'serviceSecret');
          expect(serviceSecret['status'], 'SET (User)');

          final authPepper = payload[3] as Map;
          expect(authPepper['name'], 'emailSecretHashPepper');
          expect(authPepper['category'], 'auth');
          expect(authPepper['status'], 'AUTO (Platform)');
          expect(authPepper['isPlatformManaged'], isTrue);
          expect(authPepper['isUserSet'], isFalse);
        });
      });

      group('with no passwords', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((_) async => Future.value([]));
          when(
            () => client.secrets.listManaged(any()),
          ).thenAnswer((_) async => Future.value([]));

          commandResult = cli.run([
            'password',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);
        });

        test('then emits an empty JSON array', () async {
          await commandResult;

          expect(logger.lineCalls, isEmpty);
          expect(logger.infoCalls, isEmpty);
          expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
        });
      });

      group('with platform-managed scloudAuthEmailKey', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((_) async => Future.value([]));

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (_) async =>
                Future.value(['SERVERPOD_PASSWORD_scloudAuthEmailKey']),
          );

          commandResult = cli.run([
            'password',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);
        });

        test('then categorizes scloudAuthEmailKey as auth', () async {
          await commandResult;

          expect(logger.lineCalls, isEmpty);
          final payload = jsonDecode(logger.rawCalls.single.content) as List;
          final entry = payload.single as Map;

          expect(entry['name'], 'scloudAuthEmailKey');
          expect(entry['category'], 'auth');
          expect(entry['status'], 'AUTO (Platform)');
          expect(entry['isPlatformManaged'], isTrue);
          expect(entry['isUserSet'], isFalse);
        });
      });
    });

    group('when executing password list with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.list(any())).thenAnswer(
          (_) async => Future.value([
            'SERVERPOD_PASSWORD_database',
            'SERVERPOD_PASSWORD_serviceSecret',
            'SERVERPOD_PASSWORD_customPassword',
          ]),
        );

        when(() => client.secrets.listManaged(any())).thenAnswer(
          (_) async => Future.value([
            'SERVERPOD_PASSWORD_database',
            'SERVERPOD_PASSWORD_emailSecretHashPepper',
          ]),
        );

        commandResult = cli.run([
          'password',
          'list',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML list of passwords', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(4));
        expect((payload[0] as Map)['name'], 'customPassword');
        expect((payload[0] as Map)['category'], 'custom');
        expect((payload[1] as Map)['name'], 'database');
        expect((payload[1] as Map)['status'], 'SET (User)');
        expect((payload[3] as Map)['name'], 'emailSecretHashPepper');
        expect((payload[3] as Map)['status'], 'AUTO (Platform)');
      });
    });
  });
}

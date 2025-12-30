import 'dart:async';

import 'package:config/config.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';

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
          ).thenAnswer((final _) async => Future.value());

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
          ).thenAnswer((final _) async => Future.value());

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
          ).thenAnswer((final _) async => Future.value());

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

          await expectLater(commandResult, throwsA(isA<UsageException>()));
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
          ).thenAnswer((final _) async => Future.value());

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
          await expectLater(
            commandResult,
            throwsA(
              isA<ErrorExitException>().having(
                (final e) => e.reason,
                'reason',
                contains('must be at least 20 characters'),
              ),
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
          ).thenAnswer((final _) async => Future.value());

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
          await expectLater(
            commandResult,
            throwsA(
              isA<ErrorExitException>().having(
                (final e) => e.reason,
                'reason',
                contains('must be at least 10 characters'),
              ),
            ),
          );
        });
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
          ).thenAnswer((final _) async => Future.value());

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
          ).thenAnswer((final _) async => Future.value());

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

    group('when executing password list', () {
      group('with user-defined and platform-managed passwords', () {
        late Future commandResult;

        setUp(() async {
          when(() => client.secrets.list(any())).thenAnswer(
            (final _) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_serviceSecret',
              'SERVERPOD_PASSWORD_customPassword',
            ]),
          );

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (final _) async => Future.value([
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
          final lines = logger.lineCalls.map((final c) => c.line).toList();

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
            (final _) async => Future.value([
              'SERVERPOD_PASSWORD_database',
              'SERVERPOD_PASSWORD_customPassword',
            ]),
          );

          when(
            () => client.secrets.listManaged(any()),
          ).thenAnswer((final _) async => Future.value([]));

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then displays passwords', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          final lines = logger.lineCalls.map((final c) => c.line).toList();

          expect(lines, contains(contains('database')));
          expect(lines, contains(contains('customPassword')));
        });
      });

      group('with only platform-managed passwords', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((final _) async => Future.value([]));

          when(() => client.secrets.listManaged(any())).thenAnswer(
            (final _) async => Future.value([
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
          final lines = logger.lineCalls.map((final c) => c.line).toList();

          expect(lines, contains(contains('database')));
          expect(lines, contains(contains('emailSecretHashPepper')));
        });
      });

      group('with no passwords', () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((final _) async => Future.value([]));

          when(
            () => client.secrets.listManaged(any()),
          ).thenAnswer((final _) async => Future.value([]));

          commandResult = cli.run(['password', 'list', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then displays Custom section with empty message', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          final lines = logger.lineCalls.map((final c) => c.line).toList();

          expect(lines, contains('Custom'));
          expect(lines, contains('<no rows data>'));
        });
      });
    });
  });
}

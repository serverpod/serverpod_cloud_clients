import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/secret_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  const projectId = 'projectId';

  test('Given secrets command when instantiated then requires login', () {
    expect(CloudSecretCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing secrets create', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.create(
              secrets: any(named: 'secrets'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'secret',
          'create',
          'key',
          'value',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
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
            ));
      });
    });

    group('when executing secrets delete and confirming prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.delete(
              key: any(named: 'key'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenThrow(ServerpodClientUnauthorized());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'secret',
          'delete',
          'key',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
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
            ));
      });
    });

    group('when executing secrets list', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.list(any()))
            .thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'secret',
          'list',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
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
            ));
      });
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing secrets create', () {
      setUp(() async {
        when(() => client.secrets.create(
              secrets: any(
                named: 'secrets',
                that: equals({'key': 'value'}),
              ),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final _) async => Future.value());
      });

      group('with value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'secret',
            'create',
            'key',
            'value',
            '--project',
            projectId,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(message: 'Successfully created secret.'),
          );
        });
      });

      group('with value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'secret',
            'create',
            'key',
            '--from-file',
            p.join(d.sandbox, 'value.txt'),
            '--project',
            projectId,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(message: 'Successfully created secret.'),
          );
        });
      });

      group('with both value arg and value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'secret',
            'create',
            'key',
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
            throwsA(isA<UsageException>().having(
              (final e) => e.message,
              'message',
              equals('These options are mutually exclusive: from-file, value.'),
            )),
          );
        });
      });

      group('with neither value arg nor file arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'secret',
            'create',
            'key',
            '--project',
            projectId,
          ]);
        });

        test('then command throws UsageException', () async {
          await expectLater(
            commandResult,
            throwsA(isA<UsageException>().having(
              (final e) => e.message,
              'message',
              equals(
                'Option group Value requires one of the options to be provided.',
              ),
            )),
          );
        });
      });
    });

    group(
        'when executing secrets create '
        'with multi-line value file arg', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.create(
              secrets: any(
                named: 'secrets',
                that: equals({'key': 'value1\nline2'}),
              ),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final _) async => Future.value());

        await d.file('value.txt', 'value1\nline2').create();

        commandResult = cli.run([
          'secret',
          'create',
          'key',
          '--from-file',
          p.join(d.sandbox, 'value.txt'),
          '--project',
          projectId,
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(message: 'Successfully created secret.'),
        );
      });
    });

    group('when executing secrets delete and confirming prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.delete(
              key: any(named: 'key'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final _) async => Future.value());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'secret',
          'delete',
          'key',
          '--project',
          projectId,
        ]);
      });

      test('then logs confirm message', () async {
        await commandResult;

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the secret "key"?',
            defaultValue: false,
          ),
        );
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(message: 'Successfully deleted secret: key.'),
        );
      });
    });

    group('when executing secrets delete and rejecting prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.delete(
              key: any(named: 'key'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final _) async => Future.value());

        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'secret',
          'delete',
          'key',
          '--project',
          projectId,
        ]);
      });

      test('then logs confirm message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the secret "key"?',
            defaultValue: false,
          ),
        );
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

    group('when executing secrets list', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.list(any()))
            .thenAnswer((final _) async => Future.value([
                  'SECRET_1',
                  'SECRET_2',
                  'SECRET_3',
                ]));

        commandResult = cli.run([
          'secret',
          'list',
          '--project',
          projectId,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs table', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'Secret name'),
            equalsLineCall(line: '-----------'),
            equalsLineCall(line: 'SECRET_1   '),
            equalsLineCall(line: 'SECRET_2   '),
            equalsLineCall(line: 'SECRET_3   '),
          ]),
        );
      });
    });
  });
}

import 'dart:async';

import 'package:args/command_runner.dart';
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
    group('when executing password create', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.create(
            secrets: any(named: 'secrets'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'password',
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
          ),
        );
      });
    });

    group('when executing password delete and confirming prompt', () {
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
          ),
        );
      });
    });

    group('when executing password list', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run(['password', 'list', '--project', projectId]);
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
          ),
        );
      });
    });
  });

  group('Given authenticated', () {
    group('when executing password create', () {
      setUp(() async {
        when(
          () => client.secrets.create(
            secrets: any(
              named: 'secrets',
              that: equals({'SERVERPOD_PASSWORD_key': 'value'}),
            ),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value());
      });

      group('with value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
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
            equalsSuccessCall(message: 'Successfully created password.'),
          );
        });
      });

      group('with value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'password',
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
            equalsSuccessCall(message: 'Successfully created password.'),
          );
        });
      });

      group('with both value arg and value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'password',
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
            throwsA(
              isA<UsageException>().having(
                (final e) => e.message,
                'message',
                equals(
                  'These options are mutually exclusive: from-file, value.',
                ),
              ),
            ),
          );
        });
      });

      group('with neither value arg nor file arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'password',
            'create',
            'key',
            '--project',
            projectId,
          ]);
        });

        test('then command throws UsageException', () async {
          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (final e) => e.message,
                'message',
                equals(
                  'Option group Value requires one of the options to be provided.',
                ),
              ),
            ),
          );
        });
      });
    });

    group('when executing password create '
        'with multi-line value file arg', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.create(
            secrets: any(
              named: 'secrets',
              that: equals({'SERVERPOD_PASSWORD_key': 'value1\nline2'}),
            ),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value());

        await d.file('value.txt', 'value1\nline2').create();

        commandResult = cli.run([
          'password',
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
          equalsSuccessCall(message: 'Successfully created password.'),
        );
      });
    });

    group('when executing password delete and confirming prompt', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.delete(
            key: any(named: 'key', that: equals('SERVERPOD_PASSWORD_key')),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'password',
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
            message: 'Are you sure you want to delete the password "key"?',
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
          equalsSuccessCall(message: 'Successfully deleted password: key.'),
        );
      });
    });

    group('when executing password delete and rejecting prompt', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.secrets.delete(
            key: any(named: 'key'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async => Future.value());

        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'password',
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
            message: 'Are you sure you want to delete the password "key"?',
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

    group('when executing password list', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.list(any())).thenAnswer(
          (final _) async => Future.value([
            'SECRET_1',
            'SERVERPOD_PASSWORD_key1',
            'SECRET_2',
            'SERVERPOD_PASSWORD_key2',
            'SERVERPOD_PASSWORD_key3',
            'OTHER_SECRET',
          ]),
        );

        commandResult = cli.run(['password', 'list', '--project', projectId]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs table with only password secrets', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(logger.lineCalls[0].line, equals('Password name'));
        expect(logger.lineCalls[1].line, equals('-------------'));
        expect(logger.lineCalls[2].line, startsWith('key1'));
        expect(logger.lineCalls[3].line, startsWith('key2'));
        expect(logger.lineCalls[4].line, startsWith('key3'));
      });

      test('then filters out non-password secrets', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          isNot(contains(equalsLineCall(line: 'SECRET_1   '))),
        );
        expect(
          logger.lineCalls,
          isNot(contains(equalsLineCall(line: 'SECRET_2   '))),
        );
        expect(
          logger.lineCalls,
          isNot(contains(equalsLineCall(line: 'OTHER_SECRET   '))),
        );
      });

      test('then displays passwords without prefix', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls.any(
            (final call) => call.line.contains('SERVERPOD_PASSWORD_'),
          ),
          isFalse,
        );
        expect(
          logger.lineCalls.any((final call) => call.line.startsWith('key1')),
          isTrue,
        );
      });
    });

    group('when executing password list with no password secrets', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.secrets.list(any())).thenAnswer(
          (final _) async =>
              Future.value(['SECRET_1', 'SECRET_2', 'OTHER_SECRET']),
        );

        commandResult = cli.run(['password', 'list', '--project', projectId]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs table with only header', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(logger.lineCalls[0].line, equals('Password name'));
        expect(logger.lineCalls[1].line, equals('-------------'));
        expect(logger.lineCalls.length, greaterThanOrEqualTo(2));
        expect(logger.lineCalls.length, lessThanOrEqualTo(3));
      });
    });
  });
}

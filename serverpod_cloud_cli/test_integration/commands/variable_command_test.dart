import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/variable_command.dart';
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

  test('Given variable command when instantiated then requires login', () {
    expect(CloudVariableCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing variable create', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.create(any(), any(), any()))
            .thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'variable',
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

    group('when executing variable update', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.update(
              name: any(named: 'name'),
              value: any(named: 'value'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'variable',
          'update',
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

    group('when executing variable delete and confirming prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.delete(
              name: any(named: 'name'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenThrow(ServerpodClientUnauthorized());

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'variable',
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

    group('when executing variable list', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any()))
            .thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'variable',
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

    group('when executing variable create', () {
      setUp(() async {
        when(() => client.environmentVariables.create(
              any(that: equals('key')),
              any(that: equals('value')),
              any(),
            )).thenAnswer((final invocation) async => Future.value(
              EnvironmentVariable(
                name: invocation.positionalArguments[0],
                value: invocation.positionalArguments[1],
                capsuleId: 0,
              ),
            ));
      });

      group('with value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
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
            equalsSuccessCall(
              message: 'Successfully created environment variable.',
            ),
          );
        });
      });

      group('with value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'variable',
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
            equalsSuccessCall(
              message: 'Successfully created environment variable.',
            ),
          );
        });
      });

      group('with both value arg and value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'variable',
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
              equals(
                'These options are mutually exclusive: from-file, value.',
              ),
            )),
          );
        });
      });

      group('with neither value arg nor file arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
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

    group('when executing variable create', () {
      setUp(() async {
        when(() => client.environmentVariables.create(
              any(that: equals('key')),
              any(that: equals('value1\nline2')),
              any(),
            )).thenAnswer((final invocation) async => Future.value(
              EnvironmentVariable(
                name: invocation.positionalArguments[0],
                value: invocation.positionalArguments[1],
                capsuleId: 0,
              ),
            ));
      });

      group('with multi-line value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'create',
            'key',
            'value1\nline2',
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
            equalsSuccessCall(
              message: 'Successfully created environment variable.',
            ),
          );
        });
      });

      group('with multi-line value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value1\nline2').create();

          commandResult = cli.run([
            'variable',
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
            equalsSuccessCall(
              message: 'Successfully created environment variable.',
            ),
          );
        });
      });
    });

    group('when executing variable update', () {
      setUp(() async {
        when(() => client.environmentVariables.update(
              name: any(named: 'name', that: equals('key')),
              value: any(named: 'value', that: equals('value')),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final invocation) async => Future.value(
              EnvironmentVariable(
                name: invocation.namedArguments[#name],
                value: invocation.namedArguments[#value],
                capsuleId: 0,
              ),
            ));
      });

      group('with value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'update',
            'key',
            'value',
            '--project',
            projectId,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully updated environment variable: key.',
            ),
          );
        });
      });

      group('with value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'variable',
            'update',
            'key',
            '--from-file',
            p.join(d.sandbox, 'value.txt'),
            '--project',
            projectId,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Successfully updated environment variable: key.',
            ),
          );
        });
      });

      group('with both value arg and value file arg', () {
        late Future commandResult;

        setUp(() async {
          await d.file('value.txt', 'value').create();

          commandResult = cli.run([
            'variable',
            'update',
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
              equals(
                'These options are mutually exclusive: from-file, value.',
              ),
            )),
          );
        });
      });

      group('with neither value arg nor file arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'update',
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

    group('when executing variable delete and confirming prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.delete(
              name: any(named: 'name'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final invocation) async => Future.value(
              EnvironmentVariable(
                name: invocation.namedArguments[#name],
                value: 'placeholder',
                capsuleId: 0,
              ),
            ));

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'variable',
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
            message:
                'Are you sure you want to delete the environment variable "key"?',
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
          equalsSuccessCall(
            message: 'Successfully deleted environment variable: key.',
          ),
        );
      });
    });

    group('when executing variable delete and rejecting prompt', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'variable',
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
            message:
                'Are you sure you want to delete the environment variable "key"?',
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

    group('when executing variable list', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any()))
            .thenAnswer((final invocation) async => Future.value([
                  EnvironmentVariable(
                    name: 'name',
                    value: 'value',
                    capsuleId: 0,
                  ),
                ]));

        commandResult = cli.run([
          'variable',
          'list',
          '--project',
          projectId,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'Name | Value'),
            equalsLineCall(line: '-----+------'),
            equalsLineCall(line: 'name | value'),
          ]),
        );
      });
    });
  });
}

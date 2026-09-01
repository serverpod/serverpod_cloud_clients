import 'dart:async';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/variable/variable_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
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
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() async {
    logger.clear();
  });

  const projectId = 'projectId';

  test('Given variable command when instantiated then requires login', () {
    expect(CloudVariableCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing variable set', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'variable',
          'set',
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

    group('when executing variable set and the variable already exists', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (final _) async => [
            EnvironmentVariable(name: 'key', value: 'old', capsuleId: 0),
          ],
        );
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);
        when(
          () => client.environmentVariables.update(
            name: any(named: 'name'),
            value: any(named: 'value'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'variable',
          'set',
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

    group('when executing variable unset', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run([
          'variable',
          'unset',
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

    group('when executing variable list', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        commandResult = cli.run(['variable', 'list', '--project', projectId]);
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
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    group('when executing variable set', () {
      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);
        when(
          () => client.environmentVariables.create(
            any(that: equals('key')),
            any(that: equals('value')),
            any(),
          ),
        ).thenAnswer(
          (final invocation) async => Future.value(
            EnvironmentVariable(
              name: invocation.positionalArguments[0],
              value: invocation.positionalArguments[1],
              capsuleId: 0,
            ),
          ),
        );
      });

      group('with value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'set',
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
              message: 'Successfully set environment variable: key.',
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
            'set',
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
              message: 'Successfully set environment variable: key.',
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
            'set',
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
            'variable',
            'set',
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

    group('when executing variable set with multi-line values', () {
      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);
        when(
          () => client.environmentVariables.create(
            any(that: equals('key')),
            any(that: equals('value1\nline2')),
            any(),
          ),
        ).thenAnswer(
          (final invocation) async => Future.value(
            EnvironmentVariable(
              name: invocation.positionalArguments[0],
              value: invocation.positionalArguments[1],
              capsuleId: 0,
            ),
          ),
        );
      });

      group('with multi-line value arg', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'set',
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
              message: 'Successfully set environment variable: key.',
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
            'set',
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
              message: 'Successfully set environment variable: key.',
            ),
          );
        });
      });
    });

    group(
      'when executing variable set and name already exists as unmasked',
      () {
        setUp(() async {
          when(() => client.environmentVariables.list(any())).thenAnswer(
            (final _) async => [
              EnvironmentVariable(name: 'key', value: 'old', capsuleId: 0),
            ],
          );
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((final _) async => <String>[]);
          when(
            () => client.environmentVariables.update(
              name: any(named: 'name', that: equals('key')),
              value: any(named: 'value', that: equals('value')),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer(
            (final invocation) async => Future.value(
              EnvironmentVariable(
                name: invocation.namedArguments[#name],
                value: invocation.namedArguments[#value],
                capsuleId: 0,
              ),
            ),
          );
        });

        group('with value arg', () {
          late Future commandResult;

          setUp(() async {
            commandResult = cli.run([
              'variable',
              'set',
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
                message: 'Successfully set environment variable: key.',
              ),
            );
          });
        });

        group('with --no-secret', () {
          late Future commandResult;

          setUp(() async {
            commandResult = cli.run([
              'variable',
              'set',
              '--no-secret',
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
                message: 'Successfully set environment variable: key.',
              ),
            );
          });
        });

        group('with --secret', () {
          late Future commandResult;

          setUp(() async {
            commandResult = cli.run([
              'variable',
              'set',
              '--secret',
              'key',
              'value',
              '--project',
              projectId,
            ]);
          });

          test('then throws exception', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then logs error with recreate commands', () async {
            try {
              await commandResult;
            } catch (_) {}

            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first,
              equalsErrorCall(
                message:
                    '"key" already exists as an unmasked variable. '
                    'To recreate it as a secret:',
                hint:
                    'scloud variable unset key\n'
                    '  scloud variable set --secret key <value>',
              ),
            );
          });
        });
      },
    );

    group('when executing variable set and name already exists as secret', () {
      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => ['key']);
        when(
          () => client.secrets.upsert(
            secrets: any(named: 'secrets', that: equals({'key': 'value'})),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async {});
      });

      group('without flag', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'set',
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
            equalsSuccessCall(message: 'Successfully set secret: key.'),
          );
        });
      });

      group('with --secret', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'set',
            '--secret',
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
            equalsSuccessCall(message: 'Successfully set secret: key.'),
          );
        });
      });

      group('with --no-secret', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'variable',
            'set',
            '--no-secret',
            'key',
            'value',
            '--project',
            projectId,
          ]);
        });

        test('then throws exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error with recreate commands', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.errorCalls, isNotEmpty);
          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  '"key" already exists as a secret. '
                  'To recreate it as an unmasked variable:',
              hint:
                  'scloud variable unset key\n'
                  '  scloud variable set --no-secret key <value>',
            ),
          );
        });
      });
    });

    group('when executing variable set --secret and name does not exist', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);
        when(
          () => client.secrets.create(
            secrets: any(named: 'secrets', that: equals({'key': 'value'})),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async {});

        commandResult = cli.run([
          'variable',
          'set',
          '--secret',
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
          equalsSuccessCall(message: 'Successfully set secret: key.'),
        );
      });
    });

    group('when executing variable set --secret with value file arg', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);
        when(
          () => client.secrets.create(
            secrets: any(named: 'secrets', that: equals({'key': 'value'})),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer((final _) async {});

        await d.file('value.txt', 'value').create();

        commandResult = cli.run([
          'variable',
          'set',
          '--secret',
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
          equalsSuccessCall(message: 'Successfully set secret: key.'),
        );
      });
    });

    group('when executing variable set with an invalid name', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'variable',
          'set',
          'new-secret',
          'value',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs validation error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message:
                'Use letters, digits and underscores, starting with a letter or '
                'an underscore.',
          ),
        );
      });
    });

    group('when executing variable set with a password-prefixed name', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'variable',
          'set',
          'SERVERPOD_PASSWORD_database',
          'value',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs prefix error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: "Names can't start with 'SERVERPOD_PASSWORD_'.",
            hint: 'Use `scloud password set` to manage passwords.',
          ),
        );
      });
    });

    group('when executing variable unset and confirming prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (final _) async => [
            EnvironmentVariable(name: 'key', value: 'value', capsuleId: 0),
          ],
        );
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);
        when(
          () => client.environmentVariables.delete(
            name: any(named: 'name'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          ),
        ).thenAnswer(
          (final invocation) async => Future.value(
            EnvironmentVariable(
              name: invocation.namedArguments[#name],
              value: 'placeholder',
              capsuleId: 0,
            ),
          ),
        );

        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'variable',
          'unset',
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
                'Are you sure you want to remove the environment variable "key"?',
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
            message: 'Successfully removed environment variable: key.',
          ),
        );
      });
    });

    group(
      'when executing variable unset for a secret and confirming prompt',
      () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.environmentVariables.list(any()),
          ).thenAnswer((final _) async => <EnvironmentVariable>[]);
          when(
            () => client.secrets.list(any()),
          ).thenAnswer((final _) async => ['key']);
          when(
            () => client.secrets.delete(
              key: any(named: 'key'),
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((final _) async {});

          logger.answerNextConfirmWith(true);
          commandResult = cli.run([
            'variable',
            'unset',
            'key',
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
            equalsSuccessCall(message: 'Successfully removed secret: key.'),
          );
        });
      },
    );

    group('when executing variable unset and the name is not found', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);

        commandResult = cli.run([
          'variable',
          'unset',
          'key',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs not found error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'The environment variable "key" was not found.',
          ),
        );
      });
    });

    group('when executing variable unset and rejecting prompt', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (final _) async => [
            EnvironmentVariable(name: 'key', value: 'value', capsuleId: 0),
          ],
        );
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((final _) async => <String>[]);

        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'variable',
          'unset',
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
                'Are you sure you want to remove the environment variable "key"?',
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
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (final _) async => [
            EnvironmentVariable(name: 'zebra', value: 'one', capsuleId: 0),
            EnvironmentVariable(name: 'alpha', value: 'two', capsuleId: 0),
          ],
        );
        when(() => client.secrets.list(any())).thenAnswer(
          (final _) async => [
            'secret_z',
            'SERVERPOD_PASSWORD_database',
            'secret_a',
          ],
        );

        commandResult = cli.run(['variable', 'list', '--project', projectId]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs unmasked variables first then masked secrets', () async {
        await commandResult;

        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'Name     | Value   '),
            equalsLineCall(line: '---------+---------'),
            equalsLineCall(line: 'zebra    | one     '),
            equalsLineCall(line: 'alpha    | two     '),
            equalsLineCall(line: 'secret_z | ••••••••'),
            equalsLineCall(line: 'secret_a | ••••••••'),
          ]),
        );
      });

      test('then omits password-prefixed secrets', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((final call) => call.line),
          isNot(contains(contains('SERVERPOD_PASSWORD_database'))),
        );
      });
    });

    group('when executing variable list with --format json', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (final _) async => [
            EnvironmentVariable(name: 'zebra', value: 'one', capsuleId: 0),
            EnvironmentVariable(name: 'alpha', value: 'two', capsuleId: 0),
          ],
        );
        when(() => client.secrets.list(any())).thenAnswer(
          (final _) async => [
            'secret_z',
            'SERVERPOD_PASSWORD_database',
            'secret_a',
          ],
        );

        commandResult = cli.run([
          'variable',
          'list',
          '--project',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON list of variables', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), [
          {'name': 'zebra', 'value': 'one'},
          {'name': 'alpha', 'value': 'two'},
          {'name': 'secret_z', 'value': '••••••••'},
          {'name': 'secret_a', 'value': '••••••••'},
        ]);
      });
    });

    group('when executing variable list with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (final _) async => [
            EnvironmentVariable(name: 'zebra', value: 'one', capsuleId: 0),
            EnvironmentVariable(name: 'alpha', value: 'two', capsuleId: 0),
          ],
        );
        when(() => client.secrets.list(any())).thenAnswer(
          (final _) async => [
            'secret_z',
            'SERVERPOD_PASSWORD_database',
            'secret_a',
          ],
        );

        commandResult = cli.run([
          'variable',
          'list',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML list of variables', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(4));
        expect((payload[0] as Map)['name'], 'zebra');
        expect((payload[0] as Map)['value'], 'one');
        expect((payload[1] as Map)['name'], 'alpha');
        expect((payload[1] as Map)['value'], 'two');
        expect((payload[2] as Map)['name'], 'secret_z');
        expect((payload[2] as Map)['value'], '••••••••');
        expect((payload[3] as Map)['name'], 'secret_a');
        expect((payload[3] as Map)['value'], '••••••••');
      });
    });
  });
}

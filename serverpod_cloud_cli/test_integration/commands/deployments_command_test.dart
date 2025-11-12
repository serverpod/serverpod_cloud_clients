import 'dart:async';

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:test/test.dart';

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

  test('Given deployments show command when instantiated then requires login',
      () {
    expect(CloudDeploymentsShowCommand(logger: logger).requireLogin, isTrue);
  });

  test('Given deployments list command when instantiated then requires login',
      () {
    expect(CloudDeploymentsListCommand(logger: logger).requireLogin, isTrue);
  });

  test(
      'Given deployments build-log command when instantiated then requires login',
      () {
    expect(
        CloudDeploymentsBuildLogCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    setUpAll(() async {
      when(() => client.status.getDeployAttempts(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            limit: any(named: 'limit'),
          )).thenThrow(ServerpodClientUnauthorized());

      when(() => client.status.getDeployAttemptId(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            attemptNumber: any(named: 'attemptNumber'),
          )).thenThrow(ServerpodClientUnauthorized());
    });

    tearDownAll(() {
      reset(client.status);
    });

    group('when executing deployments show', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'deployment',
          'show',
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

    group('when executing deployments build-log', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'deployment',
          'build-log',
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

    group('when executing deployments list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'deployment',
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

    group('and a successful status, when running deployments show command', () {
      group('with correct args to get the most recent deploy status', () {
        setUpAll(() async {
          final attemptStages = [
            DeployAttemptStage(
              cloudCapsuleId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.upload,
              stageStatus: DeployProgressStatus.success,
              startedAt: DateTime.parse("2021-12-31 10:20:30"),
              endedAt: DateTime.parse("2021-12-31 10:20:40"),
            ),
            DeployAttemptStage(
              cloudCapsuleId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.build,
              buildId: 'build-id-foo',
              stageStatus: DeployProgressStatus.success,
              startedAt: DateTime.parse("2021-12-31 10:20:30"),
              endedAt: DateTime.parse("2021-12-31 10:20:40"),
            ),
            DeployAttemptStage(
              cloudCapsuleId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.deploy,
              stageStatus: DeployProgressStatus.success,
              startedAt: DateTime.parse("2021-12-31 10:20:30"),
              endedAt: DateTime.parse("2021-12-31 10:20:40"),
            ),
            DeployAttemptStage(
              cloudCapsuleId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.service,
              stageStatus: DeployProgressStatus.success,
              startedAt: DateTime.parse("2021-12-31 10:20:30"),
              endedAt: DateTime.parse("2021-12-31 10:20:40"),
            ),
          ];

          when(() => client.status.getDeployAttemptStatus(
                cloudCapsuleId: projectId,
                attemptId: attemptStages.first.attemptId,
              )).thenAnswer((final _) async => attemptStages);

          when(() => client.status.getDeployAttemptId(
                cloudCapsuleId: projectId,
                attemptNumber: 0,
              )).thenAnswer((final _) async => attemptStages.first.attemptId);
        });

        tearDownAll(() {
          reset(client.status);
        });

        @isTestGroup
        void testCorrectGetRecentStatusCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;
            setUp(() async {
              commandResult = cli.run([
                'deployment',
                'show',
                ...args,
              ]);
            });

            test('then completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then outputs the status', () async {
              await commandResult;

              expect(logger.lineCalls, isNotEmpty);
              expect(
                logger.lineCalls.map((final l) => l.line).join('\n'),
                '''
Status of projectId deploy abc, started at 2021-12-31 10:20:30:

✅  Booster liftoff:     Upload successful!

✅  Orbit acceleration:  Build successful!

✅  Orbital insertion:   Deploy successful!

✅  Pod commissioning:   Service successful! 🚀
''',
              );
            });
          });
        }

        testCorrectGetRecentStatusCommand(
            'by named proj opt and default build', ['--project', projectId]);
        testCorrectGetRecentStatusCommand(
            'by named proj opt and build index', ['--project', projectId, '0']);
        testCorrectGetRecentStatusCommand(
            'by named proj opt and build id', ['--project', projectId, 'abc']);

        group('and with option --output-overall-status', () {
          late Future commandResult;

          setUp(() async {
            commandResult = cli.run([
              'deployment',
              'show',
              '--project',
              projectId,
              '--output-overall-status',
            ]);
          });

          test('then completes successfully', () async {
            await expectLater(commandResult, completes);
          });

          test('then outputs the single word success', () async {
            await commandResult;

            expect(logger.lineCalls, isNotEmpty);
            expect(logger.lineCalls.single.line, equals('success'));
          });
        });
      });

      group('with args to get most recent deploy status which does not exist',
          () {
        setUpAll(() async {
          when(() => client.status.getDeployAttemptStatus(
                cloudCapsuleId: any(named: 'cloudCapsuleId'),
                attemptId: any(named: 'attemptId'),
              )).thenThrow(NotFoundException(message: 'not found'));

          when(() => client.status.getDeployAttemptId(
                cloudCapsuleId: any(named: 'cloudCapsuleId'),
                attemptNumber: any(named: 'attemptNumber'),
              )).thenThrow(NotFoundException(message: 'not found'));
        });

        tearDownAll(() async {
          reset(client.status);
        });

        @isTestGroup
        void testGetStatusWithMissingDeployCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;
            setUp(() async {
              commandResult = cli.run([
                'deployment',
                'show',
                ...args,
              ]);
            });

            test('then throws ExitErrorException', () async {
              await expectLater(
                  commandResult, throwsA(isA<ErrorExitException>()));
            });

            test('then outputs error message', () async {
              await commandResult.onError((final e, final s) {});

              expect(logger.errorCalls, isNotEmpty);
              expect(
                logger.errorCalls.first,
                equalsErrorCall(
                  message: 'No deployment status found.',
                  hint: 'Run this command to deploy: scloud deploy',
                ),
              );
            });
          });
        }

        testGetStatusWithMissingDeployCommand(
          'for named proj opt without deploy index',
          ['--project', projectId],
        );
        testGetStatusWithMissingDeployCommand(
          'for named proj opt with deploy index 0',
          ['--project', projectId, '0'],
        );
        testGetStatusWithMissingDeployCommand(
          'for non-existing project without deploy index',
          ['--project', 'non-existing'],
        );
        testGetStatusWithMissingDeployCommand(
          'for non-existing project with deploy index 0',
          ['--project', 'non-existing', '0'],
        );
      });

      group('with args to get a specific deploy status which does not exist',
          () {
        setUpAll(() async {
          when(() => client.status.getDeployAttemptStatus(
                cloudCapsuleId: any(named: 'cloudCapsuleId'),
                attemptId: any(named: 'attemptId'),
              )).thenThrow(NotFoundException(message: 'not found'));

          when(() => client.status.getDeployAttemptId(
                cloudCapsuleId: any(named: 'cloudCapsuleId'),
                attemptNumber: any(named: 'attemptNumber'),
              )).thenThrow(NotFoundException(message: 'not found'));
        });

        tearDownAll(() async {
          reset(client.status);
        });

        @isTestGroup
        void testGetSpecificMissingStatusCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;
            setUp(() async {
              commandResult = cli.run([
                'deployment',
                'show',
                ...args,
              ]);
            });

            test('then throws ExitErrorException', () async {
              await expectLater(
                  commandResult, throwsA(isA<ErrorExitException>()));
            });

            test('then outputs error message', () async {
              await commandResult.onError((final e, final s) {});

              expect(logger.errorCalls, isNotEmpty);
              expect(
                logger.errorCalls.first,
                equalsErrorCall(
                  message: 'No such deployment status found.',
                  hint: 'Run this command to see recent deployments: '
                      'scloud deployment list',
                ),
              );
            });
          });
        }

        testGetSpecificMissingStatusCommand(
          'for named proj opt with non-existing deploy index',
          ['--project', projectId, '2'],
        );
        testGetSpecificMissingStatusCommand(
          'for non-existing project with non-existing deploy index',
          ['--project', 'non-existing', '2'],
        );

        group(
            'for named proj opt with non-existing deploy id with args="--project $projectId non-existing"',
            () {
          late Future commandResult;
          setUp(() async {
            commandResult = cli.run([
              'deployment',
              'show',
              '--project',
              projectId,
              'non-existing',
            ]);
          });

          test('then throws ExitErrorException', () async {
            await expectLater(
                commandResult, throwsA(isA<ErrorExitException>()));
          });

          test('then outputs error message', () async {
            await commandResult.onError((final e, final s) {});

            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first,
              equalsErrorCall(
                message: 'The requested resource did not exist.',
                hint: 'not found',
              ),
            );
          });
        });
      });
    });

    group('and an unsuccessful status,', () {
      setUpAll(() async {
        final attemptStages = [
          DeployAttemptStage(
            cloudCapsuleId: projectId,
            attemptId: 'abc',
            stageType: DeployStageType.upload,
            stageStatus: DeployProgressStatus.success,
            startedAt: DateTime.parse("2021-12-31 10:20:30"),
            endedAt: DateTime.parse("2021-12-31 10:20:40"),
          ),
          DeployAttemptStage(
            cloudCapsuleId: projectId,
            attemptId: 'abc',
            stageType: DeployStageType.build,
            buildId: 'build-id-foo',
            stageStatus: DeployProgressStatus.success,
            startedAt: DateTime.parse("2021-12-31 10:20:30"),
            endedAt: DateTime.parse("2021-12-31 10:20:40"),
          ),
          DeployAttemptStage(
            cloudCapsuleId: projectId,
            attemptId: 'abc',
            stageType: DeployStageType.deploy,
            stageStatus: DeployProgressStatus.success,
            startedAt: DateTime.parse("2021-12-31 10:20:30"),
            endedAt: DateTime.parse("2021-12-31 10:20:40"),
          ),
          DeployAttemptStage(
            cloudCapsuleId: projectId,
            attemptId: 'abc',
            stageType: DeployStageType.service,
            stageStatus: DeployProgressStatus.awaiting,
            startedAt: DateTime.parse("2021-12-31 10:20:30"),
            endedAt: DateTime.parse("2021-12-31 10:20:40"),
          ),
        ];

        when(() => client.status.getDeployAttemptStatus(
              cloudCapsuleId: projectId,
              attemptId: attemptStages.first.attemptId,
            )).thenAnswer((final _) async => attemptStages);

        when(() => client.status.getDeployAttemptId(
              cloudCapsuleId: projectId,
              attemptNumber: 0,
            )).thenAnswer((final _) async => attemptStages.first.attemptId);
      });

      tearDownAll(() {
        reset(client.status);
      });

      group('when running deployments show command to get the deploy status',
          () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'deployment',
            'show',
            '--project',
            projectId,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then outputs the status', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          expect(
            logger.lineCalls.map((final l) => l.line).join('\n'),
            '''
Status of projectId deploy abc, started at 2021-12-31 10:20:30:

✅  Booster liftoff:     Upload successful!

✅  Orbit acceleration:  Build successful!

✅  Orbital insertion:   Deploy successful!

⬛  Pod commissioning:   Service awaiting...
''',
          );
        });
      });

      group(
          'when running deployments show command with --output-overall-status option',
          () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([
            'deployment',
            'show',
            '--project',
            projectId,
            '--output-overall-status',
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then outputs the single word awaiting', () async {
          await commandResult;

          expect(logger.lineCalls, isNotEmpty);
          expect(logger.lineCalls.single.line, equals('awaiting'));
        });
      });
    });

    group('when running deployments list command', () {
      group('with correct args to get the deployments list', () {
        setUpAll(() async {
          final buildStatuses = [
            DeployAttempt(
              cloudCapsuleId: projectId,
              attemptId: 'foo',
              status: DeployProgressStatus.success,
              startedAt: DateTime.parse("2021-12-31 10:20:30"),
              endedAt: DateTime.parse("2021-12-31 10:20:40"),
              statusInfo: null,
            ),
            DeployAttempt(
              cloudCapsuleId: projectId,
              attemptId: 'bar',
              status: DeployProgressStatus.failure,
              startedAt: DateTime.parse("2021-12-31 10:10:30"),
              endedAt: DateTime.parse("2021-12-31 10:10:40"),
              statusInfo: 'Some error',
            ),
          ];

          when(() => client.status.getDeployAttempts(
                cloudCapsuleId: projectId,
                limit: any(named: 'limit'),
              )).thenAnswer((final _) async => buildStatuses);
        });

        tearDownAll(() async {
          reset(client.status);
        });

        @isTestGroup
        void testCorrectGetStatusesCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;

            setUp(() async {
              commandResult = cli.run([
                'deployment',
                'list',
                ...args,
              ]);
            });

            test('then completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then outputs the status list', () async {
              await commandResult;

              expect(logger.lineCalls, isNotEmpty);
              expect(
                logger.lineCalls,
                containsAllInOrder([
                  equalsLineCall(
                    line:
                        '# | Project   | Deploy Id | Status  | Started             | Finished            | Info      ',
                  ),
                  equalsLineCall(
                    line:
                        '--+-----------+-----------+---------+---------------------+---------------------+-----------',
                  ),
                  equalsLineCall(
                    line:
                        '0 | projectId | foo       | SUCCESS | 2021-12-31 10:20:30 | 2021-12-31 10:20:40 |           ',
                  ),
                  equalsLineCall(
                    line:
                        '1 | projectId | bar       | FAILURE | 2021-12-31 10:10:30 | 2021-12-31 10:10:40 | Some error',
                  ),
                ]),
              );
            });
          });
        }

        testCorrectGetStatusesCommand(
            'with named project opt', ['--project', projectId]);
      });
    });
  });
}

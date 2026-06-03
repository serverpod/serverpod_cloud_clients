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

  setUpAll(() {
    registerFallbackValue(Uuid().v4obj());
  });

  test(
    'Given deployments show command when instantiated then requires login',
    () {
      expect(CloudDeploymentsShowCommand(logger: logger).requireLogin, isTrue);
    },
  );

  test(
    'Given deployments list command when instantiated then requires login',
    () {
      expect(CloudDeploymentsListCommand(logger: logger).requireLogin, isTrue);
    },
  );

  test(
    'Given deployments build-log command when instantiated then requires login',
    () {
      expect(
        CloudDeploymentsBuildLogCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given unauthenticated', () {
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    setUpAll(() async {
      when(
        () => client.status.getDeployAttempts(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(ServerpodClientUnauthorized());

      when(
        () => client.status.getDeployAttemptId(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          attemptNumber: any(named: 'attemptNumber'),
        ),
      ).thenThrow(ServerpodClientUnauthorized());
    });

    tearDownAll(() {
      reset(client.status);
    });

    group('when executing deployments show', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run(['deployment', 'show', '--project', projectId]);
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
          ),
        );
      });
    });

    group('when executing deployments list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run(['deployment', 'list', '--project', projectId]);
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
    final attemptId = Uuid().v4obj();
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    group('and a successful status, when running deployments show command', () {
      group('with correct args to get the most recent deploy status', () {
        setUpAll(() async {
          final attemptStages = [
            DeployAttemptStageBuilder()
                .withCloudCapsuleId(projectId)
                .withAttemptId(attemptId)
                .withStageType(DeployStageType.upload)
                .withStageStatus(DeployProgressStatus.success)
                .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
                .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
                .build(),
            DeployAttemptStageBuilder()
                .withCloudCapsuleId(projectId)
                .withAttemptId(attemptId)
                .withStageType(DeployStageType.build)
                .withBuildId('build-id-foo')
                .withStageStatus(DeployProgressStatus.running)
                .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
                .build(),
            DeployAttemptStageBuilder()
                .withCloudCapsuleId(projectId)
                .withAttemptId(attemptId)
                .withStageType(DeployStageType.build)
                .withBuildId('build-id-foo')
                .withStageStatus(DeployProgressStatus.success)
                .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
                .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
                .build(),
            DeployAttemptStageBuilder()
                .withCloudCapsuleId(projectId)
                .withAttemptId(attemptId)
                .withStageType(DeployStageType.deploy)
                .withStageStatus(DeployProgressStatus.success)
                .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
                .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
                .build(),
            DeployAttemptStageBuilder()
                .withCloudCapsuleId(projectId)
                .withAttemptId(attemptId)
                .withStageType(DeployStageType.service)
                .withStageStatus(DeployProgressStatus.success)
                .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
                .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
                .build(),
          ];

          when(
            () => client.status.getDeployAttemptStatus(
              cloudCapsuleId: projectId,
              attemptId: attemptStages.first.attemptId,
            ),
          ).thenAnswer((final _) async => attemptStages);

          when(
            () => client.status.getDeployAttemptId(
              cloudCapsuleId: projectId,
              attemptNumber: 0,
            ),
          ).thenAnswer((final _) async => attemptStages.first.attemptId);

          when(
            () => client.status.tailDeployAttemptStatus(
              cloudCapsuleId: projectId,
              attemptId: attemptStages.first.attemptId,
            ),
          ).thenAnswer((final _) => Stream.fromIterable(attemptStages));
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
              commandResult = cli.run(['deployment', 'show', ...args]);
            });

            test('then completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then outputs the status', () async {
              await commandResult;

              expect(logger.lineCalls, isNotEmpty);
              expect(logger.lineCalls.map((final l) => l.line).join('\n'), '''
Tracking projectId deployment $attemptId
(Press Ctrl+C to exit)
''');
              expect(
                logger.progressCalls.map((final c) => c.message),
                containsAllInOrder([
                  contains('Upload awaiting'),
                  contains('Cloud build awaiting'),
                  contains('Infra deploy awaiting'),
                  contains('Service rollout awaiting'),
                ]),
              );
            });
          });
        }

        testCorrectGetRecentStatusCommand(
          'by named proj opt and default build',
          ['--project', projectId],
        );
        testCorrectGetRecentStatusCommand('by named proj opt and build index', [
          '--project',
          projectId,
          '0',
        ]);
        testCorrectGetRecentStatusCommand('by named proj opt and build id', [
          '--project',
          projectId,
          attemptId.toString(),
        ]);

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

      group(
        'with args to get most recent deploy status which does not exist',
        () {
          setUpAll(() async {
            when(
              () => client.status.getDeployAttemptStatus(
                cloudCapsuleId: any(named: 'cloudCapsuleId'),
                attemptId: any(named: 'attemptId'),
              ),
            ).thenThrow(NotFoundException(message: 'not found'));

            when(
              () => client.status.getDeployAttemptId(
                cloudCapsuleId: any(named: 'cloudCapsuleId'),
                attemptNumber: any(named: 'attemptNumber'),
              ),
            ).thenThrow(NotFoundException(message: 'not found'));
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
                commandResult = cli.run(['deployment', 'show', ...args]);
              });

              test('then throws ExitErrorException', () async {
                await expectLater(
                  commandResult,
                  throwsA(isA<ErrorExitException>()),
                );
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
        },
      );

      group('with args to get a specific deploy status which does not exist', () {
        setUpAll(() async {
          when(
            () => client.status.getDeployAttemptStatus(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              attemptId: any(named: 'attemptId'),
            ),
          ).thenThrow(NotFoundException(message: 'not found'));

          when(
            () => client.status.getDeployAttemptId(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              attemptNumber: any(named: 'attemptNumber'),
            ),
          ).thenThrow(NotFoundException(message: 'not found'));

          when(
            () => client.status.tailDeployAttemptStatus(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              attemptId: any(named: 'attemptId'),
            ),
          ).thenThrow(NotFoundException(message: 'not found'));
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
              commandResult = cli.run(['deployment', 'show', ...args]);
            });

            test('then throws ExitErrorException', () async {
              await expectLater(
                commandResult,
                throwsA(isA<ErrorExitException>()),
              );
            });

            test('then outputs error message', () async {
              await commandResult.onError((final e, final s) {});

              expect(logger.errorCalls, isNotEmpty);
              expect(
                logger.errorCalls.first,
                equalsErrorCall(
                  message: 'No such deployment status found.',
                  hint:
                      'Run this command to see recent deployments: '
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
          'for named proj opt with non-existing deploy id with args="--project $projectId ${Uuid().v4obj().toString()}"',
          () {
            late Future commandResult;
            setUp(() async {
              commandResult = cli.run([
                'deployment',
                'show',
                '--project',
                projectId,
                Uuid().v4obj().toString(),
              ]);
            });

            test('then throws ExitErrorException', () async {
              await expectLater(
                commandResult,
                throwsA(isA<ErrorExitException>()),
              );
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
          },
        );

        test(
          'for an invalid deploy id then a descriptive error is logged',
          () async {
            final commandResult = cli.run([
              'deployment',
              'show',
              '--project',
              projectId,
              'invalid-attempt-id',
            ]);

            await commandResult.onError((final e, final s) {});

            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first,
              equalsErrorCall(
                message: 'The requested resource did not exist.',
                hint: 'Validate the attempt id is correct.',
              ),
            );
          },
        );
      });
    });

    group('and an awaiting service stage status,', () {
      setUpAll(() async {
        final attemptStages = [
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.upload)
              .withStageStatus(DeployProgressStatus.success)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.build)
              .withBuildId('build-id-foo')
              .withStageStatus(DeployProgressStatus.success)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.deploy)
              .withStageStatus(DeployProgressStatus.success)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.service)
              .withStageStatus(DeployProgressStatus.awaiting)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
        ];

        when(
          () => client.status.getDeployAttemptStatus(
            cloudCapsuleId: projectId,
            attemptId: attemptStages.first.attemptId,
          ),
        ).thenAnswer((final _) async => attemptStages);

        when(
          () => client.status.getDeployAttemptId(
            cloudCapsuleId: projectId,
            attemptNumber: 0,
          ),
        ).thenAnswer((final _) async => attemptStages.first.attemptId);

        when(
          () => client.status.tailDeployAttemptStatus(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            attemptId: any(named: 'attemptId'),
          ),
        ).thenAnswer((final _) => Stream.fromIterable(attemptStages));
      });

      tearDownAll(() {
        reset(client.status);
      });

      group(
        'when running deployments show command to get the deploy status',
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
            expect(logger.lineCalls.map((final l) => l.line).join('\n'), '''
Tracking projectId deployment $attemptId
(Press Ctrl+C to exit)
''');
            expect(
              logger.progressCalls.map((final c) => c.message),
              containsAllInOrder([
                contains('Upload awaiting'),
                contains('Cloud build awaiting'),
                contains('Infra deploy awaiting'),
                contains('Service rollout awaiting'),
              ]),
            );
          });
        },
      );

      group(
        'when running deployments show --no-await command to get the deploy status',
        () {
          late Future commandResult;

          setUp(() async {
            commandResult = cli.run([
              'deployment',
              'show',
              '--project',
              projectId,
              '--no-await',
            ]);
          });

          test('then completes successfully', () async {
            await expectLater(commandResult, completes);
          });

          test('then outputs the status', () async {
            await commandResult;

            expect(logger.lineCalls, isNotEmpty);
            expect(logger.lineCalls.map((final l) => l.line).join('\n'), '''
Status of projectId deployment $attemptId, started at 2021-12-31 10:20:30:

Upload successful!
Cloud build successful!
Infra deploy successful!
Service rollout awaiting...''');
          });
        },
      );

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
        },
      );
    });

    group('and a failed build stage status,', () {
      setUpAll(() async {
        final attemptStages = [
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.upload)
              .withStageStatus(DeployProgressStatus.success)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.build)
              .withBuildId('build-id-foo')
              .withStageStatus(DeployProgressStatus.failure)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
        ];

        when(
          () => client.status.getDeployAttemptStatus(
            cloudCapsuleId: projectId,
            attemptId: attemptStages.first.attemptId,
          ),
        ).thenAnswer((final _) async => attemptStages);

        when(
          () => client.status.getDeployAttemptId(
            cloudCapsuleId: projectId,
            attemptNumber: 0,
          ),
        ).thenAnswer((final _) async => attemptStages.first.attemptId);

        when(
          () => client.status.tailDeployAttemptStatus(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            attemptId: any(named: 'attemptId'),
          ),
        ).thenAnswer((final _) => Stream.fromIterable(attemptStages));
      });

      tearDownAll(() {
        reset(client.status);
      });

      group(
        'when running deployments show command to get the deploy status',
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
            expect(logger.lineCalls.map((final l) => l.line).join('\n'), '''
Tracking projectId deployment $attemptId
(Press Ctrl+C to exit)
''');
            final progressMessages = logger.progressCalls.map(
              (final c) => c.message,
            );
            expect(progressMessages.length, 4);
            expect(
              progressMessages,
              containsAllInOrder([
                contains('Upload awaiting'),
                contains('Upload successful!'),
                contains('Cloud build awaiting'),
                contains('Cloud build failed! 💥'),
              ]),
            );
          });
        },
      );

      group(
        'when running deployments show --no-await command to get the deploy status',
        () {
          late Future commandResult;

          setUp(() async {
            commandResult = cli.run([
              'deployment',
              'show',
              '--project',
              projectId,
              '--no-await',
            ]);
          });

          test('then completes successfully', () async {
            await expectLater(commandResult, completes);
          });

          test('then outputs the status', () async {
            await commandResult;

            expect(logger.lineCalls, isNotEmpty);
            expect(logger.lineCalls.map((final l) => l.line).join('\n'), '''
Status of projectId deployment $attemptId, started at 2021-12-31 10:20:30:

Upload successful!
Cloud build failed! 💥''');
          });
        },
      );

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
            expect(logger.lineCalls.single.line, equals('failure'));
          });
        },
      );
    });

    group('when running deployments list command', () {
      group('with correct args to get the deployments list', () {
        final attemptId1 = Uuid().v4obj();
        final attemptId2 = Uuid().v4obj();
        setUpAll(() async {
          final buildStatuses = [
            DeployAttemptBuilder()
                .withSuccessfulDeployment()
                .withCloudCapsuleId('projectId')
                .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
                .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
                .withAttemptId(attemptId1)
                .build(),
            DeployAttemptBuilder()
                .withFailedDeployment()
                .withCloudCapsuleId('projectId')
                .withStartedAt(DateTime.parse("2021-12-31 10:10:30"))
                .withEndedAt(DateTime.parse("2021-12-31 10:10:40"))
                .withStatusInfo('Some error')
                .withAttemptId(attemptId2)
                .build(),
          ];

          when(
            () => client.status.getDeployAttempts(
              cloudCapsuleId: projectId,
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((final _) async => buildStatuses);
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
              commandResult = cli.run(['deployment', 'list', ...args]);
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
                        '# | Project   | Deploy Id                            | Status  | Started             | Finished            | Info      ',
                  ),
                  equalsLineCall(
                    line:
                        '--+-----------+--------------------------------------+---------+---------------------+---------------------+-----------',
                  ),
                  equalsLineCall(
                    line:
                        '0 | projectId | $attemptId1 | SUCCESS | 2021-12-31 10:20:30 | 2021-12-31 10:20:40 |           ',
                  ),
                  equalsLineCall(
                    line:
                        '1 | projectId | $attemptId2 | FAILURE | 2021-12-31 10:10:30 | 2021-12-31 10:10:40 | Some error',
                  ),
                ]),
              );
            });
          });
        }

        testCorrectGetStatusesCommand('with named project opt', [
          '--project',
          projectId,
        ]);
      });
    });
  });
}

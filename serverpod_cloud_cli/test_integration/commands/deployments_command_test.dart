import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../test/util/inline_tui/helpers/fake_terminal.dart';
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
      // These groups assert on the plain progressStream messages, not on the
      // interactive build-log streaming, so they use a non-interactive
      // terminal to keep exercising the showStageProgress fallback path.
      setUp(() {
        logger.inlineTerminal = FakeTerminal(hasTerminal: false);
      });

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
                  contains('Rollout awaiting'),
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
      // Asserts on the plain progressStream messages, not on the interactive
      // build-log streaming, so it uses a non-interactive terminal to keep
      // exercising the showStageProgress fallback path.
      setUp(() {
        logger.inlineTerminal = FakeTerminal(hasTerminal: false);
      });

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
                contains('Rollout awaiting'),
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

Upload successful.
Cloud build successful.
Rollout running...''');
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

          test('then outputs the single word running', () async {
            await commandResult;

            expect(logger.lineCalls, isNotEmpty);
            expect(logger.lineCalls.single.line, equals('running'));
          });
        },
      );
    });

    group('and a failed build stage status,', () {
      // Asserts on the plain progressStream messages, not on the interactive
      // build-log streaming, so it uses a non-interactive terminal to keep
      // exercising the showStageProgress fallback path.
      setUp(() {
        logger.inlineTerminal = FakeTerminal(hasTerminal: false);
      });

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

          test('then throws a failure exception', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then outputs the status', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );

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
                contains('Upload successful.'),
                contains('Cloud build awaiting'),
                contains('Cloud build failed. 💥'),
              ]),
            );
          });

          test('then the build log command hint is logged', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );

            expect(logger.terminalCommandCalls, hasLength(1));
            expect(
              logger.terminalCommandCalls.single,
              equalsTerminalCommandCall(
                command: 'scloud deployment build-log',
                message: 'To view the build log again, run this command:',
                newParagraph: true,
              ),
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

Upload successful.
Cloud build failed. 💥''');
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

        group('when executing deployments list with --format json', () {
          late Future commandResult;
          setUp(() async {
            commandResult = cli.run([
              'deployment',
              'list',
              '--project',
              projectId,
              '--format',
              'json',
            ]);
          });

          test('then emits deployment objects', () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(jsonDecode(logger.rawCalls.single.content), [
              {
                'index': 0,
                'projectId': 'projectId',
                'deployId': attemptId1.toString(),
                'status': 'SUCCESS',
                'startedAt': DateTime.parse(
                  '2021-12-31 10:20:30',
                ).toUtc().toIso8601String(),
                'finishedAt': DateTime.parse(
                  '2021-12-31 10:20:40',
                ).toUtc().toIso8601String(),
                'info': null,
              },
              {
                'index': 1,
                'projectId': 'projectId',
                'deployId': attemptId2.toString(),
                'status': 'FAILURE',
                'startedAt': DateTime.parse(
                  '2021-12-31 10:10:30',
                ).toUtc().toIso8601String(),
                'finishedAt': DateTime.parse(
                  '2021-12-31 10:10:40',
                ).toUtc().toIso8601String(),
                'info': 'Some error',
              },
            ]);
          });
        });

        group('when executing deployments list with --format yaml', () {
          late Future commandResult;
          setUp(() async {
            commandResult = cli.run([
              'deployment',
              'list',
              '--project',
              projectId,
              '--format',
              'yaml',
            ]);
          });

          test('then emits deployment objects', () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(yamlDecode(logger.rawCalls.single.content), [
              {
                'index': 0,
                'projectId': 'projectId',
                'deployId': attemptId1.toString(),
                'status': 'SUCCESS',
                'startedAt': DateTime.parse(
                  '2021-12-31 10:20:30',
                ).toUtc().toIso8601String(),
                'finishedAt': DateTime.parse(
                  '2021-12-31 10:20:40',
                ).toUtc().toIso8601String(),
                'info': null,
              },
              {
                'index': 1,
                'projectId': 'projectId',
                'deployId': attemptId2.toString(),
                'status': 'FAILURE',
                'startedAt': DateTime.parse(
                  '2021-12-31 10:10:30',
                ).toUtc().toIso8601String(),
                'finishedAt': DateTime.parse(
                  '2021-12-31 10:10:40',
                ).toUtc().toIso8601String(),
                'info': 'Some error',
              },
            ]);
          });
        });
      });
    });

    group('and a build stage that stays running, '
        'when tailing deployment status is interrupted', () {
      late StreamController<DeployAttemptStage> stageController;
      late StreamController<void> interruptController;
      final attemptId = Uuid().v4obj();

      setUp(() {
        stageController = StreamController<DeployAttemptStage>();
        interruptController = StreamController<void>.broadcast();

        when(
          () => client.status.tailDeployAttemptStatus(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            attemptId: any(named: 'attemptId'),
          ),
        ).thenAnswer((final _) => stageController.stream);
        when(
          () => client.logs.tailBuildLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            attemptId: any(named: 'attemptId'),
          ),
        ).thenAnswer((final _) => const Stream<LogRecord>.empty());
      });

      tearDown(() async {
        await stageController.close();
        await interruptController.close();
        reset(client.status);
        reset(client.logs);
      });

      test(
        'then deployment continues guidance and show command hint are logged',
        () async {
          final runningBuild = DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(attemptId)
              .withStageType(DeployStageType.build)
              .withStageStatus(DeployProgressStatus.running)
              .build();

          final tailFuture = StatusCommands.tailDeploymentStatus(
            client,
            logger: logger,
            cloudCapsuleId: projectId,
            attemptId: attemptId,
            skipUploadStage: true,
            processSignalStreamOverride: interruptController.stream,
          );

          stageController.add(runningBuild);
          await pumpEventQueue();
          interruptController.add(null);

          await expectLater(tailFuture, throwsA(isA<UserAbortException>()));

          expect(
            logger.infoCalls,
            contains(
              equalsInfoCall(
                message: 'The deployment continues in Serverpod Cloud.',
                newParagraph: true,
              ),
            ),
          );
          expect(logger.terminalCommandCalls, hasLength(1));
          expect(
            logger.terminalCommandCalls.single,
            equalsTerminalCommandCall(
              command: 'scloud deployment show',
              message: 'To view the deployment status, run this command:',
            ),
          );
        },
      );
    });

    group('and the build stage streams its log,', () {
      late StreamController<DeployAttemptStage> stageController;
      final streamingAttemptId = Uuid().v4obj();

      DeployAttemptStage buildStage(final DeployProgressStatus status) =>
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(streamingAttemptId)
              .withStageType(DeployStageType.build)
              .withStageStatus(status)
              .build();

      LogRecord logRecord(final String recordId, final String content) =>
          LogRecordBuilder()
              .withCloudIds(projectId)
              .withDeployAttemptId(streamingAttemptId)
              .withRecordId(recordId)
              .withContent(content)
              .build();

      setUp(() {
        stageController = StreamController<DeployAttemptStage>();
        when(
          () => client.status.tailDeployAttemptStatus(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            attemptId: any(named: 'attemptId'),
          ),
        ).thenAnswer((final _) => stageController.stream);
      });

      tearDown(() async {
        await stageController.close();
        reset(client.status);
        reset(client.logs);
      });

      group('given an interactive terminal', () {
        setUp(() {
          logger.inlineTerminal = FakeTerminal(hasTerminal: true);
        });

        test('and a running build stage then the build log lines are shown '
            'while running and the section clears on success', () async {
          when(
            () => client.logs.tailBuildLog(
              cloudCapsuleId: projectId,
              attemptId: streamingAttemptId,
            ),
          ).thenAnswer(
            (final _) =>
                Stream.fromIterable([logRecord('1', 'Building image...')]),
          );

          final tailFuture = StatusCommands.tailDeploymentStatus(
            client,
            logger: logger,
            cloudCapsuleId: projectId,
            attemptId: streamingAttemptId,
            skipUploadStage: true,
          );

          stageController.add(buildStage(DeployProgressStatus.running));
          await pumpEventQueue();
          stageController.add(buildStage(DeployProgressStatus.success));
          await stageController.close();

          await tailFuture;

          final terminal = logger.inlineTerminal as FakeTerminal;
          expect(terminal.output, contains('Building image...'));
          expect(terminal.output, endsWith('\x1b[?25h'));
        });

        test('and a failing build stage then the build log lines are kept in '
            'the failure output', () async {
          when(
            () => client.logs.tailBuildLog(
              cloudCapsuleId: projectId,
              attemptId: streamingAttemptId,
            ),
          ).thenAnswer(
            (final _) =>
                Stream.fromIterable([logRecord('1', 'Error: build failed')]),
          );

          final tailFuture = StatusCommands.tailDeploymentStatus(
            client,
            logger: logger,
            cloudCapsuleId: projectId,
            attemptId: streamingAttemptId,
            skipUploadStage: true,
          );

          stageController.add(buildStage(DeployProgressStatus.running));
          await pumpEventQueue();
          stageController.add(buildStage(DeployProgressStatus.failure));

          await expectLater(tailFuture, throwsA(isA<FailureException>()));

          final terminal = logger.inlineTerminal as FakeTerminal;
          expect(terminal.output, contains('Error: build failed'));
          expect(
            terminal.output,
            contains(
              'Cloud build failed. 💥'.padRight(
                StatusCommands.progressMessagePadLength,
              ),
            ),
          );
          expect(terminal.output, endsWith('\n\x1b[?25h'));
        });

        test('and a build stage that is only awaiting then no build log '
            'tail happens yet', () async {
          final tailFuture = StatusCommands.tailDeploymentStatus(
            client,
            logger: logger,
            cloudCapsuleId: projectId,
            attemptId: streamingAttemptId,
            skipUploadStage: true,
          );

          stageController.add(buildStage(DeployProgressStatus.awaiting));
          await pumpEventQueue();

          verifyNever(
            () => client.logs.tailBuildLog(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              attemptId: any(named: 'attemptId'),
            ),
          );

          stageController.add(buildStage(DeployProgressStatus.success));
          await stageController.close();
          await tailFuture;
        });

        test('and Ctrl+C during the running build stage then interrupt '
            'guidance is still logged with the log subscription unwound '
            'cleanly', () async {
          final interruptController = StreamController<void>.broadcast();
          addTearDown(interruptController.close);
          when(
            () => client.logs.tailBuildLog(
              cloudCapsuleId: projectId,
              attemptId: streamingAttemptId,
            ),
          ).thenAnswer(
            (final _) =>
                Stream.fromIterable([logRecord('1', 'Building image...')]),
          );

          final tailFuture = StatusCommands.tailDeploymentStatus(
            client,
            logger: logger,
            cloudCapsuleId: projectId,
            attemptId: streamingAttemptId,
            skipUploadStage: true,
            processSignalStreamOverride: interruptController.stream,
          );

          stageController.add(buildStage(DeployProgressStatus.running));
          await pumpEventQueue();
          interruptController.add(null);

          await expectLater(tailFuture, throwsA(isA<UserAbortException>()));

          expect(
            logger.infoCalls,
            contains(
              equalsInfoCall(
                message: 'The deployment continues in Serverpod Cloud.',
                newParagraph: true,
              ),
            ),
          );
          final terminal = logger.inlineTerminal as FakeTerminal;
          expect(terminal.output, contains('Building image...'));
          expect(terminal.output, contains('Cloud build running...'));
          expect(terminal.output, isNot(contains('Cloud build failed.')));
          expect(terminal.output, endsWith('\x1b[?25h'));
        });
      });

      test(
        'given a non-interactive terminal then no build-log tail happens',
        () async {
          logger.inlineTerminal = FakeTerminal(hasTerminal: false);

          final tailFuture = StatusCommands.tailDeploymentStatus(
            client,
            logger: logger,
            cloudCapsuleId: projectId,
            attemptId: streamingAttemptId,
            skipUploadStage: true,
          );

          stageController.add(buildStage(DeployProgressStatus.running));
          await pumpEventQueue();
          stageController.add(buildStage(DeployProgressStatus.success));
          await stageController.close();

          await tailFuture;

          verifyNever(
            () => client.logs.tailBuildLog(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              attemptId: any(named: 'attemptId'),
            ),
          );
        },
      );
    });

    group('and a failed upload stage status,', () {
      final failedUploadAttemptId = Uuid().v4obj();

      setUpAll(() async {
        final attemptStages = [
          DeployAttemptStageBuilder()
              .withCloudCapsuleId(projectId)
              .withAttemptId(failedUploadAttemptId)
              .withStageType(DeployStageType.upload)
              .withStageStatus(DeployProgressStatus.failure)
              .withStartedAt(DateTime.parse("2021-12-31 10:20:30"))
              .withEndedAt(DateTime.parse("2021-12-31 10:20:40"))
              .build(),
        ];

        when(
          () => client.status.getDeployAttemptId(
            cloudCapsuleId: projectId,
            attemptNumber: 0,
          ),
        ).thenAnswer((final _) async => failedUploadAttemptId);

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

          test('then throws a failure exception', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then the deployment show command hint is logged', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );

            expect(logger.terminalCommandCalls, hasLength(1));
            expect(
              logger.terminalCommandCalls.single,
              equalsTerminalCommandCall(
                command: 'scloud deployment show',
                message: 'To view the deployment status, run this command:',
                newParagraph: true,
              ),
            );
          });
        },
      );
    });
  });
}

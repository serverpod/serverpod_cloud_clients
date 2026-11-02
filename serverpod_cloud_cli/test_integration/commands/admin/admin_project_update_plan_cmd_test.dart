import 'dart:async';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
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
    adminUserMode: true,
  );
  final unauthenticatedClient = ClientMock(
    authKeyProvider: InMemoryKeyManager(),
  );
  final unauthenticatedCli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => unauthenticatedClient,
    ),
    adminUserMode: true,
  );

  const projectId = 'my-proj';

  setUpAll(() {
    registerFallbackValue(ProjectProfileUpdate());
  });

  tearDown(() async {
    reset(client.adminProjects);
    logger.clear();
  });

  test(
    'Given admin project update-plan command when instantiated then requires login',
    () {
      expect(
        AdminProjectUpdatePlanCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given not logged in', () {
    group(
      'when executing admin project update-plan without plan or podlet options',
      () {
        late Future commandResult;
        setUp(() async {
          commandResult = unauthenticatedCli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
            '--non-interactive',
          ]);
        });

        test('then throws a usage error naming the required options', () async {
          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (e) => e.message,
                'message',
                'At least one of --plan, --min-podlets or --max-podlets '
                    'must be given.',
              ),
            ),
          );
        });
      },
    );
  });

  group('Given authenticated', () {
    void stubSuccessfulUpdate() {
      when(
        () => client.adminProjects.updateProjectProfile(
          cloudProjectId: any(named: 'cloudProjectId'),
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((_) async {});
    }

    group(
      'when executing admin project update-plan and accepting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulUpdate();
          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
            'growth',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test(
          'then updateProjectProfile is called with the growth plan',
          () async {
            await commandResult;

            final captured = verify(
              () => client.adminProjects.updateProjectProfile(
                cloudProjectId: projectId,
                profile: captureAny(named: 'profile'),
              ),
            ).captured;
            expect(
              (captured.single as ProjectProfileUpdate).planType,
              PlanType.growth,
            );
          },
        );

        test('then command logs a confirm message to set the plan', () async {
          await commandResult;

          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to set the plan to "growth" '
                  'for project "my-proj"?',
              defaultValue: false,
            ),
          );
        });

        test('then command outputs a success message for the plan', () async {
          await commandResult;

          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Set the plan to "growth" for project "my-proj".',
              newParagraph: true,
            ),
          );
        });
      },
    );

    group(
      'when executing admin project update-plan with --yes and --format json',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulUpdate();

          commandResult = cli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
            'starter',
            '--yes',
            '--format',
            'json',
          ]);
        });

        test(
          'then emits a JSON object with the project id and plan type',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(jsonDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'planType': 'starter',
            });
          },
        );
      },
    );

    group(
      'when executing admin project update-plan with --yes and --format yaml',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulUpdate();

          commandResult = cli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
            'starter',
            '--yes',
            '--format',
            'yaml',
          ]);
        });

        test(
          'then emits a YAML object with the project id and plan type',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(yamlDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'planType': 'starter',
            });
          },
        );
      },
    );

    group(
      'when executing admin project update-plan and rejecting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulUpdate();
          logger.answerNextConfirmWith(false);

          commandResult = cli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
            'growth',
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs a confirm message to set the plan', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to set the plan to "growth" '
                  'for project "my-proj"?',
              defaultValue: false,
            ),
          );
        });

        test('then logs no success message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.successCalls, isEmpty);
        });

        test('then updateProjectProfile is not called', () async {
          try {
            await commandResult;
          } catch (_) {}

          verifyNever(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: any(named: 'cloudProjectId'),
              profile: any(named: 'profile'),
            ),
          );
        });
      },
    );

    group(
      'when executing admin project update-plan and API returns not found',
      () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: any(named: 'cloudProjectId'),
              profile: any(named: 'profile'),
            ),
          ).thenThrow(
            NotFoundException(message: 'No such project: $projectId'),
          );

          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
            'growth',
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.errorCalls, isNotEmpty);
          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message: 'The requested resource did not exist.',
              hint: 'No such project: my-proj',
            ),
          );
        });
      },
    );

    group('when executing admin project update-plan with only '
        '--min-podlets 0 --max-podlets 1 and accepting the prompt', () {
      late Future commandResult;
      setUp(() async {
        stubSuccessfulUpdate();
        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'project',
          'update-plan',
          projectId,
          '--min-podlets',
          '0',
          '--max-podlets',
          '1',
        ]);
      });

      test('then updateProjectProfile is called without a plan type', () async {
        await commandResult;

        final captured = verify(
          () => client.adminProjects.updateProjectProfile(
            cloudProjectId: projectId,
            profile: captureAny(named: 'profile'),
          ),
        ).captured;
        expect((captured.single as ProjectProfileUpdate).planType, isNull);
      });

      test(
        'then updateProjectProfile is called with min instances 0',
        () async {
          await commandResult;

          final captured = verify(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: projectId,
              profile: captureAny(named: 'profile'),
            ),
          ).captured;
          expect((captured.single as ProjectProfileUpdate).minInstances, 0);
        },
      );

      test(
        'then updateProjectProfile is called with max instances 1',
        () async {
          await commandResult;

          final captured = verify(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: projectId,
              profile: captureAny(named: 'profile'),
            ),
          ).captured;
          expect((captured.single as ProjectProfileUpdate).maxInstances, 1);
        },
      );

      test(
        'then command logs a confirm message describing the podlet change',
        () async {
          await commandResult;

          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to set min podlets to 0 and '
                  'max podlets to 1 for project "my-proj"?',
              defaultValue: false,
            ),
          );
        },
      );

      test(
        'then command outputs a success message describing the podlet change',
        () async {
          await commandResult;

          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message:
                  'Set min podlets to 0 and max podlets to 1 '
                  'for project "my-proj".',
              newParagraph: true,
            ),
          );
        },
      );
    });

    group('when executing admin project update-plan with plan growth and '
        '--min-podlets 0 and accepting the prompt', () {
      late Future commandResult;
      setUp(() async {
        stubSuccessfulUpdate();
        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'project',
          'update-plan',
          projectId,
          'growth',
          '--min-podlets',
          '0',
        ]);
      });

      test(
        'then updateProjectProfile is called with the growth plan',
        () async {
          await commandResult;

          final captured = verify(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: projectId,
              profile: captureAny(named: 'profile'),
            ),
          ).captured;
          expect(
            (captured.single as ProjectProfileUpdate).planType,
            PlanType.growth,
          );
        },
      );

      test(
        'then updateProjectProfile is called with min instances 0',
        () async {
          await commandResult;

          final captured = verify(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: projectId,
              profile: captureAny(named: 'profile'),
            ),
          ).captured;
          expect((captured.single as ProjectProfileUpdate).minInstances, 0);
        },
      );

      test(
        'then command outputs a success message describing both changes',
        () async {
          await commandResult;

          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message:
                  'Set the plan to "growth" and min podlets to 0 '
                  'for project "my-proj".',
              newParagraph: true,
            ),
          );
        },
      );
    });

    group('when executing admin project update-plan with '
        '--min-podlets 0 --max-podlets 1 --yes and --format json', () {
      late Future commandResult;
      setUp(() async {
        stubSuccessfulUpdate();

        commandResult = cli.run([
          'admin',
          'project',
          'update-plan',
          projectId,
          '--min-podlets',
          '0',
          '--max-podlets',
          '1',
          '--yes',
          '--format',
          'json',
        ]);
      });

      test(
        'then emits a JSON object with the project id and instance counts',
        () async {
          await commandResult;

          expect(jsonDecode(logger.rawCalls.single.content), {
            'projectId': projectId,
            'minInstances': 0,
            'maxInstances': 1,
          });
        },
      );
    });

    group(
      'when executing admin project update-plan without plan or podlet options',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulUpdate();

          commandResult = cli.run([
            'admin',
            'project',
            'update-plan',
            projectId,
          ]);
        });

        test('then throws a usage error naming the required options', () async {
          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (e) => e.message,
                'message',
                'At least one of --plan, --min-podlets or --max-podlets '
                    'must be given.',
              ),
            ),
          );
        });

        test('then updateProjectProfile is not called', () async {
          try {
            await commandResult;
          } catch (_) {}

          verifyNever(
            () => client.adminProjects.updateProjectProfile(
              cloudProjectId: any(named: 'cloudProjectId'),
              profile: any(named: 'profile'),
            ),
          );
        });
      },
    );

    group('when executing admin project update-plan with --min-podlets -1', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'admin',
          'project',
          'update-plan',
          projectId,
          '--min-podlets',
          '-1',
        ]);
      });

      test('then throws a usage error that -1 is below the minimum', () async {
        await expectLater(
          commandResult,
          throwsA(
            isA<UsageException>().having(
              (e) => e.message,
              'message',
              contains('-1 is below the minimum (0)'),
            ),
          ),
        );
      });
    });
  });
}

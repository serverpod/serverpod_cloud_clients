import 'dart:async';
import 'dart:convert';

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

        test('then command logs confirm message', () async {
          await commandResult;

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to update the plan of project '
                  '"my-proj" to "growth"?',
              defaultValue: false,
            ),
          );
        });

        test('then command outputs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Updated the plan of project "my-proj" to "growth".',
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

        test('then logs confirm message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to update the plan of project '
                  '"my-proj" to "growth"?',
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
  });
}

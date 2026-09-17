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
  final subscriptionId = UuidValue.fromString(
    '11111111-1111-4111-8111-111111111111',
  );

  setUpAll(() {
    registerFallbackValue(ProjectProfileUpdate());
  });

  tearDown(() async {
    reset(client.adminProjects);
    logger.clear();
  });

  test(
    'Given admin project reprocure-subscription command when instantiated then requires login',
    () {
      expect(AdminProjectReprocureCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    void stubSuccessfulReprocure() {
      when(
        () => client.adminProjects.reprocureExistingProject(
          cloudProjectId: any(named: 'cloudProjectId'),
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((_) async => subscriptionId);
    }

    group(
      'when executing admin project reprocure-subscription and accepting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulReprocure();
          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'reprocure-subscription',
            projectId,
            'starter',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test(
          'then reprocureExistingProject is called with the starter plan',
          () async {
            await commandResult;

            final captured = verify(
              () => client.adminProjects.reprocureExistingProject(
                cloudProjectId: projectId,
                profile: captureAny(named: 'profile'),
              ),
            ).captured;
            expect(
              (captured.single as ProjectProfileUpdate).planType,
              PlanType.starter,
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
                  'Are you sure you want to re-procure a new subscription for project '
                  '"$projectId" on plan "starter"?',
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
              message:
                  'Re-procured project "my-proj" on plan "starter" '
                  'with subscription 11111111-1111-4111-8111-111111111111.',
              newParagraph: true,
            ),
          );
        });
      },
    );

    group(
      'when executing admin project reprocure-subscription with --yes and --format json',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulReprocure();

          commandResult = cli.run([
            'admin',
            'project',
            'reprocure-subscription',
            projectId,
            'starter',
            '--yes',
            '--format',
            'json',
          ]);
        });

        test(
          'then emits a JSON object with the project id, plan type, and subscription id',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(jsonDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'planType': 'starter',
              'subscriptionId': subscriptionId.uuid,
            });
          },
        );
      },
    );

    group(
      'when executing admin project reprocure-subscription with --yes and --format yaml',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulReprocure();

          commandResult = cli.run([
            'admin',
            'project',
            'reprocure-subscription',
            projectId,
            'starter',
            '--yes',
            '--format',
            'yaml',
          ]);
        });

        test(
          'then emits a YAML object with the project id, plan type, and subscription id',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(yamlDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'planType': 'starter',
              'subscriptionId': subscriptionId.uuid,
            });
          },
        );
      },
    );

    group(
      'when executing admin project reprocure-subscription and rejecting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulReprocure();
          logger.answerNextConfirmWith(false);

          commandResult = cli.run([
            'admin',
            'project',
            'reprocure-subscription',
            projectId,
            'starter',
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
                  'Are you sure you want to re-procure a new subscription for project '
                  '"$projectId" on plan "starter"?',
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

        test('then reprocureExistingProject is not called', () async {
          try {
            await commandResult;
          } catch (_) {}

          verifyNever(
            () => client.adminProjects.reprocureExistingProject(
              cloudProjectId: any(named: 'cloudProjectId'),
              profile: any(named: 'profile'),
            ),
          );
        });
      },
    );

    group(
      'when executing admin project reprocure-subscription and API returns not found',
      () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminProjects.reprocureExistingProject(
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
            'reprocure-subscription',
            projectId,
            'starter',
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

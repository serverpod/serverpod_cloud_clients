import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
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

const _projectId = 'my-proj';

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

  tearDown(() async {
    reset(client.adminProjects);
    logger.clear();
  });

  test(
    'Given admin project reactivate command when instantiated then requires login',
    () {
      expect(
        AdminProjectReactivateCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given authenticated', () {
    group(
      'when executing admin project reactivate and accepting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          _stubSuccess(client);
          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'reactivate',
            _projectId,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
          verify(
            () => client.adminProjects.reactivateProject(
              cloudProjectId: _projectId,
            ),
          ).called(1);
        });

        test('then command logs confirm message', () async {
          await commandResult;

          expect(
            logger.confirmCalls.single,
            equalsConfirmCall(
              message:
                  'Are you sure you want to reactivate the project "my-proj"?',
              defaultValue: false,
            ),
          );
        });

        test('then command outputs success message', () async {
          await commandResult;

          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: 'Reactivated the project "my-proj".',
              newParagraph: true,
            ),
          );
        });
      },
    );

    group(
      'when executing admin project reactivate and rejecting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          _stubSuccess(client);
          logger.answerNextConfirmWith(false);

          commandResult = cli.run([
            'admin',
            'project',
            'reactivate',
            _projectId,
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then reactivateProject is not called', () async {
          await commandResult.catchError((_) {});

          verifyNever(
            () => client.adminProjects.reactivateProject(
              cloudProjectId: _projectId,
            ),
          );
        });
      },
    );

    group(
      'when executing admin project reactivate with --yes and --format json',
      () {
        late Future commandResult;
        setUp(() async {
          _stubSuccess(client);

          commandResult = cli.run([
            'admin',
            'project',
            'reactivate',
            _projectId,
            '--yes',
            '--format',
            'json',
          ]);
        });

        test(
          'then emits a JSON object with the project id and status',
          () async {
            await commandResult;

            expect(logger.successCalls, isEmpty);
            expect(jsonDecode(logger.rawCalls.single.content), {
              'projectId': _projectId,
              'status': 'active',
            });
          },
        );
      },
    );

    group(
      'when executing admin project reactivate with --yes and --format yaml',
      () {
        late Future commandResult;
        setUp(() async {
          _stubSuccess(client);

          commandResult = cli.run([
            'admin',
            'project',
            'reactivate',
            _projectId,
            '--yes',
            '--format',
            'yaml',
          ]);
        });

        test(
          'then emits a YAML object with the project id and status',
          () async {
            await commandResult;

            expect(logger.successCalls, isEmpty);
            expect(yamlDecode(logger.rawCalls.single.content), {
              'projectId': _projectId,
              'status': 'active',
            });
          },
        );
      },
    );

    group(
      'when executing admin project reactivate and API returns not found',
      () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminProjects.reactivateProject(
              cloudProjectId: any(named: 'cloudProjectId'),
            ),
          ).thenThrow(
            NotFoundException(message: 'No such project: $_projectId'),
          );
          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'reactivate',
            _projectId,
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error message', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls.single,
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

void _stubSuccess(ClientMock client) {
  when(
    () => client.adminProjects.reactivateProject(
      cloudProjectId: any(named: 'cloudProjectId'),
    ),
  ).thenAnswer(
    (_) async => ProjectBuilder().withCloudProjectId(_projectId).build(),
  );
}

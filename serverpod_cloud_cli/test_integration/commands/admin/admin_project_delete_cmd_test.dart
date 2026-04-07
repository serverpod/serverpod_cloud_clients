import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

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
    adminUserMode: true,
  );

  tearDown(() async {
    reset(client.adminProjects);
    logger.clear();
  });

  const projectId = 'my-proj';

  test(
    'Given admin project delete command when instantiated then requires login',
    () {
      expect(AdminProjectDeleteCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin project delete and accepting the prompt', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.deleteProject(
            cloudProjectId: any(named: 'cloudProjectId'),
          ),
        ).thenAnswer(
          (final invocation) async =>
              ProjectBuilder().withCloudProjectId(projectId).build(),
        );

        logger.answerNextConfirmWith(true);

        commandResult = cli.run(['admin', 'project', 'delete', projectId]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
        verify(
          () => client.adminProjects.deleteProject(cloudProjectId: projectId),
        ).called(1);
      });

      test('then command logs confirm message', () async {
        await commandResult;

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the project "my-proj"?',
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
            message: 'Deleted the project "my-proj".',
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing admin project delete and rejecting the prompt', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.deleteProject(
            cloudProjectId: any(named: 'cloudProjectId'),
          ),
        ).thenAnswer(
          (final invocation) async =>
              ProjectBuilder().withCloudProjectId(projectId).build(),
        );

        logger.answerNextConfirmWith(false);

        commandResult = cli.run(['admin', 'project', 'delete', projectId]);
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
            message: 'Are you sure you want to delete the project "my-proj"?',
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

      test('then deleteProject is not called', () async {
        try {
          await commandResult;
        } catch (_) {}

        verifyNever(
          () => client.adminProjects.deleteProject(cloudProjectId: projectId),
        );
      });
    });

    group('when executing admin project delete and API returns not found', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.deleteProject(
            cloudProjectId: any(named: 'cloudProjectId'),
          ),
        ).thenThrow(NotFoundException(message: 'No such project: $projectId'));

        logger.answerNextConfirmWith(true);

        commandResult = cli.run(['admin', 'project', 'delete', projectId]);
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
    });
  });
}

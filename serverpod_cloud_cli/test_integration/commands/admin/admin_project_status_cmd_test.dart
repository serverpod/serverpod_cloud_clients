import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show ErrorExitException;
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

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

  const projectId = 'my-project';

  tearDown(() async {
    logger.clear();
    reset(client);
  });

  test(
    'Given admin project status command when instantiated then requires login',
    () {
      expect(AdminProjectStatusCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin project status', () {
      setUp(() async {
        when(
          () =>
              client.adminProjects.getProjectStatus(cloudProjectId: projectId),
        ).thenAnswer(
          (_) async => AdminProjectInfoBuilder()
              .withProjectInfo(
                ProjectInfoBuilder().withProject(
                  ProjectBuilder().withCloudProjectId(projectId),
                ),
              )
              .build(),
        );

        await cli.run(['admin', 'project', 'status', projectId]);
      });

      test('then stdout contains structured project output', () {
        final output = logger.lineCalls.join('\n');
        expect(output, contains('Project'));
        expect(output, contains(projectId));
        expect(output, contains('Phase'));
        expect(output, contains('active'));
        expect(output, contains('Roles'));
        expect(output, contains('Plan'));
        expect(output, contains('Billing'));
      });
    });

    group('when the API returns NotFoundException', () {
      test('then the command fails with the server message', () async {
        when(
          () =>
              client.adminProjects.getProjectStatus(cloudProjectId: projectId),
        ).thenThrow(NotFoundException(message: 'No such project'));

        await expectLater(
          cli.run(['admin', 'project', 'status', projectId]),
          throwsA(isA<ErrorExitException>()),
        );
      });
    });

    group('when executing admin project status with --format json', () {
      setUp(() async {
        when(
          () =>
              client.adminProjects.getProjectStatus(cloudProjectId: projectId),
        ).thenAnswer(
          (_) async => AdminProjectInfoBuilder()
              .withProjectInfo(
                ProjectInfoBuilder().withProject(
                  ProjectBuilder().withCloudProjectId(projectId),
                ),
              )
              .build(),
        );

        await cli.run([
          'admin',
          'project',
          'status',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then raw json contains cloud project id', () {
        final decoded =
            jsonDecode(logger.rawCalls.single.content) as Map<String, dynamic>;
        final projectInfo = decoded['projectInfo'] as Map<String, dynamic>;
        final project = projectInfo['project'] as Map<String, dynamic>;
        expect(project['cloudProjectId'], projectId);
        expect(decoded['status'], 'active');
        expect(decoded.containsKey('suspendedAt'), isFalse);
        expect(decoded.containsKey('suspensionReason'), isFalse);
      });
    });

    group('when executing admin project status with --format yaml', () {
      setUp(() async {
        when(
          () =>
              client.adminProjects.getProjectStatus(cloudProjectId: projectId),
        ).thenAnswer(
          (_) async => AdminProjectInfoBuilder()
              .withProjectInfo(
                ProjectInfoBuilder().withProject(
                  ProjectBuilder()
                      .withCloudProjectId(projectId)
                      .withRoles(const []),
                ),
              )
              .build(),
        );

        await cli.run([
          'admin',
          'project',
          'status',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then raw yaml contains empty project roles list', () {
        final decoded =
            yamlDecode(logger.rawCalls.single.content) as Map<Object?, Object?>;
        final projectInfo = decoded['projectInfo'] as Map<Object?, Object?>;
        final project = projectInfo['project'] as Map<Object?, Object?>;
        expect(project['roles'], isEmpty);
      });
    });
  });
}

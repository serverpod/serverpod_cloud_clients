import 'dart:async';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

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
    logger.clear();
  });

  test(
    'Given admin project list command when instantiated then requires login',
    () {
      expect(AdminListProjectsCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin project list', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.listProjectsInfo(
            includeArchived: any(named: 'includeArchived', that: isTrue),
            includeLatestDeployAttemptTime: any(
              named: 'includeLatestDeployAttemptTime',
              that: isTrue,
            ),
          ),
        ).thenAnswer(
          (final invocation) async => Future.value([
            ProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withCloudProjectId('projectId')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .build(),
            ProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withArchivedAt(DateTime.parse('2025-07-02T12:10:00'))
                      .withCloudProjectId('projectId2')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      )
                      .withDeveloperUser(
                        UserBuilder().withEmail('dev@example.com').build(),
                      ),
                )
                .build(),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'project',
          'list',
          '--include-archived',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs user list', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line:
                  'Project Id | Created At (local)  | Archived At (local) | Last Deploy Attempt | Owner            | Users                                              ',
            ),
            equalsLineCall(
              line:
                  '-----------+---------------------+---------------------+---------------------+------------------+----------------------------------------------------',
            ),
            equalsLineCall(
              line:
                  'projectId  | 2025-07-02 11:00:00 |                     |                     | test@example.com | Admin: test@example.com                            ',
            ),
            equalsLineCall(
              line:
                  'projectId2 | 2025-07-02 11:00:00 | 2025-07-02 12:10:00 |                     | test@example.com | Admin: test@example.com; Developer: dev@example.com',
            ),
          ]),
        );
      });
    });
  });
}

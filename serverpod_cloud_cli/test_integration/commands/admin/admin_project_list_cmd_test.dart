import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show Project, Role, User, UserRoleMembership;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
    adminUserMode: true,
  );

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  test(
      'Given admin list-projects command when instantiated then requires login',
      () {
    expect(AdminListProjectsCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing admin list-projects', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'admin',
          'list-projects',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        await commandResult.catchError((final _) {});

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message: 'This command requires you to be logged in.',
            ));
      });
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing admin list-projects', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminProjects.listProjects(
              includeArchived: any(named: 'includeArchived', that: isTrue),
            )).thenAnswer(
          (final invocation) async => Future.value([
            Project(
                id: 1,
                createdAt: DateTime.parse('2025-07-02T11:00:00'),
                cloudProjectId: 'projectId',
                roles: [
                  Role(
                    id: 11,
                    projectId: 1,
                    name: 'Owners',
                    projectScopes: ['P0-all'],
                    memberships: [
                      UserRoleMembership(
                        userId: 1,
                        roleId: 11,
                        user: User(
                          id: 21,
                          email: 'test@example.com',
                        ),
                      ),
                    ],
                  ),
                ]),
            Project(
                id: 2,
                createdAt: DateTime.parse('2025-07-02T12:00:00'),
                archivedAt: DateTime.parse('2025-07-02T12:10:00'),
                cloudProjectId: 'projectId2',
                roles: [
                  Role(
                    id: 12,
                    projectId: 2,
                    name: 'Owners',
                    projectScopes: ['P0-all'],
                    memberships: [
                      UserRoleMembership(
                        userId: 21,
                        roleId: 12,
                        user: User(
                          id: 21,
                          email: 'test@example.com',
                        ),
                      ),
                    ],
                  ),
                ]),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'list-projects',
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
                    'Project Id | Created at (local)  | Archived at (local) | Owners                  '),
            equalsLineCall(
                line:
                    '-----------+---------------------+---------------------+-------------------------'),
            equalsLineCall(
                line:
                    'projectId  | 2025-07-02 11:00:00 |                     | Owners: test@example.com'),
            equalsLineCall(
                line:
                    'projectId2 | 2025-07-02 12:00:00 | 2025-07-02 12:10:00 | Owners: test@example.com'),
          ]),
        );
      });
    });
  });
}

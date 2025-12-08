import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show Role, User, UserRoleMembership;
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user_command.dart';
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
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
  );

  const projectId = 'projectId';

  tearDown(() async {
    logger.clear();
  });

  test('Given user list command when instantiated then requires login', () {
    expect(ProjectUserListCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    group('when executing user list', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.users.listUsersInProject(
              cloudProjectId: any(named: 'cloudProjectId'),
            )).thenAnswer(
          (final invocation) async => Future.value([
            User(
              userAuthId: 'userAuthId',
              email: 'test@example.com',
              memberships: [
                UserRoleMembership(
                  userId: 1,
                  roleId: 1,
                  role: Role(
                    projectId: 1,
                    name: 'Admin',
                    projectScopes: [],
                  ),
                ),
              ],
            ),
          ]),
        );

        commandResult = cli.run([
          'project',
          'user',
          'list',
          '--project',
          projectId,
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
                line: 'User             | Project   | Project roles'),
            equalsLineCall(
                line: '-----------------+-----------+--------------'),
            equalsLineCall(
                line: 'test@example.com | projectId | Admin        '),
          ]),
        );
      });
    });
  });
}

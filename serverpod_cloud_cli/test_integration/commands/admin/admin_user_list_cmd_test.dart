import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show UserAccountStatus;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_users_commands.dart';
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

  test('Given admin list-users command when instantiated then requires login',
      () {
    expect(AdminListUsersCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    group('when executing admin list-users', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminUsers.listUsers(
              cloudProjectId: any(named: 'cloudProjectId'),
              ofAccountStatus: any(named: 'ofAccountStatus'),
              includeArchived: any(named: 'includeArchived'),
            )).thenAnswer(
          (final invocation) async => Future.value([
            UserBuilder()
                .withEmail('test@example.com')
                .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                .withAccountStatus(UserAccountStatus.registered)
                .build(),
            UserBuilder()
                .withEmail('test2@example.com')
                .withCreatedAt(DateTime.parse('2025-07-02T12:00:00'))
                .withAccountStatus(UserAccountStatus.invited)
                .withArchivedAt(DateTime.parse('2025-07-02T12:10:00'))
                .build(),
          ]),
        );
        when(() => client.adminProcurement.listProcuredProducts(
              userEmail: any(named: 'userEmail'),
            )).thenAnswer(
          (final invocation) async => Future.value([
            ('test-plan', 'PlanProduct'),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'list-users',
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
                    'User              | Account status | Created at (local)  | Archived at (local) | Subscribed Plans'),
            equalsLineCall(
                line:
                    '------------------+----------------+---------------------+---------------------+-----------------'),
            equalsLineCall(
                line:
                    'test@example.com  | registered     | 2025-07-02 11:00:00 |                     | test-plan       '),
            equalsLineCall(
                line:
                    'test2@example.com | invited        | 2025-07-02 12:00:00 | 2025-07-02 12:10:00 |                 '),
          ]),
        );
      });
    });
  });
}

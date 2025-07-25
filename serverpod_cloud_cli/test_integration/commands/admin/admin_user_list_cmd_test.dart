import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show User, UserAccountStatus;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_users_commands.dart';
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

  test('Given admin list-users command when instantiated then requires login',
      () {
    expect(AdminListUsersCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing admin list-users', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'admin',
          'list-users',
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

    group('when executing admin list-users', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminUsers.listUsers(
              cloudProjectId: any(named: 'cloudProjectId'),
              ofAccountStatus: any(named: 'ofAccountStatus'),
              includeArchived: any(named: 'includeArchived'),
            )).thenAnswer(
          (final invocation) async => Future.value([
            User(
              createdAt: DateTime.parse('2025-07-02T11:00:00'),
              userAuthId: 'userAuthId',
              email: 'test@example.com',
              accountStatus: UserAccountStatus.registered,
              maxOwnedProjects: 5,
            ),
            User(
              createdAt: DateTime.parse('2025-07-02T12:00:00'),
              archivedAt: DateTime.parse('2025-07-02T12:10:00'),
              userAuthId: 'userAuthId2',
              email: 'test2@example.com',
              accountStatus: UserAccountStatus.invited,
              maxOwnedProjects: 5,
            ),
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
                    'User              | Account status | Max owned projects | Created at (local)  | Archived at (local)'),
            equalsLineCall(
                line:
                    '------------------+----------------+--------------------+---------------------+--------------------'),
            equalsLineCall(
                line:
                    'test@example.com  | registered     | 5                  | 2025-07-02 11:00:00 |                    '),
            equalsLineCall(
                line:
                    'test2@example.com | invited        | 5                  | 2025-07-02 12:00:00 | 2025-07-02 12:10:00'),
          ]),
        );
      });
    });
  });
}

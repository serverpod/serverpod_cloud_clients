import 'dart:async';

import 'package:ground_control_client/ground_control_client_mock.dart';
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

  test('Given admin invite-user command when instantiated then requires login',
      () {
    expect(AdminInviteUserCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing admin invite-user', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'admin',
          'invite-user',
          '--user',
          'test@example.com',
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

    group('when executing admin invite-user', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminUsers.inviteUser(
              email: any(named: 'email'),
              maxOwnedProjectsQuota: any(named: 'maxOwnedProjectsQuota'),
            )).thenAnswer(
          (final invocation) async => Future.value(),
        );

        commandResult = cli.run([
          'admin',
          'invite-user',
          '--user',
          'test@example.com',
          '--max-owned-projects',
          '5',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs user list', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'User invited to Serverpod Cloud.',
            newParagraph: true,
          ),
        );
      });
    });
  });
}

import 'dart:async';

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

  test('Given admin invite-user command when instantiated then requires login',
      () {
    expect(AdminInviteUserCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    group('when executing admin invite-user', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminUsers.inviteUser(
              email: any(named: 'email'),
            )).thenAnswer(
          (final invocation) async => Future.value(),
        );

        commandResult = cli.run([
          'admin',
          'invite-user',
          '--user',
          'test@example.com',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs success message', () async {
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

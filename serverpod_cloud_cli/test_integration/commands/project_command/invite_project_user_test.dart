import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show NotFoundException;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
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

  test(
      'Given project invite user command when instantiated then requires login',
      () {
    expect(ProjectUserInviteCommand(logger: logger).requireLogin, isTrue);
  });

  test(
      'Given project revoke user command when instantiated then requires login',
      () {
    expect(ProjectUserRevokeCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    group('when executing project invite user', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.inviteUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              assignRoleNames: any(named: 'assignRoleNames'),
            )).thenAnswer(
          (final invocation) async => Future.value(),
        );

        commandResult = cli.run([
          'project',
          'user',
          'invite',
          'test@example.com',
          '--project',
          projectId,
        ]);
      });

      test('then command completes successfully and logs success message',
          () async {
        await expectLater(commandResult, completes);

        expect(logger.successCalls, hasLength(1));
        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'User invited to the project with roles: admin.',
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing project invite with non-existent user', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.inviteUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              assignRoleNames: any(named: 'assignRoleNames'),
            )).thenThrow(
          NotFoundException(message: 'User not found.'),
        );

        commandResult = cli.run([
          'project',
          'user',
          'invite',
          'test@example.com',
          '--project',
          projectId,
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
              message: 'User not found.',
            ));
      });
    });

    group('when executing project revoke user and user has roles', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.revokeUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              unassignRoleNames: any(named: 'unassignRoleNames'),
              unassignAllRoles: any(named: 'unassignAllRoles'),
            )).thenAnswer(
          (final invocation) async => Future.value(['admin']),
        );

        commandResult = cli.run([
          'project',
          'user',
          'revoke',
          'test@example.com',
          '--project',
          projectId,
        ]);
      });

      test('then command completes successfully and logs success message',
          () async {
        await expectLater(commandResult, completes);

        expect(logger.successCalls, hasLength(1));
        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message:
                "Revoked all access roles of the user from the project: admin",
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing project revoke user but user has no roles', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.revokeUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              unassignRoleNames: any(named: 'unassignRoleNames'),
              unassignAllRoles: any(named: 'unassignAllRoles'),
            )).thenAnswer(
          (final invocation) async => Future.value([]),
        );

        commandResult = cli.run([
          'project',
          'user',
          'revoke',
          'test@example.com',
          '--project',
          projectId,
        ]);
      });

      test('then command completes successfully and logs info message',
          () async {
        await expectLater(commandResult, completes);

        expect(logger.infoCalls, hasLength(1));
        expect(
          logger.infoCalls.single,
          equalsInfoCall(
            message: "The user has no access roles to revoke on the project.",
          ),
        );
      });
    });
  });
}

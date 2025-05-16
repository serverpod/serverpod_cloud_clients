@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show NotFoundException;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger(printToStdout: true);
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  const projectId = 'projectId';

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  test(
      'Given project invite user command when instantiated then requires login',
      () {
    expect(ProjectInviteUserCommand(logger: logger).requireLogin, isTrue);
  });

  test(
      'Given project revoke user command when instantiated then requires login',
      () {
    expect(ProjectRevokeUserCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    group('when executing project invite user', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'invite',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--role',
          'owner',
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

    group('when executing project revoke user', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'revoke',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--role',
          'owner',
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

    group('when executing project invite user', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.attachUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              assignRoleNames: any(named: 'assignRoleNames'),
            )).thenAnswer(
          (final invocation) async => Future.value(),
        );

        commandResult = cli.run([
          'project',
          'invite',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--role',
          'owner',
        ]);
      });

      test('then command completes successfully and logs success message',
          () async {
        await expectLater(commandResult, completes);

        expect(logger.successCalls, hasLength(1));
        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'User invited to the project with roles: owner.',
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing project invite with non-existent user', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.attachUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              assignRoleNames: any(named: 'assignRoleNames'),
            )).thenThrow(
          NotFoundException(message: 'User not found.'),
        );

        commandResult = cli.run([
          'project',
          'invite',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--role',
          'owner',
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

    group('when executing project revoke user with specific role', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.detachUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              unassignRoleNames: any(named: 'unassignRoleNames'),
              unassignAllRoles: any(named: 'unassignAllRoles'),
            )).thenAnswer(
          (final invocation) async => Future.value(['owner']),
        );

        commandResult = cli.run([
          'project',
          'revoke',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--role',
          'owner',
        ]);
      });

      test('then command completes successfully and logs success message',
          () async {
        await expectLater(commandResult, completes);

        expect(logger.successCalls, hasLength(1));
        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Revoked access roles of the user from the project: owner',
            newParagraph: true,
          ),
        );
      });
    });

    group(
        'when executing project revoke user for all roles and user has a role',
        () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.detachUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              unassignRoleNames: any(named: 'unassignRoleNames'),
              unassignAllRoles: any(named: 'unassignAllRoles'),
            )).thenAnswer(
          (final invocation) async => Future.value(['owner']),
        );

        commandResult = cli.run([
          'project',
          'revoke',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--all',
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
                "Revoked all access roles of the user from the project: owner",
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing project revoke user with specific, non-assigned role',
        () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.detachUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              unassignRoleNames: any(named: 'unassignRoleNames'),
              unassignAllRoles: any(named: 'unassignAllRoles'),
            )).thenAnswer(
          (final invocation) async => Future.value([]),
        );

        commandResult = cli.run([
          'project',
          'revoke',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--role',
          'owner',
        ]);
      });

      test('then command completes successfully and logs info message',
          () async {
        await expectLater(commandResult, completes);

        expect(logger.infoCalls, hasLength(1));
        expect(
          logger.infoCalls.single,
          equalsInfoCall(
            message:
                'The user does not have any of the specified project roles.',
          ),
        );
      });
    });

    group(
        'when executing project revoke user for all roles but user has no roles',
        () {
      late Future commandResult;
      setUp(() async {
        when(() => client.projects.detachUser(
              cloudProjectId: any(named: 'cloudProjectId'),
              email: any(named: 'email'),
              unassignRoleNames: any(named: 'unassignRoleNames'),
              unassignAllRoles: any(named: 'unassignAllRoles'),
            )).thenAnswer(
          (final invocation) async => Future.value([]),
        );

        commandResult = cli.run([
          'project',
          'revoke',
          '--project',
          projectId,
          '--user',
          'test@example.com',
          '--all',
        ]);
      });

      test('then command completes successfully and logs success message',
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

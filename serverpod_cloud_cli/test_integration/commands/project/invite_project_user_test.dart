import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart'
    show
        NotFoundException,
        ProcurementDeniedException,
        ProcurementDeniedReason,
        ProjectRole;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user/user_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(<ProjectRole>[]);
    registerFallbackValue(ProjectRole.admin);
  });

  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
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
    },
  );

  test(
    'Given project revoke user command when instantiated then requires login',
    () {
      expect(ProjectUserRevokeCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing project invite user', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.projects.inviteUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenAnswer((invocation) async => Future.value());

        commandResult = cli.run([
          'project',
          'user',
          'invite',
          'test@example.com',
          '--project',
          projectId,
        ]);
      });

      test(
        'then command completes successfully and logs success message',
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
        },
      );
    });

    group('when executing project invite with non-existent user', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.projects.inviteUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenThrow(NotFoundException(message: 'User not found.'));

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
        await commandResult.catchError((_) {});

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(message: 'User not found.'),
        );
      });
    });

    group('when the plan does not include inviting users', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.projects.inviteUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenThrow(
          ProcurementDeniedException(
            message: "Inviting users is not available for this project's plan.",
            reason: ProcurementDeniedReason.productNotAvailable,
          ),
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

      test('then logs the denial with the plan upgrade hint', () async {
        await commandResult.catchError((_) {});

        final error = logger.errorCalls.single;
        expect(
          error.message,
          "Inviting users is not available for this project's plan.",
        );
        expect(
          error.hint,
          startsWith(
            'Inviting users to a project is available on the Growth plan.\n',
          ),
        );
        expect(error.hint, contains('/project/$projectId/plan-and-settings'));
      });
    });

    group('when the account has no payment method', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.projects.inviteUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenThrow(
          ProcurementDeniedException(
            message: 'The account has no valid payment method',
            reason: ProcurementDeniedReason.paymentMethodRequired,
          ),
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

      test('then logs the common payment method error', () async {
        await commandResult.catchError((_) {});

        expect(logger.errorCalls.single.message, 'You need a payment method!');
      });
    });

    group('when executing project revoke user and user has roles', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.projects.revokeUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer(
          (invocation) async => Future.value([ProjectRole.admin.name]),
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

      test(
        'then command completes successfully and logs success message',
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
        },
      );
    });

    group('when executing project revoke user but user has no roles', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.projects.revokeUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer((invocation) async => Future.value([]));

        commandResult = cli.run([
          'project',
          'user',
          'revoke',
          'test@example.com',
          '--project',
          projectId,
        ]);
      });

      test(
        'then command completes successfully and logs info message',
        () async {
          await expectLater(commandResult, completes);

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(
              message: "The user has no access roles to revoke on the project.",
            ),
          );
        },
      );
    });
  });
}

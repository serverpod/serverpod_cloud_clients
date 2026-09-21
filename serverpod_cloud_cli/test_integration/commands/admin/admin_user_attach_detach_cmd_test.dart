import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart'
    show NotFoundException, ProjectRole;
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/users/admin_users_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

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
    adminUserMode: true,
  );

  const projectId = 'my-project';
  const userEmail = 'test@example.com';

  tearDown(() async {
    logger.clear();
    reset(client);
  });

  test(
    'Given admin user attach command when instantiated then requires login',
    () {
      expect(AdminUserAttachCommand(logger: logger).requireLogin, isTrue);
    },
  );

  test(
    'Given admin user detach command when instantiated then requires login',
    () {
      expect(AdminUserDetachCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin user attach', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.attachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenAnswer((_) async {});

        commandResult = cli.run([
          'admin',
          'user',
          'attach',
          projectId,
          userEmail,
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs success message', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'User attached to the project with roles: admin.',
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing admin user attach with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.attachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenAnswer((_) async {});

        commandResult = cli.run([
          'admin',
          'user',
          'attach',
          projectId,
          userEmail,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML object with the assigned roles', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), {
          'roles': ['admin'],
        });
      });
    });

    group('when executing admin user attach with --format json', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.attachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenAnswer((_) async {});

        commandResult = cli.run([
          'admin',
          'user',
          'attach',
          projectId,
          userEmail,
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON object with the assigned roles', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'roles': ['admin'],
        });
      });
    });

    group('when executing admin user attach with unknown user', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.attachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            assignRoles: any(named: 'assignRoles'),
          ),
        ).thenThrow(NotFoundException(message: 'User not found'));

        commandResult = cli.run([
          'admin',
          'user',
          'attach',
          projectId,
          userEmail,
        ]);
      });

      test('then command fails with error exit', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });
    });

    group('when executing admin user detach without role', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.detachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer((_) async => ['admin']);

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'user',
          'detach',
          projectId,
          userEmail,
        ]);
      });

      test(
        'then command completes successfully and detaches all roles',
        () async {
          await expectLater(commandResult, completes);

          verify(
            () => client.adminUsers.detachUser(
              cloudProjectId: projectId,
              email: userEmail,
              unassignRoles: const [],
              unassignAllRoles: true,
            ),
          ).called(1);
        },
      );

      test('then command outputs success message', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message:
                'Detached all access roles of the user from the project: admin',
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing admin user detach with --yes and --format json', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.detachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer((_) async => ['admin']);

        commandResult = cli.run([
          'admin',
          'user',
          'detach',
          projectId,
          userEmail,
          '--yes',
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON object with the unassigned roles', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'unassigned': ['admin'],
        });
      });
    });

    group('when executing admin user detach with --yes and --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.detachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer((_) async => ['admin']);

        commandResult = cli.run([
          'admin',
          'user',
          'detach',
          projectId,
          userEmail,
          '--yes',
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML object with the unassigned roles', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), {
          'unassigned': ['admin'],
        });
      });
    });

    group('when executing admin user detach and rejecting the prompt', () {
      late Future commandResult;

      setUp(() async {
        reset(client.adminUsers);

        when(
          () => client.adminUsers.detachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer((_) async => ['admin']);

        logger.answerNextConfirmWith(false);

        commandResult = cli.run([
          'admin',
          'user',
          'detach',
          projectId,
          userEmail,
        ]);
      });

      test('then command aborts without calling the API', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        verifyNever(
          () => client.adminUsers.detachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        );
      });
    });

    group('when executing admin user detach with role', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminUsers.detachUser(
            cloudProjectId: any(named: 'cloudProjectId'),
            email: any(named: 'email'),
            unassignRoles: any(named: 'unassignRoles'),
            unassignAllRoles: any(named: 'unassignAllRoles'),
          ),
        ).thenAnswer((_) async => ['admin']);

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'user',
          'detach',
          projectId,
          userEmail,
          'admin',
        ]);
      });

      test('then detach is called with the specified role', () async {
        await commandResult.catchError((_) {});

        verify(
          () => client.adminUsers.detachUser(
            cloudProjectId: projectId,
            email: userEmail,
            unassignRoles: const [ProjectRole.admin],
            unassignAllRoles: false,
          ),
        ).called(1);
      });
    });
  });
}

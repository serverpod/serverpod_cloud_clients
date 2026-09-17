import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

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
      apiClientFactory: (globalCfg) => client,
    ),
    adminUserMode: true,
  );

  const projectId = 'my-proj';
  const ownerEmail = 'new-owner@example.com';
  final ownerId = Uuid().v4obj();

  setUpAll(() {
    registerFallbackValue(ownerId);
  });

  tearDown(() async {
    reset(client.adminProjects);
    reset(client.adminUsers);
    logger.clear();
  });

  test(
    'Given admin project change-owner command when instantiated then requires login',
    () {
      expect(
        AdminProjectChangeOwnerCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given authenticated', () {
    void stubSuccessfulChange() {
      when(
        () => client.adminUsers.getUser(
          email: any(named: 'email'),
          includeArchived: any(named: 'includeArchived'),
        ),
      ).thenAnswer(
        (_) async =>
            UserBuilder().withEmail(ownerEmail).withOwnerId(ownerId).build(),
      );
      when(
        () => client.adminProjects.changeProjectOwner(
          cloudProjectId: any(named: 'cloudProjectId'),
          newOwnerId: any(named: 'newOwnerId'),
        ),
      ).thenAnswer((_) async {});
    }

    group(
      'when executing admin project change-owner and accepting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulChange();
          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'change-owner',
            projectId,
            ownerEmail,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
          verify(
            () => client.adminProjects.changeProjectOwner(
              cloudProjectId: projectId,
              newOwnerId: ownerId,
            ),
          ).called(1);
        });

        test('then command logs confirm message', () async {
          await commandResult;

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to change the owner of project '
                  '"my-proj" to "new-owner@example.com"?',
              defaultValue: false,
            ),
          );
        });

        test('then command outputs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message:
                  'Changed the owner of project "my-proj" '
                  'to "new-owner@example.com".',
              newParagraph: true,
            ),
          );
        });
      },
    );

    group(
      'when executing admin project change-owner with --yes and --format json',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulChange();

          commandResult = cli.run([
            'admin',
            'project',
            'change-owner',
            projectId,
            ownerEmail,
            '--yes',
            '--format',
            'json',
          ]);
        });

        test(
          'then emits a JSON object with the project id and owner email',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(jsonDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'ownerEmail': ownerEmail,
            });
          },
        );
      },
    );

    group(
      'when executing admin project change-owner with --yes and --format yaml',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulChange();

          commandResult = cli.run([
            'admin',
            'project',
            'change-owner',
            projectId,
            ownerEmail,
            '--yes',
            '--format',
            'yaml',
          ]);
        });

        test(
          'then emits a YAML object with the project id and owner email',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(yamlDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'ownerEmail': ownerEmail,
            });
          },
        );
      },
    );

    group(
      'when executing admin project change-owner and rejecting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulChange();
          logger.answerNextConfirmWith(false);

          commandResult = cli.run([
            'admin',
            'project',
            'change-owner',
            projectId,
            ownerEmail,
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs confirm message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Are you sure you want to change the owner of project '
                  '"my-proj" to "new-owner@example.com"?',
              defaultValue: false,
            ),
          );
        });

        test('then logs no success message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.successCalls, isEmpty);
        });

        test('then changeProjectOwner is not called', () async {
          try {
            await commandResult;
          } catch (_) {}

          verifyNever(
            () => client.adminProjects.changeProjectOwner(
              cloudProjectId: any(named: 'cloudProjectId'),
              newOwnerId: any(named: 'newOwnerId'),
            ),
          );
        });
      },
    );

    group(
      'when executing admin project change-owner and API returns not found',
      () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminUsers.getUser(
              email: any(named: 'email'),
              includeArchived: any(named: 'includeArchived'),
            ),
          ).thenAnswer(
            (_) async => UserBuilder()
                .withEmail(ownerEmail)
                .withOwnerId(ownerId)
                .build(),
          );
          when(
            () => client.adminProjects.changeProjectOwner(
              cloudProjectId: any(named: 'cloudProjectId'),
              newOwnerId: any(named: 'newOwnerId'),
            ),
          ).thenThrow(
            NotFoundException(message: 'No such project: $projectId'),
          );

          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'change-owner',
            projectId,
            ownerEmail,
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.errorCalls, isNotEmpty);
          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message: 'The requested resource did not exist.',
              hint: 'No such project: my-proj',
            ),
          );
        });
      },
    );

    group('when executing admin project change-owner for an unknown user', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminUsers.getUser(
            email: any(named: 'email'),
            includeArchived: any(named: 'includeArchived'),
          ),
        ).thenThrow(NotFoundException(message: 'User not found'));

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'project',
          'change-owner',
          projectId,
          ownerEmail,
        ]);
      });

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'The requested resource did not exist.',
            hint: 'User not found',
          ),
        );
      });

      test('then changeProjectOwner is not called', () async {
        try {
          await commandResult;
        } catch (_) {}

        verifyNever(
          () => client.adminProjects.changeProjectOwner(
            cloudProjectId: any(named: 'cloudProjectId'),
            newOwnerId: any(named: 'newOwnerId'),
          ),
        );
      });
    });
  });
}

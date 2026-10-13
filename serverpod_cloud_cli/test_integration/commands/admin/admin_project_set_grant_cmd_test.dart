import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
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

  tearDown(() async {
    reset(client.adminGrants);
    logger.clear();
  });

  test(
    'Given admin project set-grant command when instantiated then requires login',
    () {
      expect(AdminProjectSetGrantCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    void stubSuccessfulSet() {
      when(
        () => client.adminGrants.setCapsuleGrant(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          grant: any(named: 'grant'),
          amount: any(named: 'amount'),
        ),
      ).thenAnswer((_) async {});
    }

    group('when executing admin project set-grant and accepting the prompt', () {
      late Future commandResult;
      setUp(() async {
        stubSuccessfulSet();
        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'project',
          'set-grant',
          projectId,
          'databaseBackups',
          '--amount',
          '1',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test(
        'then setCapsuleGrant is called with the project id as the capsule id',
        () async {
          await commandResult;

          verify(
            () => client.adminGrants.setCapsuleGrant(
              cloudCapsuleId: projectId,
              grant: 'databaseBackups',
              amount: 1,
            ),
          ).called(1);
        },
      );

      test('then command logs confirm message', () async {
        await commandResult;

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message:
                'Are you sure you want to set databaseBackups to 1 '
                'for project "my-proj"?',
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
            message: 'Set databaseBackups to 1 for project "my-proj".',
            newParagraph: true,
          ),
        );
      });
    });

    group(
      'when executing admin project set-grant with --yes and --format json',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulSet();

          commandResult = cli.run([
            'admin',
            'project',
            'set-grant',
            projectId,
            'futureCalls',
            '--amount',
            '0',
            '--yes',
            '--format',
            'json',
          ]);
        });

        test(
          'then emits a JSON object with the project id, grant, and amount',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(jsonDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'grant': 'futureCalls',
              'amount': 0,
            });
          },
        );
      },
    );

    group(
      'when executing admin project set-grant with --yes and --format yaml',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulSet();

          commandResult = cli.run([
            'admin',
            'project',
            'set-grant',
            projectId,
            'databaseBackups',
            '--amount',
            '1',
            '--yes',
            '--format',
            'yaml',
          ]);
        });

        test(
          'then emits a YAML object with the project id, grant, and amount',
          () async {
            await commandResult;

            expect(logger.lineCalls, isEmpty);
            expect(logger.successCalls, isEmpty);
            expect(yamlDecode(logger.rawCalls.single.content), {
              'projectId': projectId,
              'grant': 'databaseBackups',
              'amount': 1,
            });
          },
        );
      },
    );

    group(
      'when executing admin project set-grant and rejecting the prompt',
      () {
        late Future commandResult;
        setUp(() async {
          stubSuccessfulSet();
          logger.answerNextConfirmWith(false);

          commandResult = cli.run([
            'admin',
            'project',
            'set-grant',
            projectId,
            'databaseBackups',
            '--amount',
            '1',
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then setCapsuleGrant is not called', () async {
          try {
            await commandResult;
          } catch (_) {}

          verifyNever(
            () => client.adminGrants.setCapsuleGrant(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              grant: any(named: 'grant'),
              amount: any(named: 'amount'),
            ),
          );
        });
      },
    );

    group(
      'when executing admin project set-grant and the project is not found',
      () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminGrants.setCapsuleGrant(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              grant: any(named: 'grant'),
              amount: any(named: 'amount'),
            ),
          ).thenThrow(
            NotFoundException(message: 'Capsule $projectId not found'),
          );

          logger.answerNextConfirmWith(true);

          commandResult = cli.run([
            'admin',
            'project',
            'set-grant',
            projectId,
            'databaseBackups',
            '--amount',
            '1',
          ]);
        });

        test('then command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs the not found message', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.errorCalls, isNotEmpty);
          expect(
            logger.errorCalls.first,
            equalsErrorCall(message: 'Capsule $projectId not found'),
          );
        });
      },
    );
  });
}

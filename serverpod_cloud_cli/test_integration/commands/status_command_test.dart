import 'dart:async';

import 'package:meta/meta.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client_mock.dart';

import '../../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();
  final version = Version.parse('0.0.1');
  final client = ClientMock();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() {
    logger.clear();
  });

  const projectId = 'projectId';

  group('Given unauthenticated', () {
    setUpAll(() {
      when(() => client.status.getDeployAttempts(
            cloudEnvironmentId: any(named: 'cloudEnvironmentId'),
            limit: any(named: 'limit'),
          )).thenThrow(ServerpodClientUnauthorized());

      when(() => client.status.getDeployAttemptId(
            cloudEnvironmentId: any(named: 'cloudEnvironmentId'),
            attemptNumber: any(named: 'attemptNumber'),
          )).thenThrow(ServerpodClientUnauthorized());
    });

    tearDownAll(() {
      reset(client.status);
    });

    group('when running status without options', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'status',
          '--project-id',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'Failed to get deployment status: ServerpodClientException: Unauthorized, statusCode = 401',
        );
      });
    });

    group('when running status with --build-log', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'status',
          '--project-id',
          projectId,
          '--build-log',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'Failed to get build log: ServerpodClientException: Unauthorized, statusCode = 401',
        );
      });
    });

    group('when running status with --list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'status',
          '--project-id',
          projectId,
          '--list',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'Failed to get deployments list: ServerpodClientException: Unauthorized, statusCode = 401',
        );
      });
    });
  });

  group('Given authenticated', () {
    group('when running status command', () {
      group('with correct args to get the most recent deploy status', () {
        setUpAll(() async {
          final attemptStages = [
            DeployAttemptStage(
              cloudEnvironmentId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.upload,
              stageStatus: DeployProgressStatus.success,
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              endTime: DateTime.parse("2021-12-31 10:20:40"),
            ),
            DeployAttemptStage(
              cloudEnvironmentId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.build,
              externalId: 'build-id-foo',
              stageStatus: DeployProgressStatus.success,
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              endTime: DateTime.parse("2021-12-31 10:20:40"),
            ),
            DeployAttemptStage(
              cloudEnvironmentId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.deploy,
              stageStatus: DeployProgressStatus.success,
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              endTime: DateTime.parse("2021-12-31 10:20:40"),
            ),
            DeployAttemptStage(
              cloudEnvironmentId: projectId,
              attemptId: 'abc',
              stageType: DeployStageType.service,
              stageStatus: DeployProgressStatus.success,
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              endTime: DateTime.parse("2021-12-31 10:20:40"),
            ),
          ];

          when(() => client.status.getDeployAttemptStatus(
                cloudEnvironmentId: projectId,
                attemptId: attemptStages.first.attemptId,
              )).thenAnswer((final _) async => attemptStages);

          when(() => client.status.getDeployAttemptId(
                cloudEnvironmentId: projectId,
                attemptNumber: 0,
              )).thenAnswer((final _) async => attemptStages.first.attemptId);
        });

        tearDownAll(() {
          reset(client.status);
        });

        @isTestGroup
        void testCorrectGetRecentStatusCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;
            setUp(() async {
              commandResult = cli.run([
                'status',
                ...args,
              ]);
            });

            test('then completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then outputs the status', () async {
              await commandResult;

              expect(logger.messages, isNotEmpty);
              expect(
                logger.messages.first,
                '''
Status of projectId deploy abc, started at 2021-12-31 10:20:30:

✅  Booster liftoff:     Upload successful!

✅  Orbit acceleration:  Build successful!

✅  Orbital insertion:   Deploy successful!

✅  Pod commissioning:   Service successful! 🚀

''',
              );
            });
          });
        }

        testCorrectGetRecentStatusCommand(
            'by named proj opt and default build', ['--project-id', projectId]);
        testCorrectGetRecentStatusCommand('by named proj opt and build index',
            ['--project-id', projectId, '0']);
        testCorrectGetRecentStatusCommand('by named proj opt and build id',
            ['--project-id', projectId, 'abc']);
      });

      group('with incorrect args to get a deploy status', () {
        setUpAll(() async {
          when(() => client.status.getDeployAttemptStatus(
                cloudEnvironmentId: any(named: 'cloudEnvironmentId'),
                attemptId: any(named: 'attemptId'),
              )).thenThrow(ServerpodClientNotFound());

          when(() => client.status.getDeployAttemptId(
                cloudEnvironmentId: any(named: 'cloudEnvironmentId'),
                attemptNumber: any(named: 'attemptNumber'),
              )).thenThrow(ServerpodClientNotFound());
        });

        tearDownAll(() async {
          reset(client.status);
        });

        @isTestGroup
        void testIncorrectGetStatusCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;
            setUp(() async {
              commandResult = cli.run([
                'status',
                ...args,
              ]);
            });

            test('then throws ExitException', () async {
              await expectLater(commandResult, throwsA(isA<ExitException>()));

              expect(logger.errors, isNotEmpty);
              expect(
                logger.errors.first,
                startsWith('Failed to get deployment status'),
              );
            });
            test('then outputs error message', () async {
              await commandResult.onError((final e, final s) {});

              expect(logger.errors, isNotEmpty);
              expect(
                logger.errors.first,
                startsWith('Failed to get deployment status'),
              );
            });
          });
        }

        testIncorrectGetStatusCommand(
            'for named proj opt and non-existing build index',
            ['--project-id', projectId, '2']);
        testIncorrectGetStatusCommand(
            'for non-existing project without build index',
            ['--project-id', 'non-existing']);
        testIncorrectGetStatusCommand(
            'for non-existing project and build index',
            ['--project-id', 'non-existing', '0']);
      });
    });

    group('when running status list command', () {
      group('with correct args to get the deployments list', () {
        setUpAll(() async {
          final buildStatuses = [
            DeployAttempt(
              cloudEnvironmentId: projectId,
              attemptId: 'foo',
              status: DeployProgressStatus.success,
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              endTime: DateTime.parse("2021-12-31 10:20:40"),
              statusInfo: null,
            ),
            DeployAttempt(
              cloudEnvironmentId: projectId,
              attemptId: 'bar',
              status: DeployProgressStatus.failure,
              startTime: DateTime.parse("2021-12-31 10:10:30"),
              endTime: DateTime.parse("2021-12-31 10:10:40"),
              statusInfo: 'Some error',
            ),
          ];

          when(() => client.status.getDeployAttempts(
                cloudEnvironmentId: projectId,
                limit: any(named: 'limit'),
              )).thenAnswer((final _) async => buildStatuses);
        });

        tearDownAll(() async {
          reset(client.status);
        });

        @isTestGroup
        void testCorrectGetStatusesCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;

            setUp(() async {
              commandResult = cli.run([
                'status',
                ...args,
              ]);
            });

            test('then completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then outputs the status list', () async {
              await commandResult;

              expect(logger.messages, isNotEmpty);
              expect(
                logger.messages.first,
                '''
# | Project   | Deploy Id | Status  | Started             | Finished            | Info      
--+-----------+-----------+---------+---------------------+---------------------+-----------
0 | projectId | foo       | SUCCESS | 2021-12-31 10:20:30 | 2021-12-31 10:20:40 |           
1 | projectId | bar       | FAILURE | 2021-12-31 10:10:30 | 2021-12-31 10:10:40 | Some error
''',
              );
            });
          });
        }

        testCorrectGetStatusesCommand('with named project opt and long option',
            ['--project-id', projectId, '--list']);
        testCorrectGetStatusesCommand('with named project op and short option',
            ['--project-id', projectId, '-l']);
      });

      group('with incorrect args to get a deployments list', () {
        @isTestGroup
        void testIncorrectGetStatusesCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;

            setUp(() async {
              commandResult = cli.run([
                'status',
                ...args,
              ]);
            });

            test('then throws ExitException', () async {
              await expectLater(commandResult, throwsA(isA<ExitException>()));
            });
            test('then outputs error message', () async {
              await commandResult.onError((final e, final s) {});

              expect(logger.errors, isNotEmpty);
              expect(
                logger.errors.first,
                startsWith('Cannot specify deploy id with --list'),
              );
            });
          });
        }

        testIncorrectGetStatusesCommand(
            'for non-existing project and long option',
            ['--project-id', projectId, 'disallowed-attempt-id', '--list']);
        testIncorrectGetStatusesCommand(
            'for non-existing project and short option',
            ['--project-id', projectId, 'disallowed-attempt-id', '-l']);
      });
    });
  });
}

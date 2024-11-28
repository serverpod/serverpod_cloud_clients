import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
  );

  tearDown(() {
    logger.clear();
  });

  const projectId = 'projectId';

  group('Given unauthenticated', () {
    late Uri localServerAddress;
    late Completer requestCompleter;
    late HttpServer server;

    setUp(() async {
      requestCompleter = Completer();
      final serverBuilder = HttpServerBuilder();
      serverBuilder.withOnRequest((final request) {
        requestCompleter.complete();
        request.response.statusCode = 401;
        request.response.close();
      });

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group('when running status', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          '--api-url',
          localServerAddress.toString(),
          'status',
          '--project-id',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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
          '--api-url',
          localServerAddress.toString(),
          'status',
          '--project-id',
          projectId,
          '--build-log',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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
          '--api-url',
          localServerAddress.toString(),
          'status',
          '--project-id',
          projectId,
          '--list',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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
        late Uri localServerAddress;
        late HttpServer server;

        setUpAll(() async {
          final buildStatuses = [
            BuildStatus(
              cloudProjectId: projectId,
              cloudEnvironmentId: projectId,
              buildId: 'build-id-foo',
              status: 'SUCCESS',
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              finishTime: DateTime.parse("2021-12-31 10:20:40"),
              info: null,
            ),
          ];

          final serverBuilder = HttpServerBuilder();
          serverBuilder.withMethodResponse(
            'status',
            'getBuildStatus',
            (final parameters) {
              if (parameters['cloudProjectId'] != projectId) {
                return (404, null);
              }
              final status = buildStatuses
                  .where(
                      (final status) => status.buildId == parameters['buildId'])
                  .firstOrNull;
              return (status != null ? 200 : 404, status);
            },
          );

          serverBuilder.withMethodResponse(
            'status',
            'getBuildId',
            (final parameters) {
              if (parameters['cloudProjectId'] != projectId) {
                return (404, null);
              }
              final buildNumber = parameters['buildNumber'] as int;
              if (buildNumber < 0 || buildNumber >= buildStatuses.length) {
                return (404, null);
              }
              return (200, buildStatuses[buildNumber].buildId);
            },
          );

          (server, localServerAddress) = await serverBuilder.build();
        });

        tearDownAll(() async {
          await server.close(force: true);
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
                '--api-url',
                localServerAddress.toString(),
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
Status of projectId build build-id-foo, started at 2021-12-31 10:20:30:

✅  Booster liftoff:     Upload successful!

✅  Orbit acceleration:  Build successful!

✅  Orbital insertion:   Deploy successful!

✅  Pod commissioning:   Service running! 🚀

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
            ['--project-id', projectId, 'build-id-foo']);
      });

      group('with incorrect args to get a deploy status', () {
        late Uri localServerAddress;
        late HttpServer server;

        setUpAll(() async {
          final serverBuilder = HttpServerBuilder();
          serverBuilder.withMethodResponse(
            'status',
            'getBuildStatus',
            (final parameters) => (404, null),
          );

          serverBuilder.withMethodResponse(
            'status',
            'getBuildId',
            (final parameters) => (404, null),
          );

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;
        });

        tearDownAll(() async {
          await server.close(force: true);
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
                '--api-url',
                localServerAddress.toString(),
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
        late Uri localServerAddress;
        late HttpServer server;

        setUpAll(() async {
          final buildStatuses = [
            BuildStatus(
              cloudProjectId: projectId,
              cloudEnvironmentId: projectId,
              buildId: 'build-id-foo',
              status: 'SUCCESS',
              startTime: DateTime.parse("2021-12-31 10:20:30"),
              finishTime: DateTime.parse("2021-12-31 10:20:40"),
              info: null,
            ),
            BuildStatus(
              cloudProjectId: projectId,
              cloudEnvironmentId: projectId,
              buildId: 'build-id-bar',
              status: 'FAILURE',
              startTime: DateTime.parse("2021-12-31 10:10:30"),
              finishTime: DateTime.parse("2021-12-31 10:10:40"),
              info: 'Some error',
            ),
          ];

          final serverBuilder = HttpServerBuilder();
          serverBuilder.withMethodResponse(
            'status',
            'getBuildStatuses',
            (final parameters) {
              if (parameters['cloudProjectId'] != projectId) {
                return (404, null);
              }
              return (200, buildStatuses);
            },
          );

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;
        });

        tearDownAll(() async {
          await server.close(force: true);
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
                '--api-url',
                localServerAddress.toString(),
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
# | Project   | Build Id     | Status  | Started             | Finished            | Info      
--+-----------+--------------+---------+---------------------+---------------------+-----------
0 | projectId | build-id-foo | SUCCESS | 2021-12-31 10:20:30 | 2021-12-31 10:20:40 |           
1 | projectId | build-id-bar | FAILURE | 2021-12-31 10:10:30 | 2021-12-31 10:10:40 | Some error
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
        late Uri localServerAddress;
        late HttpServer server;

        setUpAll(() async {
          final serverBuilder = HttpServerBuilder();
          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;
        });

        tearDownAll(() async {
          await server.close(force: true);
        });

        @isTestGroup
        void testIncorrectGetStatusesCommand(
          final String description,
          final List<String> args,
        ) {
          group('$description with args="${args.join(' ')}"', () {
            late Future commandResult;

            setUp(() async {
              commandResult = cli.run([
                '--api-url',
                localServerAddress.toString(),
                'status',
                ...args,
              ]);
            });

            test('then throws ExitException', () async {
              await expectLater(commandResult, throwsA(isA<ExitException>()));

              expect(logger.errors, isNotEmpty);
              expect(
                logger.errors.first,
                startsWith('Failed to get deployments list:'),
              );
            });
            test('then outputs error message', () async {
              await commandResult.onError((final e, final s) {});

              expect(logger.errors, isNotEmpty);
              expect(
                logger.errors.first,
                startsWith('Failed to get deployments list:'),
              );
            });
          });
        }

        testIncorrectGetStatusesCommand(
            'for non-existing project and long option',
            ['--project-id', projectId, 'non-existing-project', '--list']);
        testIncorrectGetStatusesCommand(
            'for non-existing project and short option',
            ['--project-id', projectId, 'non-existing-project', '-l']);
      });
    });
  });
}

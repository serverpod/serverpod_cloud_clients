import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/builds/builds_command.dart';
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
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  setUpAll(() {
    registerFallbackValue(Uuid().v4obj());
  });

  tearDown(() async {
    logger.clear();
    reset(client.status);
    reset(client.logs);
  });

  const projectId = 'projectId';
  final attemptId = Uuid().v4obj();
  final timestamp = DateTime.parse('2024-01-01T00:00:00Z');

  const commandPaths = {
    'build log': ['build', 'log'],
    'status deployment log': ['status', 'deployment', 'log'],
    'the hidden deployment build-log': ['deployment', 'build-log'],
  };

  test('Given build log command when instantiated then requires login', () {
    expect(CloudBuildLogCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      when(
        () => client.status.getDeployAttemptId(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          attemptNumber: any(named: 'attemptNumber'),
        ),
      ).thenThrow(ServerpodClientUnauthorized());
    });

    for (final MapEntry(key: description, value: path)
        in commandPaths.entries) {
      group('when executing $description', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([...path, '--project', projectId]);
        });

        test('then throws exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(logger.errorCalls, isNotEmpty);
          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ),
          );
        });
      });
    }
  });

  group('Given authenticated and a deployment with build log records', () {
    setUp(() async {
      when(
        () => client.status.getDeployAttemptId(
          cloudCapsuleId: projectId,
          attemptNumber: 0,
        ),
      ).thenAnswer((final _) async => attemptId);

      when(
        () => client.logs.fetchBuildLog(
          cloudCapsuleId: projectId,
          attemptId: attemptId,
        ),
      ).thenAnswer(
        (final _) => Stream.fromIterable([
          LogRecordBuilder()
              .withCloudIds(projectId)
              .withDeployAttemptId(attemptId)
              .withRecordId('1')
              .withTimestamp(timestamp)
              .withContent('Building image...')
              .withSeverity(null)
              .build(),
          LogRecordBuilder()
              .withCloudIds(projectId)
              .withDeployAttemptId(attemptId)
              .withRecordId('2')
              .withTimestamp(timestamp)
              .withContent('Pushing image...')
              .withSeverity(null)
              .build(),
        ]),
      );
    });

    for (final MapEntry(key: description, value: path)
        in commandPaths.entries) {
      group('when executing $description', () {
        late Future commandResult;

        setUp(() async {
          commandResult = cli.run([...path, '--utc', '--project', projectId]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then outputs the log records as a table', () async {
          await commandResult;

          expect(
            logger.lineCalls.map((final call) => call.line),
            containsAllInOrder([
              contains('Timestamp'),
              contains('Building image...'),
              contains('Pushing image...'),
            ]),
          );
          expect(
            logger.lineCalls.map((final call) => call.line),
            contains(contains('2024-01-01 00:00:00z')),
          );
        });
      });
    }

    group('when executing build log with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'build',
          'log',
          '--format',
          'json',
          '--project',
          projectId,
        ]);
      });

      test('then emits a JSON array of log records', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload[0] as Map)['content'], 'Building image...');
        expect((payload[0] as Map)['recordId'], '1');
        expect(
          (payload[0] as Map)['timestamp'],
          timestamp.toUtc().toIso8601String(),
        );
        expect((payload[1] as Map)['content'], 'Pushing image...');
      });
    });

    group('when executing build log with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'build',
          'log',
          '--format',
          'yaml',
          '--project',
          projectId,
        ]);
      });

      test('then emits YAML of the same log records', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload[0] as Map)['content'], 'Building image...');
        expect((payload[0] as Map)['recordId'], '1');
        expect(
          (payload[0] as Map)['timestamp'],
          timestamp.toUtc().toIso8601String(),
        );
      });
    });
  });

  group('Given authenticated and a deployment without build log records', () {
    setUp(() async {
      when(
        () => client.status.getDeployAttemptId(
          cloudCapsuleId: projectId,
          attemptNumber: 0,
        ),
      ).thenAnswer((final _) async => attemptId);

      when(
        () => client.logs.fetchBuildLog(
          cloudCapsuleId: projectId,
          attemptId: attemptId,
        ),
      ).thenAnswer((final _) => const Stream.empty());
    });

    group('when executing build log', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run(['build', 'log', '--project', projectId]);
      });

      test('then reports that no log records were found', () async {
        await commandResult;

        expect(
          logger.infoCalls,
          contains(equalsInfoCall(message: 'No log records found.')),
        );
        expect(logger.lineCalls, isEmpty);
      });
    });

    group('when executing build log with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'build',
          'log',
          '--format',
          'json',
          '--project',
          projectId,
        ]);
      });

      test('then emits an empty JSON array', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.infoCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
      });
    });
  });

  group('Given a deployment that does not exist', () {
    setUp(() async {
      when(
        () => client.status.getDeployAttemptId(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          attemptNumber: any(named: 'attemptNumber'),
        ),
      ).thenThrow(NotFoundException(message: 'not found'));
    });

    group('when executing build log for a specific deployment', () {
      setUp(() async {
        try {
          await cli.run(['build', 'log', '3', '--project', projectId]);
        } catch (_) {}
      });

      test('then the hint points to the status deployment list command', () {
        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'No such deployment status found.',
            hint:
                'Run this command to see recent deployments: '
                'scloud status deployment list',
          ),
        );
      });
    });

    group(
      'when executing the hidden deployment build-log for a specific deployment',
      () {
        setUp(() async {
          try {
            await cli.run([
              'deployment',
              'build-log',
              '3',
              '--project',
              projectId,
            ]);
          } catch (_) {}
        });

        test('then the hint points to the legacy deployment list command', () {
          expect(logger.errorCalls, isNotEmpty);
          expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message: 'No such deployment status found.',
              hint:
                  'Run this command to see recent deployments: '
                  'scloud deployment list',
            ),
          );
        });
      },
    );
  });
}

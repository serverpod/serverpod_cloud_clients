import 'dart:convert';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
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
  );

  final logTimestamp = DateTime.parse('2024-01-01T00:00:00Z');
  final projectId = 'my-project-id';

  tearDown(() {
    logger.clear();
    reset(client.logs);
  });

  test('Given log command when instantiated then requires login', () {
    expect(CloudLogCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given stored credentials', () {
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    tearDown(() async {
      client.authKeyProvider = InMemoryKeyManager.unauthenticated();
    });

    group('when fetching recent logs', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecentRecords(
            cloudCapsuleId: projectId,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run(['log', '--utc', '--project', projectId]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the log records as a table', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            contains('Timestamp'),
            contains('Log message 1'),
            contains('Log message 2'),
          ]),
        );
        expect(
          logger.lineCalls.map((call) => call.line),
          contains(contains('2024-01-01 00:00:00z')),
        );
      });
    });

    group('when fetching recent logs with --format json', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecentRecords(
            cloudCapsuleId: projectId,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--format',
          'json',
          '--project',
          projectId,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then emits a JSON array of log records', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload[0] as Map)['content'], 'Log message 1');
        expect((payload[0] as Map)['recordId'], '1');
        expect(
          (payload[0] as Map)['timestamp'],
          logTimestamp.toUtc().toIso8601String(),
        );
        expect((payload[1] as Map)['content'], 'Log message 2');
      });
    });

    group('when fetching recent logs with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecentRecords(
            cloudCapsuleId: projectId,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Server started')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
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
        expect(payload, hasLength(1));
        expect((payload[0] as Map)['content'], 'Server started');
        expect((payload[0] as Map)['recordId'], '1');
        expect(
          (payload[0] as Map)['timestamp'],
          logTimestamp.toUtc().toIso8601String(),
        );
      });
    });

    group('when calling with --utc flag and --since duration value', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecords(
            cloudCapsuleId: projectId,
            beforeTime: null,
            afterTime: any(named: 'afterTime'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--since',
          '1m',
          '--utc',
          '--project',
          projectId,
        ]);
      });

      test('then outputs the log records as a table', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            contains('Timestamp'),
            contains('Log message 1'),
            contains('Log message 2'),
          ]),
        );
      });
    });

    group('when calling with --utc flag and --until duration value', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecords(
            cloudCapsuleId: projectId,
            beforeTime: any(named: 'beforeTime'),
            afterTime: any(named: 'afterTime'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--until',
          '1m',
          '--utc',
          '--project',
          projectId,
        ]);
      });

      test('then outputs the log records as a table', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            contains('Timestamp'),
            contains('Log message 1'),
            contains('Log message 2'),
          ]),
        );
      });
    });

    group('when calling with --utc flag and --until value', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecords(
            cloudCapsuleId: projectId,
            beforeTime: DateTime.parse('2030-12-01T00:00:00Z'),
            afterTime: null,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--utc',
          '--until',
          '2030-12-01T00:00:00Z',
          '--project',
          projectId,
        ]);
      });

      test('then outputs the log records as a table', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            contains('Timestamp'),
            contains('Log message 1'),
            contains('Log message 2'),
          ]),
        );
      });
    });

    group('when calling with --utc flag and --since value', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.logs.fetchRecords(
            cloudCapsuleId: projectId,
            beforeTime: null,
            afterTime: DateTime.parse('2020-12-01T00:00:00Z'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--utc',
          '--since',
          '2020-12-01T00:00:00Z',
          '--project',
          projectId,
        ]);
      });

      test('then outputs the log records as a table', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            contains('Timestamp'),
            contains('Log message 1'),
            contains('Log message 2'),
          ]),
        );
      });
    });

    group(
      'when calling with --utc flag and both --since and --until value',
      () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.logs.fetchRecords(
              cloudCapsuleId: projectId,
              beforeTime: DateTime.parse('2030-01-01T00:00:00Z'),
              afterTime: DateTime.parse('2020-12-01T00:00:00Z'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) => Stream.fromIterable([
              LogRecordBuilder()
                  .withCloudIds(projectId)
                  .withRecordId('1')
                  .withTimestamp(logTimestamp)
                  .withContent('Log message 1')
                  .withSeverity(null)
                  .build(),
              LogRecordBuilder()
                  .withCloudIds(projectId)
                  .withRecordId('2')
                  .withTimestamp(logTimestamp)
                  .withContent('Log message 2')
                  .withSeverity(null)
                  .build(),
            ]),
          );

          commandResult = cli.run([
            'log',
            '--utc',
            '--until',
            '2030-01-01T00:00:00Z',
            '--since',
            '2020-12-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        });

        test('then outputs the log records as a table', () async {
          await commandResult;

          expect(
            logger.lineCalls.map((call) => call.line),
            containsAllInOrder([
              contains('Timestamp'),
              contains('Log message 1'),
              contains('Log message 2'),
            ]),
          );
        });
      },
    );

    group('when calling with --utc flag and --tail flag', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.logs.tailRecords(
            cloudCapsuleId: projectId,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--utc',
          '--tail',
          '--project',
          projectId,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the tailed log records as a table', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            contains('Tailing logs. Display time zone: UTC.'),
            contains('Timestamp'),
            contains('Log message 1'),
            contains('Log message 2'),
            contains('-- End of log stream -- 2 records (limit 50) --'),
          ]),
        );
        expect(
          logger.lineCalls.map((call) => call.line),
          contains(contains('2024-01-01 00:00:00z')),
        );
      });
    });

    group('when tailing logs with --format json', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.logs.tailRecords(
            cloudCapsuleId: projectId,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Log message 1')
                .withSeverity(null)
                .build(),
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('2')
                .withTimestamp(logTimestamp)
                .withContent('Log message 2')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--tail',
          '--format',
          'json',
          '--project',
          projectId,
        ]);
      });

      test('then emits one JSON object per log record', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(2));
        final first = jsonDecode(logger.rawCalls[0].content) as Map;
        expect(first['content'], 'Log message 1');
        expect(first['recordId'], '1');
        expect(first['timestamp'], logTimestamp.toUtc().toIso8601String());
        final second = jsonDecode(logger.rawCalls[1].content) as Map;
        expect(second['content'], 'Log message 2');
      });
    });

    group('when tailing logs with --format yaml', () {
      late Future commandResult;

      setUp(() {
        when(
          () => client.logs.tailRecords(
            cloudCapsuleId: projectId,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            LogRecordBuilder()
                .withCloudIds(projectId)
                .withRecordId('1')
                .withTimestamp(logTimestamp)
                .withContent('Server started')
                .withSeverity(null)
                .build(),
          ]),
        );

        commandResult = cli.run([
          'log',
          '--tail',
          '--format',
          'yaml',
          '--project',
          projectId,
        ]);
      });

      test('then emits one YAML document per log record', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['content'], 'Server started');
        expect(payload['recordId'], '1');
        expect(payload['timestamp'], logTimestamp.toUtc().toIso8601String());
      });
    });
  });

  group('Given stored credentials and no log records', () {
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
      when(
        () => client.logs.fetchRecentRecords(
          cloudCapsuleId: projectId,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => const Stream.empty());
    });

    tearDown(() async {
      client.authKeyProvider = InMemoryKeyManager.unauthenticated();
    });

    group('when fetching recent logs', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run(['log', '--project', projectId]);
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

    group('when fetching recent logs with --format json', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run([
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
}

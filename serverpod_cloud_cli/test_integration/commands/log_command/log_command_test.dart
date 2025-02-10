import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  final logTimestamp = DateTime.parse('2024-01-01T00:00:00Z');
  final projectId = 'my-project-id';

  final mockRecords = [
    LogRecord(
      cloudProjectId: projectId,
      cloudCapsuleId: '1',
      recordId: '1',
      timestamp: logTimestamp,
      content: 'Log message 1',
    ),
    LogRecord(
      cloudProjectId: projectId,
      cloudCapsuleId: '2',
      recordId: '2',
      timestamp: logTimestamp,
      content: 'Log message 2',
    ),
  ];

  group('Given stored credentials', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    tearDown(() async {
      await keyManager.remove();
    });

    group('when calling with --utc flag and --recent value', () {
      setUp(() async {
        when(() => client.logs.fetchRecords(
              cloudProjectId: projectId,
              beforeTime: null,
              afterTime: any(named: 'afterTime'),
              limit: 50,
            )).thenAnswer((final _) => Stream.fromIterable(mockRecords));

        await cli.run([
          'log',
          '--recent',
          '1m',
          '--utc',
          '--project-id',
          projectId,
        ]);
      });

      test('then logs output stream', () async {
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line: 'Timestamp                   | Level   | Content',
            ),
            equalsLineCall(
              line: '----------------------------+---------+--------',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 1',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 2',
            ),
            equalsLineCall(
              line: '-- End of log stream -- 2 records (limit 50) --',
            ),
          ]),
        );
      });
    });

    group('when calling with --utc flag and --before value', () {
      setUp(() async {
        when(() => client.logs.fetchRecords(
              cloudProjectId: projectId,
              beforeTime: DateTime.parse('2030-12-01T00:00:00Z'),
              afterTime: null,
              limit: 50,
            )).thenAnswer((final _) => Stream.fromIterable(mockRecords));

        await cli.run([
          'log',
          '--utc',
          '--before',
          '2030-12-01T00:00:00Z',
          '--project-id',
          projectId,
        ]);
      });

      test('then logs output stream', () async {
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line:
                  'Fetching logs from oldest to 2030-12-01 00:00:00.000Z. Display time zone: UTC.',
            ),
            equalsLineCall(
              line: 'Timestamp                   | Level   | Content',
            ),
            equalsLineCall(
              line: '----------------------------+---------+--------',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 1',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 2',
            ),
            equalsLineCall(
              line: '-- End of log stream -- 2 records (limit 50) --',
            ),
          ]),
        );
      });
    });

    group('when calling with --utc flag and --after value', () {
      setUp(() async {
        when(() => client.logs.fetchRecords(
              cloudProjectId: projectId,
              beforeTime: null,
              afterTime: DateTime.parse('2020-12-01T00:00:00Z'),
              limit: 50,
            )).thenAnswer((final _) => Stream.fromIterable(mockRecords));

        await cli.run([
          'log',
          '--utc',
          '--after',
          '2020-12-01T00:00:00Z',
          '--project-id',
          projectId,
        ]);
      });

      test('then logs output stream', () async {
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line:
                  'Fetching logs from 2020-12-01 00:00:00.000Z to newest. Display time zone: UTC.',
            ),
            equalsLineCall(
              line: 'Timestamp                   | Level   | Content',
            ),
            equalsLineCall(
              line: '----------------------------+---------+--------',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 1',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 2',
            ),
            equalsLineCall(
              line: '-- End of log stream -- 2 records (limit 50) --',
            ),
          ]),
        );
      });
    });

    group('when calling with --utc flag and both --after and --before value',
        () {
      setUp(() async {
        when(() => client.logs.fetchRecords(
              cloudProjectId: projectId,
              beforeTime: DateTime.parse('2030-01-01T00:00:00Z'),
              afterTime: DateTime.parse('2020-12-01T00:00:00Z'),
              limit: 50,
            )).thenAnswer((final _) => Stream.fromIterable(mockRecords));

        await cli.run([
          'log',
          '--utc',
          '--before',
          '2030-01-01T00:00:00Z',
          '--after',
          '2020-12-01T00:00:00Z',
          '--project-id',
          projectId,
        ]);
      });

      test('then logs output stream', () async {
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line:
                  'Fetching logs from 2020-12-01 00:00:00.000Z to 2030-01-01 00:00:00.000Z. Display time zone: UTC.',
            ),
            equalsLineCall(
              line: 'Timestamp                   | Level   | Content',
            ),
            equalsLineCall(
              line: '----------------------------+---------+--------',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 1',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 2',
            ),
            equalsLineCall(
              line: '-- End of log stream -- 2 records (limit 50) --',
            ),
          ]),
        );
      });
    });

    group('when calling with --utc flag and --tail flag', () {
      setUp(() async {
        when(() => client.logs.tailRecords(
              cloudProjectId: projectId,
              limit: 50,
            )).thenAnswer((final _) => Stream.fromIterable(mockRecords));

        await cli.run([
          'log',
          '--utc',
          '--tail',
          '--project-id',
          projectId,
        ]);
      });

      test('then logs output stream', () async {
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line: 'Tailing logs. Display time zone: UTC.',
            ),
            equalsLineCall(
              line: 'Timestamp                   | Level   | Content',
            ),
            equalsLineCall(
              line: '----------------------------+---------+--------',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 1',
            ),
            equalsLineCall(
              line: '2024-01-01 00:00:00.000Z    |         | Log message 2',
            ),
            equalsLineCall(
              line: '-- End of log stream -- 2 records (limit 50) --',
            ),
          ]),
        );
      });
    });
  });
}

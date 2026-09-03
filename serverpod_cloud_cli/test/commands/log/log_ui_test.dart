import 'dart:io' as io;

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given LogsUi fetch header', () {
    group('when written with a time range in UTC', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final captured = await captureStdio(() {
          io.stdout.writeln(
            LogsUi.fetchHeader(
              after: DateTime.utc(2025, 1, 15, 14),
              before: DateTime.utc(2025, 1, 15, 15),
              inUtc: true,
            ),
          );
        });
        stdout = captured.stdout;
        stderr = captured.stderr;
      });

      test('then stdout describes the fetch range', () {
        expect(stdout, contains('Fetching logs from'));
        expect(stdout, contains('2025-01-15 14:00:00.000'));
        expect(stdout, contains('2025-01-15 15:00:00.000'));
        expect(stdout, contains('Display time zone: UTC.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when written without a time range', () {
      late String stdout;

      setUp(() async {
        final captured = await captureStdio(() {
          io.stdout.writeln(
            LogsUi.fetchHeader(after: null, before: null, inUtc: true),
          );
        });
        stdout = captured.stdout;
      });

      test('then stdout uses oldest to newest', () {
        expect(stdout, contains('Fetching logs from oldest to newest.'));
      });
    });
  });

  group('Given LogsUi tail header', () {
    group('when written', () {
      late String stdout;

      setUp(() async {
        final captured = await captureStdio(() {
          io.stdout.writeln(LogsUi.tailHeader(inUtc: true));
        });
        stdout = captured.stdout;
      });

      test('then stdout reports tailing in UTC', () {
        expect(stdout, contains('Tailing logs. Display time zone: UTC.'));
      });
    });
  });

  group('Given LogsUi build log header', () {
    group('when written', () {
      late String stdout;

      setUp(() async {
        final attemptId = UuidValue.fromString(
          '550e8400-e29b-41d4-a716-446655440000',
        );
        final captured = await captureStdio(() {
          io.stdout.writeln(
            LogsUi.buildLogHeader(attemptId: attemptId, inUtc: true),
          );
        });
        stdout = captured.stdout;
      });

      test('then stdout contains the deploy id', () {
        expect(
          stdout,
          contains(
            'Fetching build logs for deploy id 550e8400-e29b-41d4-a716-446655440000.',
          ),
        );
      });
    });
  });

  group('Given LogsUi writeLogStream', () {
    group('when written with a log record', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final captured = await captureStdio(() async {
          await LogsUi.writeLogStream(
            Stream.fromIterable([
              LogRecordBuilder()
                  .withTimestamp(DateTime.utc(2024, 11, 26, 16, 38, 44))
                  .withSeverity('INFO')
                  .withContent('Webserver listening on port 8082')
                  .build(),
            ]),
            writeln: io.stdout.writeln,
            inUtc: true,
            limit: 50,
          );
        });
        stdout = captured.stdout;
        stderr = captured.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Timestamp'));
        expect(stdout, contains('Level'));
        expect(stdout, contains('Content'));
      });

      test('then stdout contains the log record', () {
        expect(stdout, contains('INFO'));
        expect(stdout, contains('Webserver listening on port 8082'));
      });

      test('then stdout contains the end-of-stream footer', () {
        expect(
          stdout,
          contains('-- End of log stream -- 1 records (limit 50) --'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when the record count equals the limit', () {
      late String stdout;

      setUp(() async {
        final captured = await captureStdio(() async {
          await LogsUi.writeLogStream(
            Stream.fromIterable([
              LogRecordBuilder().withContent('only').build(),
            ]),
            writeln: io.stdout.writeln,
            inUtc: true,
            limit: 1,
          );
        });
        stdout = captured.stdout;
      });

      test('then stdout hints to raise the limit', () {
        expect(
          stdout,
          contains('Use the --limit option to increase the limit.'),
        );
      });
    });
  });
}

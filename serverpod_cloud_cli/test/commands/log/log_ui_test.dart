import 'package:ground_control_client/ground_control_client.dart'
    show LogRecord;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a LogListTextUi', () {
    group('when rendered with no records', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const LogListTextUi(utc: true),
          data: const <LogRecord>[],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no log records were found', () {
        expect(stdout, contains('No log records found.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a log record', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const LogListTextUi(utc: true),
          data: [
            LogRecordBuilder()
                .withTimestamp(DateTime.utc(2024, 11, 26, 16, 38, 44))
                .withSeverity('INFO')
                .withContent('Webserver listening on port 8082')
                .build(),
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
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

      test('then stdout contains the UTC timestamp', () {
        expect(stdout, contains('2024-11-26 16:38:44z'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a LogTailTextUi', () {
    group('when rendered with a log record', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const LogTailTextUi(utc: true, limit: 50),
          data: Stream.fromIterable([
            LogRecordBuilder()
                .withTimestamp(DateTime.utc(2024, 11, 26, 16, 38, 44))
                .withSeverity('INFO')
                .withContent('Webserver listening on port 8082')
                .build(),
          ]),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports tailing in UTC', () {
        expect(stdout, contains('Tailing logs. Display time zone: UTC.'));
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
        final io = await renderCommandUi(
          const LogTailTextUi(utc: true, limit: 1),
          data: Stream.fromIterable([
            LogRecordBuilder().withContent('only').build(),
          ]),
        );
        stdout = io.stdout;
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

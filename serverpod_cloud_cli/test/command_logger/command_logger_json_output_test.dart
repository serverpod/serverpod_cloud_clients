import 'dart:convert';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/output_format.dart';
import 'package:test/test.dart';

import '../../test_utils/mock_stdout.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  late CommandLogger logger;

  setUp(() {
    logger = CommandLogger.create(LogLevel.debug);
    logger.resolvedOutputFormat = OutputFormat.json;
  });

  group('Given JSON output mode', () {
    group('when outputTable is called with data', () {
      test('then flushOutput writes JSON with data array', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.outputTable(
            headers: ['Name', 'Value'],
            rows: [
              ['foo', 'bar'],
              ['baz', null],
            ],
          );
          logger.flushOutput();
        });

        final json = jsonDecode(stdout.output) as Map<String, dynamic>;
        expect(json['success'], isTrue);
        expect(json['data'], [
          {'Name': 'foo', 'Value': 'bar'},
          {'Name': 'baz', 'Value': null},
        ]);
      });
    });

    group('when outputTable is called with empty rows', () {
      test('then flushOutput writes JSON with empty data', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.outputTable(headers: ['Name'], rows: []);
          logger.flushOutput();
        });

        final json = jsonDecode(stdout.output) as Map<String, dynamic>;
        expect(json['success'], isTrue);
        expect(json['data'], isEmpty);
      });
    });

    group('when multiple outputTable calls are made', () {
      test('then flushOutput writes nested data arrays', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.outputTable(headers: ['A'], rows: [
            ['1'],
          ]);
          logger.outputTable(headers: ['B'], rows: [
            ['2'],
          ]);
          logger.flushOutput();
        });

        final json = jsonDecode(stdout.output) as Map<String, dynamic>;
        expect(json['success'], isTrue);
        expect(json['data'], hasLength(2));
        expect(json['data'][0], [
          {'A': '1'},
        ]);
        expect(json['data'][1], [
          {'B': '2'},
        ]);
      });
    });

    group('when success is called', () {
      test('then flushOutput includes message', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.success('Project created.');
          logger.flushOutput();
        });

        final json = jsonDecode(stdout.output) as Map<String, dynamic>;
        expect(json['success'], isTrue);
        expect(json['message'], 'Project created.');
      });

      test('then no text is written before flush', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.success('Project created.');
        });

        expect(stdout.output, isEmpty);
      });
    });

    group('when error is called', () {
      test('then flushOutput writes error JSON to stderr', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.error('Something failed.', hint: 'Try again.');
          logger.flushOutput();
        });

        expect(stdout.output, isEmpty);
        final json = jsonDecode(stderr.output) as Map<String, dynamic>;
        expect(json['success'], isFalse);
        expect(json['error'], 'Something failed.');
        expect(json['hint'], 'Try again.');
      });

      test('then error without hint omits hint key', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.error('Something failed.');
          logger.flushOutput();
        });

        expect(stdout.output, isEmpty);
        final json = jsonDecode(stderr.output) as Map<String, dynamic>;
        expect(json['success'], isFalse);
        expect(json['error'], 'Something failed.');
        expect(json.containsKey('hint'), isFalse);
      });
    });

    group('when decorative methods are called', () {
      test('then info produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.info('Some info');
        });
        expect(stdout.output, isEmpty);
      });

      test('then warning produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.warning('A warning');
        });
        expect(stdout.output, isEmpty);
      });

      test('then box produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.box('Boxed');
        });
        expect(stdout.output, isEmpty);
      });

      test('then init produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.init('Starting...');
        });
        expect(stdout.output, isEmpty);
      });

      test('then terminalCommand produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.terminalCommand('scloud deploy', message: 'Run:');
        });
        expect(stdout.output, isEmpty);
      });

      test('then line produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.line('A line');
        });
        expect(stdout.output, isEmpty);
      });

      test('then list produces no output', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.list(['a', 'b'], title: 'Items');
        });
        expect(stdout.output, isEmpty);
      });
    });

    group('when progress is called', () {
      test('then callback is still executed', () async {
        var executed = false;
        await collectOutput(() async {
          await logger.progress('Loading...', () async {
            executed = true;
            return true;
          });
        });
        expect(executed, isTrue);
      });

      test('then no spinner output is written', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() async {
          await logger.progress('Loading...', () async => true);
        });
        expect(stdout.output, isEmpty);
      });
    });

    group('when flushOutput is called twice', () {
      test('then second flush has no stale data', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.outputTable(headers: ['X'], rows: [
            ['1'],
          ]);
          logger.flushOutput();
          logger.flushOutput();
        });

        final lines = stdout.output
            .trim()
            .split('\n')
            .where((final l) => l.isNotEmpty)
            .toList();
        expect(lines, hasLength(2));

        final first = jsonDecode(lines.first) as Map<String, dynamic>;
        expect(first['data'], isNotEmpty);

        final second = jsonDecode(lines.last) as Map<String, dynamic>;
        expect(second.containsKey('data'), isFalse);
      });
    });

    group('when no data or message is set', () {
      test('then flushOutput writes minimal success JSON', () async {
        final (:stdout, :stderr, :stdin) = await collectOutput(() {
          logger.flushOutput();
        });

        final json = jsonDecode(stdout.output) as Map<String, dynamic>;
        expect(json['success'], isTrue);
        expect(json.containsKey('data'), isFalse);
        expect(json.containsKey('message'), isFalse);
      });
    });
  });

  group('Given text output mode', () {
    setUp(() {
      logger.resolvedOutputFormat = OutputFormat.text;
    });

    test('when outputTable is called then ASCII table is written', () async {
      final (:stdout, :stderr, :stdin) = await collectOutput(() {
        logger.outputTable(
          headers: ['Name', 'Value'],
          rows: [
            ['foo', 'bar'],
          ],
        );
      });

      expect(stdout.output, contains('Name'));
      expect(stdout.output, contains('foo'));
      expect(stdout.output, contains('bar'));
    });

    test('when flushOutput is called then nothing is written', () async {
      final (:stdout, :stderr, :stdin) = await collectOutput(() {
        logger.flushOutput();
      });
      expect(stdout.output, isEmpty);
    });
  });
}

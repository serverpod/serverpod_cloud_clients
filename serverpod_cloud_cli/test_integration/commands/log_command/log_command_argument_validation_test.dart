import 'package:args/command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
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

  final projectId = 'my-project-id';

  tearDown(() async {
    logger.clear();
  });

  group('Input validation - Given stored credentials', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    tearDown(() async {
      await keyManager.remove();
    });

    group('when running log command with invalid --recent unit', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--recent',
            '1x',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws UsageException', () async {
        await expectLater(
          result,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains(
                'Invalid value for option `recent` <integer[s|m|h|d]>: Invalid duration value "1x"'),
          )),
        );
      });
    });

    group('when running log command with invalid --recent value', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--recent',
            'hello',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws UsageException', () async {
        await expectLater(
          result,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains(
                'Invalid value for option `recent` <integer[s|m|h|d]>: Invalid duration value "hello"'),
          )),
        );
      });
    });

    group('when running log command with invalid --limit value', () {
      late Future result;
      setUp(() async {
        result = cli.run([
          'log',
          '--limit',
          'abc',
          '--project',
          projectId,
        ]);
      });

      test('then throws UsageException', () async {
        await expectLater(
          result,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains('Invalid value for option `limit` <integer>'),
          )),
        );
      });
    });

    group('when running log command with invalid --before value', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--before',
            'not-a-date',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws UsageException', () async {
        await expectLater(
          result,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains(
                'Invalid value for option `before` <YYYY-MM-DDtHH:MM:SSz>'),
          )),
        );
      });
    });

    group('when running log command with invalid --after value', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--after',
            'not-a-date',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws UsageException', () async {
        await expectLater(
          result,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains('Invalid value for option `after` <YYYY-MM-DDtHH:MM:SSz>'),
          )),
        );
      });
    });

    group(
        'when running log command with --after value that is after the --before value',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--after',
            '2024-01-01T00:00:00Z',
            '--before',
            '2023-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --before value must be after --after value.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --before flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--before',
            '2024-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --all option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --after flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--after',
            '2024-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --all option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --recent option',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--recent',
            '1m',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --all option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --before flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--before',
            '2024-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --all option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --after flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--after',
            '2024-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --all option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --recent option',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--recent',
            '1m',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --all option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --before flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--tail',
            '--before',
            '2024-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --tail option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --after flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--tail',
            '--after',
            '2024-01-01T00:00:00Z',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --tail option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --recent option',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--tail',
            '--recent',
            '1m',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --tail option cannot be combined with '
                '--before, --after, or --recent.',
          ),
        );
      });
    });

    group(
        'when running log command with --before option together with --recent option',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--before',
            '2024-01-01T00:00:00Z',
            '--recent',
            '1m',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --recent option cannot be combined with '
                '--before or --after.',
          ),
        );
      });
    });

    group(
        'when running log command with --after option together with --recent option',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--after',
            '2024-01-01T00:00:00Z',
            '--recent',
            '1m',
            '--project',
            projectId,
          ]);
        } catch (_) {}
      });

      test('then throws ExitErrorException', () async {
        await expectLater(result, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await result;
        } catch (_) {}

        expect(
          logger.errorCalls.last,
          equalsErrorCall(
            message: 'The --recent option cannot be combined with '
                '--before or --after.',
          ),
        );
      });
    });
  });
}

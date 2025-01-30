import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final version = Version.parse('0.0.1');
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
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
            '--project-id',
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
            message: 'Failed to parse --recent value "1x", '
                'the required pattern is <integer>[s|m|h|d]',
          ),
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
            '--project-id',
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
            message: 'Failed to parse --recent value "hello", '
                'the required pattern is <integer>[s|m|h|d]',
          ),
        );
      });
    });

    group('when running log command with invalid --limit value', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--limit',
            'abc',
            '--project-id',
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
            message: 'The --limit value must be an integer.',
          ),
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
            '--project-id',
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
            message: 'Failed to parse date-time option "not-a-date".',
            hint: 'Value must be an ISO date-time: '
                'YYYY-MM-DD HH:MM:SSz (or shorter) Alternate date/time separators: Tt-_/:',
          ),
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
            '--project-id',
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
            message: 'Failed to parse date-time option "not-a-date".',
            hint: 'Value must be an ISO date-time: '
                'YYYY-MM-DD HH:MM:SSz (or shorter) Alternate date/time separators: Tt-_/:',
          ),
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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
            '--project-id',
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

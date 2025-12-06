import 'package:args/command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:test/test.dart';

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

  final projectId = 'my-project-id';

  tearDown(() async {
    logger.clear();
  });

  group('Input validation - Given stored credentials', () {
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

    group('when running log command with invalid --until value', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--until',
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
            contains('Invalid value: expected ISO date string'),
          )),
        );
      });
    });

    group('when running log command with invalid --since value', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--since',
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
            contains('Invalid value: expected ISO date string'),
          )),
        );
      });
    });

    group('when running log command with invalid duration in --until', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--until',
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
            contains('Invalid value: expected ISO date string'),
          )),
        );
      });
    });

    group('when running log command with invalid duration in --since', () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--since',
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
            contains('Invalid value: expected ISO date string'),
          )),
        );
      });
    });

    group(
        'when running log command with --since value that is after the --until value',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--since',
            '2024-01-01T00:00:00Z',
            '--until',
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
            message: 'The --until value must be after --since value.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --until flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--until',
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
            message:
                'The --all option cannot be combined with --until or --since.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --since flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--since',
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
            message:
                'The --all option cannot be combined with --until or --since.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --until option',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--until',
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
            message:
                'The --all option cannot be combined with --until or --since.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --until flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--tail',
            '--until',
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
            message:
                'The --tail option cannot be combined with --until or --since.',
          ),
        );
      });
    });

    group(
        'when running log command with the hidden --all value together with --since flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--all',
            '--since',
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
            message:
                'The --all option cannot be combined with --until or --since.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --until flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--tail',
            '--until',
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
            message:
                'The --tail option cannot be combined with --until or --since.',
          ),
        );
      });
    });

    group(
        'when running log command with --tail flag together with --since flag',
        () {
      late Future result;
      setUp(() async {
        try {
          result = cli.run([
            'log',
            '--tail',
            '--since',
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
            message:
                'The --tail option cannot be combined with --until or --since.',
          ),
        );
      });
    });
  });
}

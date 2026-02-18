import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger(printToStdout: false);

  final List<String> analyticsEvents = [];

  final client = ClientMock();

  setUp(() async {
    logger.clear();
    analyticsEvents.clear();
  });

  group('Given default non-prod-env suppression (enabled)', () {
    late String settingsDir;
    late CloudCliCommandRunner cli;

    setUp(() async {
      await d.dir('settings_dir').create();
      settingsDir = p.join(d.sandbox, 'settings_dir');

      cli = CloudCliCommandRunner.create(
        logger: logger,
        serviceProvider: CloudCliServiceProvider(
          apiClientFactory: (final globalCfg) => client,
        ),
        onAnalyticsEvent: (final event, final properties) {
          analyticsEvents.add(event);
        },
      );
    });

    group('and no previous invocation', () {
      test('when invoking command'
          ' then does not ask user for consent', () async {
        await cli.run(['--config-dir', settingsDir, 'version']);
        expect(logger.confirmCalls, isEmpty);
      });

      test('when invoking command'
          ' then does not send analytics event', () async {
        await cli.run(['--config-dir', settingsDir, 'version']);
        expect(analyticsEvents, isEmpty);
      });

      test('when invoking command with analytics option set to true'
          ' then does not ask user for consent', () async {
        await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);
        expect(logger.confirmCalls, isEmpty);
      });

      test('when invoking command with analytics option set to true'
          ' then sends analytics event', () async {
        await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);
        expect(analyticsEvents, equals(['version']));
      });
    });

    group('and having set analytics enabled', () {
      setUp(() async {
        await cli.run(['--config-dir', settingsDir, 'settings', '--analytics']);
      });

      test('when invoking command'
          ' then does not ask user for consent', () async {
        await cli.run(['--config-dir', settingsDir, 'version']);
        expect(logger.confirmCalls, isEmpty);
      });

      test('when invoking command'
          ' then does not send analytics event', () async {
        await cli.run(['--config-dir', settingsDir, 'version']);
        expect(analyticsEvents, isEmpty);
      });
    });
  });

  group('Given non-prod-env suppression disabled', () {
    late String settingsDir;
    late CloudCliCommandRunner cli;

    setUp(() async {
      await d.dir('settings_dir').create();
      settingsDir = p.join(d.sandbox, 'settings_dir');

      cli = CloudCliCommandRunner.create(
        logger: logger,
        serviceProvider: CloudCliServiceProvider(
          apiClientFactory: (final globalCfg) => client,
        ),
        onAnalyticsEvent: (final event, final properties) {
          analyticsEvents.add(event);
        },
        enableAnalyticsForAllEnvs: true,
      );
    });

    group('and no previous invocation', () {
      test('when invoking command'
          ' then asks user for consent', () async {
        logger.answerNextConfirmsWith([false]);
        await cli.run(['--config-dir', settingsDir, 'version']);

        expect(logger.confirmCalls, hasLength(1));
        expect(
          logger.confirmCalls.single,
          equalsConfirmCall(
            message:
                'Do you agree to sending anonymous command usage analytics to Serverpod?',
            defaultValue: true,
          ),
        );
      });

      test('when invoking command'
          ' and user declines consent'
          ' then does not send analytics event', () async {
        logger.answerNextConfirmsWith([false]);
        await cli.run(['--config-dir', settingsDir, 'version']);

        expect(analyticsEvents, isEmpty);
      });

      test('when invoking command'
          ' and user gives consent'
          ' then sends analytics event', () async {
        logger.answerNextConfirmsWith([true]);
        await cli.run(['--config-dir', settingsDir, 'version']);

        expect(analyticsEvents, equals(['version']));
      });

      group('and declining consent on first invocation', () {
        setUp(() async {
          logger.answerNextConfirmWith(false);
          await cli.run(['--config-dir', settingsDir, 'version']);
          logger.clear();
        });

        test('when invoking command again'
            ' then does not ask user for consent', () async {
          await cli.run(['--config-dir', settingsDir, 'version']);
          expect(logger.confirmCalls, isEmpty);
        });

        test('when invoking command again'
            ' then does not send analytics event', () async {
          await cli.run(['--config-dir', settingsDir, 'version']);
          expect(analyticsEvents, isEmpty);
        });

        test('when invoking command again with analytics option set to true'
            ' then sends analytics event', () async {
          await cli.run([
            '--config-dir',
            settingsDir,
            'version',
            '--analytics',
          ]);
          expect(analyticsEvents, equals(['version']));
        });

        group('followed by changing analytics to enabled', () {
          setUp(() async {
            await cli.run([
              '--config-dir',
              settingsDir,
              'settings',
              '--analytics',
            ]);
            logger.clear();
            analyticsEvents.clear();
          });

          test('when invoking command'
              ' then does not ask user for consent', () async {
            await cli.run(['--config-dir', settingsDir, 'version']);
            expect(logger.confirmCalls, isEmpty);
          });

          test('when invoking command'
              ' then sends analytics event', () async {
            await cli.run(['--config-dir', settingsDir, 'version']);
            expect(analyticsEvents, equals(['version']));
          });

          test('when invoking command with analytics option set to false'
              ' then does not send analytics event', () async {
            await cli.run([
              '--config-dir',
              settingsDir,
              'version',
              '--no-analytics',
            ]);
            expect(analyticsEvents, isEmpty);
          });
        });
      });

      group('and giving consent on first invocation', () {
        setUp(() async {
          logger.answerNextConfirmWith(true);
          await cli.run(['--config-dir', settingsDir, 'version']);
          logger.clear();
          analyticsEvents.clear();
        });

        test('when invoking command again'
            ' then does not ask user for consent', () async {
          await cli.run(['--config-dir', settingsDir, 'version']);
          expect(logger.confirmCalls, isEmpty);
        });

        test('when invoking command again'
            ' then sends analytics event', () async {
          await cli.run(['--config-dir', settingsDir, 'version']);
          expect(analyticsEvents, equals(['version']));
        });

        test('when invoking command again with analytics option set to false'
            ' then does not send analytics event', () async {
          await cli.run([
            '--config-dir',
            settingsDir,
            'version',
            '--no-analytics',
          ]);
          expect(analyticsEvents, isEmpty);
        });

        group('followed by changing analytics to disabled', () {
          setUp(() async {
            await cli.run([
              '--config-dir',
              settingsDir,
              'settings',
              '--no-analytics',
            ]);
            logger.clear();
            analyticsEvents.clear();
          });

          test('when invoking command'
              ' then does not ask user for consent', () async {
            await cli.run(['--config-dir', settingsDir, 'version']);
            expect(logger.confirmCalls, isEmpty);
          });

          test('when invoking command'
              ' then does not send analytics event', () async {
            await cli.run(['--config-dir', settingsDir, 'version']);
            expect(analyticsEvents, isEmpty);
          });

          test('when invoking command with analytics option set to true'
              ' then sends analytics event', () async {
            await cli.run([
              '--config-dir',
              settingsDir,
              'version',
              '--analytics',
            ]);
            expect(analyticsEvents, equals(['version']));
          });
        });
      });
    });
  });
}

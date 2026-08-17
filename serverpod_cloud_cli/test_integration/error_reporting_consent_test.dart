import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger(printToStdout: false);

  final List<bool> resolvedConsents = [];
  final List<String> resolvedCommands = [];
  final List<String> resolvedApiServers = [];

  final client = ClientMock();

  late String settingsDir;

  setUp(() async {
    logger.clear();
    resolvedConsents.clear();
    resolvedCommands.clear();
    resolvedApiServers.clear();

    await d.dir('settings_dir').create();
    settingsDir = p.join(d.sandbox, 'settings_dir');
  });

  CloudCliCommandRunner createCli({
    final bool enableAnalyticsForAllEnvs = false,
    final ClientMock? clientOverride,
  }) {
    return CloudCliCommandRunner.create(
      logger: logger,
      serviceProvider: CloudCliServiceProvider(
        apiClientFactory: (final globalCfg) => clientOverride ?? client,
      ),
      onAnalyticsEvent: (final event, final properties) {},
      onAnalyticsConsentResolved: resolvedConsents.add,
      onCommandResolved: resolvedCommands.add,
      onApiServerResolved: resolvedApiServers.add,
      enableAnalyticsForAllEnvs: enableAnalyticsForAllEnvs,
    );
  }

  group('Given default non-prod-env suppression (enabled)', () {
    late CloudCliCommandRunner cli;

    setUp(() {
      cli = createCli();
    });

    test('when invoking command'
        ' then consent is resolved to false', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedConsents, equals([false]));
    });

    test('when invoking command with analytics option set to true'
        ' then consent is resolved to true', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

      expect(resolvedConsents, equals([true]));
    });

    test('when invoking command with analytics option set to false'
        ' then consent is resolved to false', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--no-analytics']);

      expect(resolvedConsents, equals([false]));
    });
  });

  group('Given a command resolution listener and an authenticated client', () {
    late CloudCliCommandRunner cli;

    setUp(() {
      cli = createCli(
        clientOverride: ClientMock(
          authKeyProvider: InMemoryKeyManager.authenticated(),
        ),
      );
    });

    test('when invoking a top-level command'
        ' then the command name and used flags are resolved', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedCommands, equals(['version --config-dir']));
    });

    test('when invoking a subcommand'
        ' then the space-separated command name path is resolved', () async {
      try {
        await cli.run(['--config-dir', settingsDir, 'auth', 'logout']);
      } catch (_) {
        // expected
      }

      expect(resolvedCommands, equals(['auth logout --config-dir']));
    });

    test(
      'when invoking a subcommand with a project argument'
      ' then the resolved command path contains the flag but not its value',
      () async {
        try {
          await cli.run([
            '--config-dir',
            settingsDir,
            'variable',
            'list',
            '--project',
            'secret-project-id',
          ]);
        } catch (_) {
          // expected
        }

        expect(
          resolvedCommands,
          equals(['variable list --config-dir --project']),
        );
      },
    );

    test('when invoking a command'
        ' then the default API server URL is resolved', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedApiServers, equals([HostConstants.serverpodCloudApi]));
    });

    test('when invoking a command with an API server URL override'
        ' then the overridden API server URL is resolved', () async {
      await cli.run([
        '--config-dir',
        settingsDir,
        '--api-url',
        'http://localhost:8080',
        'version',
      ]);

      expect(resolvedApiServers, equals(['http://localhost:8080']));
    });
  });

  group('Given non-prod-env suppression disabled', () {
    late CloudCliCommandRunner cli;

    setUp(() {
      cli = createCli(enableAnalyticsForAllEnvs: true);
    });

    test('when invoking command'
        ' and user gives consent'
        ' then consent is resolved to true', () async {
      logger.answerNextConfirmWith(true);
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedConsents, equals([true]));
    });

    test('when invoking command'
        ' and user declines consent'
        ' then consent is resolved to false', () async {
      logger.answerNextConfirmWith(false);
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedConsents, equals([false]));
    });
  });
}

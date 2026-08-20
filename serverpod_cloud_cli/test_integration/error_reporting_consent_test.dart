import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_user_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger(printToStdout: false);

  final List<CliRunContext> resolvedContexts = [];

  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );

  late String settingsDir;

  setUp(() async {
    logger.clear();
    resolvedContexts.clear();

    await d.dir('settings_dir').create();
    settingsDir = p.join(d.sandbox, 'settings_dir');
  });

  CloudCliCommandRunner createCli({
    final bool enableAnalyticsForAllEnvs = false,
    final OnRunContextResolved? onRunContextResolved,
  }) {
    return CloudCliCommandRunner.create(
      logger: logger,
      serviceProvider: CloudCliServiceProvider(
        apiClientFactory: (final globalCfg) => client,
      ),
      onAnalyticsEvent: (final event, final properties) {},
      onRunContextResolved: onRunContextResolved ?? resolvedContexts.add,
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

      expect(resolvedContexts.single.analyticsConsent, isFalse);
    });

    test('when invoking command with analytics option set to true'
        ' then consent is resolved to true', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--analytics']);

      expect(resolvedContexts.single.analyticsConsent, isTrue);
    });

    test('when invoking command with analytics option set to false'
        ' then consent is resolved to false', () async {
      await cli.run(['--config-dir', settingsDir, 'version', '--no-analytics']);

      expect(resolvedContexts.single.analyticsConsent, isFalse);
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

      expect(resolvedContexts.single.analyticsConsent, isTrue);
    });

    test('when invoking command'
        ' and user declines consent'
        ' then consent is resolved to false', () async {
      logger.answerNextConfirmWith(false);
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedContexts.single.analyticsConsent, isFalse);
    });

    test('when invoking command'
        ' and consent was given in an earlier run'
        ' then consent is resolved to true without asking again', () async {
      logger.answerNextConfirmWith(true);
      await cli.run(['--config-dir', settingsDir, 'version']);
      logger.clear();
      resolvedContexts.clear();

      await createCli(
        enableAnalyticsForAllEnvs: true,
      ).run(['--config-dir', settingsDir, 'version']);

      expect(resolvedContexts.single.analyticsConsent, isTrue);
    });

    test('when invoking command'
        ' and consent was given in an earlier run'
        ' then the user is not asked again', () async {
      logger.answerNextConfirmWith(true);
      await cli.run(['--config-dir', settingsDir, 'version']);
      logger.clear();

      await createCli(
        enableAnalyticsForAllEnvs: true,
      ).run(['--config-dir', settingsDir, 'version']);

      expect(logger.confirmCalls, isEmpty);
    });
  });

  group('Given a run context listener that throws', () {
    late CloudCliCommandRunner cli;

    setUp(() {
      cli = createCli(
        onRunContextResolved: (final context) =>
            throw StateError('run context listener failure'),
      );
    });

    test('when invoking a command'
        ' then the command is still run', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(
        logger.infoCalls.map((final call) => call.message),
        contains(startsWith('Serverpod Cloud CLI version:')),
      );
    });

    test('when invoking a command'
        ' then no error is logged', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(logger.errorCalls, isEmpty);
    });
  });

  group('Given a run context listener', () {
    late CloudCliCommandRunner cli;

    setUp(() {
      cli = createCli();
    });

    test('when invoking a top-level command'
        ' then the command name is resolved', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedContexts.single.command, 'version');
    });

    test('when invoking a top-level command'
        ' then the used flags are resolved separately', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedContexts.single.flags, ['--config-dir']);
    });

    test('when invoking a subcommand'
        ' then the space-separated command name path is resolved', () async {
      await cli.run(['--config-dir', settingsDir, 'auth', 'logout']);

      expect(resolvedContexts.single.command, 'auth logout');
    });

    test('when invoking a subcommand with a project argument'
        ' then the resolved command contains no flags', () async {
      when(
        () => client.environmentVariables.list(any()),
      ).thenAnswer((final _) async => <EnvironmentVariable>[]);

      await cli.run([
        '--config-dir',
        settingsDir,
        'variable',
        'list',
        '--project',
        'secret-project-id',
      ]);

      expect(resolvedContexts.single.command, 'variable list');
    });

    test(
      'when invoking a subcommand with a project argument'
      ' then the resolved flags contain the flag name but not its value',
      () async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenAnswer((final _) async => <EnvironmentVariable>[]);

        await cli.run([
          '--config-dir',
          settingsDir,
          'variable',
          'list',
          '--project',
          'secret-project-id',
        ]);

        expect(resolvedContexts.single.flags, ['--config-dir', '--project']);
      },
    );

    test('when invoking without a command'
        ' then the run context is resolved with a null command', () async {
      await cli.run(['--config-dir', settingsDir]);

      expect(resolvedContexts.single.command, isNull);
    });

    test('when invoking a command'
        ' then the default API server URL is resolved', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(
        resolvedContexts.single.apiServerUrl,
        HostConstants.serverpodCloudApi,
      );
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

      expect(resolvedContexts.single.apiServerUrl, 'http://localhost:8080');
    });

    test('when invoking a command without stored cloud user data'
        ' then the cloud user id is resolved to null', () async {
      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedContexts.single.cloudUserId, isNull);
    });

    test('when invoking a command with stored cloud user data'
        ' then the cloud user id is resolved', () async {
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData('cloud-user-id'),
        localStoragePath: settingsDir,
      );

      await cli.run(['--config-dir', settingsDir, 'version']);

      expect(resolvedContexts.single.cloudUserId, 'cloud-user-id');
    });
  });
}

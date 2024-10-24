import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/env_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/login_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/logout_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

/// Represents the Serverpod Cloud CLI main command, its global options, and subcommands.
class CloudCliCommandRunner extends BetterCommandRunner {
  final Version version;
  final Logger logger;

  /// The curremt global configuration for the Serverpod Cloud CLI.
  /// (Since this object is re-entrant, the global config is regenerated each call to [runCommand].)
  GlobalConfiguration globalConfiguration = GlobalConfiguration();

  final CloudCliServiceProvider serviceProvider = CloudCliServiceProvider();

  CloudCliCommandRunner._({
    required this.logger,
    required this.version,
    super.setLogLevel,
    super.logError,
    super.logInfo,
  }) : super(
          'scloud',
          'Manage your Serverpod Cloud projects',
          wrapTextColumn: logger.wrapTextColumn,
        );

  static CloudCliCommandRunner create({
    required final Logger logger,
    required final Version version,
  }) {
    final runner = CloudCliCommandRunner._(
      logger: logger,
      version: version,
      logInfo: logger.info,
      logError: logger.error,
      setLogLevel: ({
        final String? commandName,
        required final CommandRunnerLogLevel parsedLogLevel,
      }) =>
          _configureLogLevel(
        logger: logger,
        parsedLogLevel: parsedLogLevel,
        commandName: commandName,
      ),
    );

    // Add global options
    GlobalOption.values.prepareForParsing(runner.argParser);

    // Add commands (which may in turn have their own options and subcommands)
    runner.addCommands([
      VersionCommand(logger: logger),
      CloudLoginCommand(logger: logger),
      CloudLogoutCommand(logger: logger),
      CloudProjectCommand(logger: logger),
      CloudDeployCommand(logger: logger),
      CloudEnvCommand(logger: logger),
      CloudCustomDomainCommand(logger: logger),
      CloudLogCommand(logger: logger)
    ]);

    return runner;
  }

  @override
  Future<void> runCommand(final ArgResults topLevelResults) async {
    globalConfiguration = GlobalConfiguration(
      args: topLevelResults,
      env: Platform.environment,
    );

    serviceProvider.initialize(
      globalConfiguration: globalConfiguration,
      logger: logger,
    );

    try {
      await super.runCommand(topLevelResults);
    } finally {
      serviceProvider.shutdown();
    }
  }

  static void _configureLogLevel({
    required final Logger logger,
    required final CommandRunnerLogLevel parsedLogLevel,
    final String? commandName,
  }) {
    var logLevel = LogLevel.info;

    if (parsedLogLevel == CommandRunnerLogLevel.verbose) {
      logLevel = LogLevel.debug;
    } else if (parsedLogLevel == CommandRunnerLogLevel.quiet) {
      logLevel = LogLevel.nothing;
    }

    logger.logLevel = logLevel;
  }
}

String _getDefaultStoragePath() {
  return ResourceManager.localStorageDirectory.path;
}

/// The global configuration options for the Serverpod Cloud CLI.
enum GlobalOption implements OptionDefinition {
  authDir(
    ConfigOption(
      argName: 'auth-dir',
      envName: 'SERVERPOD_CLOUD_AUTH_DIR',
      helpText:
          'Override the directory path where the serverpod cloud authentication file is stored.',
      defaultFrom: _getDefaultStoragePath,
    ),
  ),
  // Developer options and flags
  apiServer(
    ConfigOption(
      argName: 'api-url',
      envName: 'SERVERPOD_CLOUD_API_SERVER_URL',
      helpText: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    ),
  ),

  consoleServer(
    ConfigOption(
      argName: 'console-url',
      envName: 'SERVERPOD_CLOUD_CONSOLE_SERVER_URL',
      helpText: 'The URL to the Serverpod cloud console server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudConsole,
    ),
  );

  const GlobalOption(this.option);

  @override
  final ConfigOption option;
}

/// The current global configuration values for the Serverpod Cloud CLI.
class GlobalConfiguration extends Configuration {
  GlobalConfiguration({
    super.args,
    super.env,
  }) : super.fromEnvAndArgs(options: GlobalOption.values);

  String get authDir => value(GlobalOption.authDir);

  String get apiServer => value(GlobalOption.apiServer);

  String get consoleServer => value(GlobalOption.consoleServer);
}

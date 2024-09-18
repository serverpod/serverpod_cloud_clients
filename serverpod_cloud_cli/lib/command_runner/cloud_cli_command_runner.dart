import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/login_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/logout_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

/// Represents the Serverpod Cloud CLI main command, its global options, and subcommands.
class CloudCliCommandRunner extends BetterCommandRunner {
  final Version version;
  final Logger logger;

  /// The curremt global configuration for the Serverpod Cloud CLI.
  /// (Since this object is re-entrant, the global config is regenerated each call to [runCommand].)
  GlobalConfiguration globalConfiguration = GlobalConfiguration();

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
    GlobalOption.values.addToArgParser(runner.argParser);

    // Add commands (which may in turn have their own options and subcommands)
    runner.addCommands([
      VersionCommand(logger: logger),
      CloudLoginCommand(logger: logger),
      CloudLogoutCommand(logger: logger),
      CloudProjectCommand(logger: logger),
      CloudDeployCommand(logger: logger),
    ]);

    return runner;
  }

  @override
  Future<void> runCommand(final ArgResults topLevelResults) async {
    globalConfiguration = GlobalConfiguration(
      args: topLevelResults,
      env: Platform.environment,
    );

    return super.runCommand(topLevelResults);
  }

  /// Gets a [Client] for the Serverpod Cloud.
  /// Will contain the authentication if the user is authenticated.
  Future<Client> getClient({
    final ServerpodCloudData? cloudDataOverride,
  }) async {
    final localStoragePath = globalConfiguration.authDir;
    final serverAddress = globalConfiguration.server;
    final address =
        serverAddress.endsWith('/') ? serverAddress : '$serverAddress/';

    final cloudClient = Client(
      address,
      authenticationKeyManager: CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: localStoragePath,
        cloudDataOverride: cloudDataOverride,
      ),
    );
    return cloudClient;
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
      argAbbrev: 'd',
      envName: 'SERVERPOD_CLOUD_AUTH_DIR',
      helpText:
          'Override the directory path where the serverpod cloud authentication file is stored.',
      defaultFrom: _getDefaultStoragePath,
    ),
  ),
  // Developer options and flags
  server(
    ConfigOption(
      argName: 'server',
      argAbbrev: 's',
      envName: 'SERVERPOD_CLOUD_SERVER_URL',
      helpText: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
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

  String get server => value(GlobalOption.server);
}

import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/env_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/secret_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_version_checker.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/capitalize.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

/// Represents the Serverpod Cloud CLI main command, its global options, and subcommands.
class CloudCliCommandRunner extends BetterCommandRunner {
  final Version version;
  final CommandLogger logger;
  final CloudCliServiceProvider serviceProvider;

  final VersionCommand _versionCommand;

  GlobalConfiguration? _globalConfiguration;

  /// The curremt global configuration for the Serverpod Cloud CLI.
  /// (Since this object is re-entrant, the global config is regenerated each call to [runCommand].)
  GlobalConfiguration get globalConfiguration {
    final globalConfig = _globalConfiguration;
    if (globalConfig == null) {
      throw StateError('Global configuration not initialized');
    }
    return globalConfig;
  }

  CloudCliCommandRunner._({
    required this.logger,
    required this.version,
    required this.serviceProvider,
    super.setLogLevel,
  })  : _versionCommand = VersionCommand(logger: logger),
        super(
          'scloud',
          'Manage your Serverpod Cloud projects',
          wrapTextColumn: logger.wrapTextColumn,
          messageOutput: MessageOutput(
            logUsage: logger.info,
          ),
        );

  static CloudCliCommandRunner create({
    required final CommandLogger logger,
    final Version? version,
    final CloudCliServiceProvider? serviceProvider,
  }) {
    final runner = CloudCliCommandRunner._(
      logger: logger,
      version: version ?? cliVersion,
      serviceProvider: serviceProvider ?? CloudCliServiceProvider(),
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
      runner._versionCommand,
      CloudAuthCommand(logger: logger),
      CloudProjectCommand(logger: logger),
      CloudDeployCommand(logger: logger),
      CloudEnvCommand(logger: logger),
      CloudCustomDomainCommand(logger: logger),
      CloudLogCommand(logger: logger),
      CloudStatusCommand(logger: logger),
      CloudSecretCommand(logger: logger),
      CloudDbCommand(logger: logger),
      CloudLaunchCommand(logger: logger),
    ]);

    return runner;
  }

  @override
  Future<void> runCommand(final ArgResults topLevelResults) async {
    _globalConfiguration = GlobalConfiguration(
      args: topLevelResults,
      env: Platform.environment,
    );

    if (globalConfiguration.errors.isNotEmpty) {
      final buffer = StringBuffer();
      final errors = globalConfiguration.errors.map(
        (final e) => '${e.capitalize()}.',
      );
      buffer.writeAll(errors, '\n');
      usageException(buffer.toString());
    }

    logger.configuration = globalConfiguration;

    serviceProvider.initialize(
      globalConfiguration: globalConfiguration,
      logger: logger,
    );

    if (globalConfiguration.version) {
      await _versionCommand.run();
    }

    final Version? latestVersion;
    try {
      latestVersion = await CLIVersionChecker.fetchLatestCLIVersion(
        logger: logger,
        localStoragePath: globalConfiguration.scloudDir,
      );
    } catch (e) {
      logger.debug('Failed to fetch latest CLI version: $e');
      throw ErrorExitException();
    }

    if (latestVersion != null && version < latestVersion) {
      final isRequiredUpdate = CLIVersionChecker.isBreakingUpdate(
        currentVersion: version,
        latestVersion: latestVersion,
      );

      _printUpdateCLIPrompt(
        latestVersion: latestVersion,
        logger: logger,
        isRequiredUpdate: isRequiredUpdate,
      );

      if (isRequiredUpdate) throw ErrorExitException();
    }

    try {
      await super.runCommand(topLevelResults);
    } finally {
      serviceProvider.shutdown();
    }
  }

  @override
  String? get usageFooter =>
      '\nSee the full documentation at: https://docs.serverpod.cloud/';

  /// Selects and verifies the project directory that is either specified by the global
  /// configuration, or files found near the current directory.
  ///
  /// Verifies that the directory is a valid Serverpod server directory
  /// using [isServerpodServerDirectory] and gives feedback to the user.
  ///
  /// Throws [ExitException] if no valid project directory could be determined.
  Directory verifiedProjectDirectory() {
    final selectedProjectDir = selectProjectDirectory();
    final projectDirectory =
        Directory(selectedProjectDir ?? Directory.current.path);

    if (!isServerpodServerDirectory(projectDirectory)) {
      logProjectDirIsNotAServerpodServerDirectory(logger, selectedProjectDir);
      throw ErrorExitException();
    }

    logger.debug('Using project directory `${projectDirectory.path}`');
    return projectDirectory;
  }

  /// Selects a project directory that is either specified by the global
  /// configuration, or files found near the current directory.
  /// If no project directory is specified nor found then null is returned.
  ///
  /// Does not verify that the directory exists and is a valid
  /// Serverpod server directory.
  /// See [isServerpodServerDirectory] for verification.
  String? selectProjectDirectory() {
    // if explicitly set, use the specified directory
    final specifiedDir = globalConfiguration.projectDir;
    if (specifiedDir != null) {
      return specifiedDir;
    }

    // if scloud.<ext> is set or found, use its directory
    final configFile = globalConfiguration.projectConfigFile;
    if (configFile != null) {
      return p.dirname(configFile);
    }

    // if server pubspec.yaml is found near the current directory, use its directory
    final serverPubspecFile = _serverPubspecFileFinder();
    if (serverPubspecFile != null) {
      return p.dirname(serverPubspecFile);
    }

    return null;
  }

  String? _serverPubspecFileFinder() {
    final finder = scloudFileFinder(
      fileBaseName: 'pubspec',
      supportedExtensions: ['yaml', 'yml'],
      fileContentCondition: (final filePath) =>
          isServerpodServerPackage(File(filePath)),
    );
    try {
      return finder(null);
    } on AmbiguousSearchException catch (e) {
      logger.error(e.message);
      return null;
    }
  }

  static void _configureLogLevel({
    required final CommandLogger logger,
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

  static void _printUpdateCLIPrompt({
    required final Version latestVersion,
    required final CommandLogger logger,
    required final bool isRequiredUpdate,
  }) {
    var infoMessage =
        '''A new version $latestVersion of Serverpod Cloud CLI is available!

To update to the latest version, run "dart pub global activate serverpod_cloud_cli".''';

    if (isRequiredUpdate) {
      infoMessage = '$infoMessage You need to update the CLI to continue.';
    }

    logger.box(
      infoMessage,
    );
  }
}

String _getDefaultStoragePath() {
  return ResourceManager.localStorageDirectory.path;
}

/// The global configuration options for the Serverpod Cloud CLI.
enum GlobalOption implements OptionDefinition {
  version(
    ConfigOption(
      argName: 'version',
      helpText: VersionCommand.usageDescription,
      isFlag: true,
      negatable: false,
      defaultsTo: 'false',
    ),
  ),
  scloudDir(
    ConfigOption(
      argName: 'scloud-dir',
      envName: 'SERVERPOD_CLOUD_DIR',
      helpText:
          'Override the directory path where Serverpod Cloud cache/authentication files are stored.',
      fromDefault: _getDefaultStoragePath,
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
  ),
  skipConfirmation(
    ConfigOption(
      argName: 'skip-confirmation',
      helpText:
          'Should be used in CI environment to bypass confirmation prompts.',
      hide: true,
      isFlag: true,
      defaultsTo: 'false',
    ),
  ),

  projectDir(
    ConfigOption(
      argName: 'project-dir',
      argAbbrev: 'd',
      envName: 'SERVERPOD_CLOUD_PROJECT_DIR',
      helpText: 'The path to the Serverpod Cloud project server directory.',
      // (no general default value since significant whether explicitly specified)
    ),
  ),
  projectConfigFile(
    ConfigOption(
      argName: 'project-config-file',
      envName: 'SERVERPOD_CLOUD_PROJECT_CONFIG_FILE',
      fromCustom: _projectConfigFileFinder,
      helpText: 'The path to the Serverpod Cloud project configuration file.',
    ),
  ),
  projectConfigContent(
    ConfigOption(
      argName: 'project-config-content',
      envName: 'SERVERPOD_CLOUD_PROJECT_CONFIG_CONTENT',
      helpText: 'Override the scloud project configuration with a YAML string.',
    ),
  );

  const GlobalOption(this.option);

  @override
  final ConfigOption option;
}

String? _projectConfigFileFinder(final Configuration cfg) {
  // if the dir option is set and it exists, we use it as starting directory
  final finder = scloudFileFinder<Configuration>(
    fileBaseName: ProjectConfigFileConstants.fileBaseName,
    supportedExtensions: ['yaml', 'yml', 'json'],
    startingDirectory: (final cfg) {
      final specifiedDir = cfg.valueOrNull(GlobalOption.projectDir);
      if (specifiedDir != null && !Directory(specifiedDir).existsSync()) {
        return null;
      }
      return specifiedDir;
    },
  );
  return finder(cfg);
}

/// The current global configuration values for the Serverpod Cloud CLI.
class GlobalConfiguration extends Configuration {
  GlobalConfiguration({
    super.args,
    super.env,
  }) : super.fromEnvAndArgs(options: GlobalOption.values);

  bool get version => flag(GlobalOption.version);

  String get scloudDir => value(GlobalOption.scloudDir);

  String get apiServer => value(GlobalOption.apiServer);

  String get consoleServer => value(GlobalOption.consoleServer);

  bool get skipConfirmation => flag(GlobalOption.skipConfirmation);

  String? get projectDir => valueOrNull(GlobalOption.projectDir);

  String? get projectConfigFile => valueOrNull(GlobalOption.projectConfigFile);

  String? get projectConfigContent =>
      valueOrNull(GlobalOption.projectConfigContent);
}

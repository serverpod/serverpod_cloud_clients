import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_tools/better_command_runner.dart';
import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show ConsoleRoutes;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/context/context_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain/custom_domain_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch/launch_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/me/me_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/variable/variable_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version/version_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_run_context_resolver.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_updater.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_version_checker.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/activation_checker.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

import 'commands/admin/admin_command.dart';
import 'commands/settings/settings_command.dart';
import 'completion/completion_script_carapace.dart';
import 'completion/completion_script_completely.dart';

/// The resolved context of a CLI run.
///
/// [command] is the space-separated command name path including subcommands
/// (e.g. `variable set`), or null when the run resolved no command.
/// [flags] holds the names of the flags and options passed on the command
/// line (e.g. `['--project']`), without their values.
/// Neither contains option values or positional arguments.
/// [cloudUserId] is the id of the logged in cloud user, or null when the
/// user is not logged in.
/// [baseCommand] is the invocation path the CLI was run through.
typedef CliRunContext = ({
  bool analyticsConsent,
  String? command,
  List<String> flags,
  String apiServerUrl,
  String? cloudUserId,
  BaseCommandInvocation baseCommand,
});

typedef OnRunContextResolved = void Function(CliRunContext context);

/// Reports an error for diagnostics.
typedef OnErrorReport =
    Future<void> Function(Object error, StackTrace stackTrace);

/// Represents the Serverpod Cloud CLI main command, its global options, and subcommands.
class CloudCliCommandRunner extends BetterCommandRunner<GlobalOption, void> {
  final Version version;
  final CommandLogger logger;
  final CloudCliServiceProvider _serviceProvider;

  /// Called with the resolved run context each time [runCommand] is entered,
  /// which is after the global configuration and the analytics consent are
  /// resolved.
  ///
  /// An error thrown by the callback is logged and ignored, so telemetry
  /// cannot break the command being run.
  final OnRunContextResolved? _onRunContextResolved;

  /// Called to report an error that the CLI handled but that shall still be
  /// reported for diagnostics.
  final OnErrorReport? _onErrorReport;

  /// If true, analytics will be not be suppressed for non-production usage.
  final bool _enableAnalyticsForAllEnvs;

  /// If true, the admin subcommands are enabled.
  final bool _adminUserMode;

  /// The invocation path the CLI was run through, as reported to telemetry.
  final BaseCommandInvocation _baseCommandInvocation;

  final VersionCommand _versionCommand;

  final CliUpdater _cliUpdater;

  /// The version this process was already updated to, if any,
  /// which must not be installed again.
  final Version? _attemptedUpdateVersion;

  GlobalConfiguration? _globalConfiguration;

  bool _analyticsConsent = false;

  /// The curremt global configuration for the Serverpod Cloud CLI.
  @override
  GlobalConfiguration get globalConfiguration {
    final globalConfig = _globalConfiguration;
    if (globalConfig == null) {
      throw StateError('Global configuration not initialized');
    }
    return globalConfig;
  }

  /// Sets the curremt global configuration for the Serverpod Cloud CLI.
  /// (Since this object is re-entrant, the global config is regenerated
  /// each call to [run].)
  @override
  set globalConfiguration(Configuration<GlobalOption> configuration) {
    _globalConfiguration = GlobalConfiguration.from(
      configuration: configuration,
    );
    logger.configuration = _globalConfiguration;
  }

  /// Gets the initialized service provider for the Serverpod Cloud CLI.
  /// Must not be called before the [run] method has been invoked.
  CloudCliServiceProvider get serviceProvider {
    if (!_serviceProvider.initialized) {
      _serviceProvider.initialize(
        globalConfiguration: globalConfiguration,
        logger: logger,
      );
    }
    return _serviceProvider;
  }

  CloudCliCommandRunner._({
    required this.logger,
    required this.version,
    required String baseCommand,
    required CloudCliServiceProvider serviceProvider,
    required bool enableAnalyticsForAllEnvs,
    required bool adminUserMode,
    required CliUpdater cliUpdater,
    required Version? attemptedUpdateVersion,
    OnRunContextResolved? onRunContextResolved,
    OnErrorReport? onErrorReport,
    super.onAnalyticsEvent,
    super.setLogLevel,
  }) : _onRunContextResolved = onRunContextResolved,
       _onErrorReport = onErrorReport,
       _serviceProvider = serviceProvider,
       _cliUpdater = cliUpdater,
       _attemptedUpdateVersion = attemptedUpdateVersion,
       _versionCommand = VersionCommand(logger: logger),
       _enableAnalyticsForAllEnvs = enableAnalyticsForAllEnvs,
       _adminUserMode = adminUserMode,
       _baseCommandInvocation = BaseCommandInvocation.from(baseCommand),
       super(
         baseCommand,
         'Manage your Serverpod Cloud projects',
         globalOptions: GlobalOption.values,
         wrapTextColumn: logger.wrapTextColumn,
         messageOutput: MessageOutput(usageLogger: logger.info),
         enableCompletionCommand: true,
         embeddedCompletions: [
           completionScriptCompletely,
           completionScriptCarapace,
         ],
       );

  /// The environment variable that overrides the base command name shown in
  /// user-facing text.
  ///
  /// It holds the literal display name, such as `serverpod cloud`, and is
  /// written by the wrapper that invokes this CLI under another name - above
  /// all the `serverpod cloud` command of the Serverpod framework. The value
  /// is used verbatim, and an unset or empty value means [defaultBaseCommand].
  static const baseCommandEnvName = 'SERVERPOD_CLOUD_BASE_COMMAND';

  static CloudCliCommandRunner create({
    required CommandLogger logger,
    Version? version,
    CloudCliServiceProvider? serviceProvider,
    OnAnalyticsEvent? onAnalyticsEvent,
    OnRunContextResolved? onRunContextResolved,
    OnErrorReport? onErrorReport,
    bool enableAnalyticsForAllEnvs = false,
    bool? adminUserMode,
    CliUpdater? cliUpdater,
    Version? attemptedUpdateVersion,
    String? baseCommand,
  }) {
    adminUserMode ??=
        bool.tryParse(
          Platform.environment['SERVERPOD_CLOUD_ADMIN_USER_MODE'] ?? 'false',
          caseSensitive: false,
        ) ??
        false;

    baseCommand ??= Platform.environment[baseCommandEnvName];
    final resolvedBaseCommand = baseCommand == null || baseCommand.isEmpty
        ? defaultBaseCommand
        : baseCommand;

    final runner = CloudCliCommandRunner._(
      logger: logger,
      version: version ?? cliVersion,
      baseCommand: resolvedBaseCommand,
      serviceProvider: serviceProvider ?? CloudCliServiceProvider(),
      enableAnalyticsForAllEnvs: enableAnalyticsForAllEnvs,
      adminUserMode: adminUserMode,
      cliUpdater: cliUpdater ?? const DartCliUpdater(),
      attemptedUpdateVersion:
          attemptedUpdateVersion ?? attemptedCliUpdateVersion(),
      onRunContextResolved: onRunContextResolved,
      onErrorReport: onErrorReport,
      onAnalyticsEvent: onAnalyticsEvent,
      setLogLevel:
          ({
            String? commandName,
            required CommandRunnerLogLevel parsedLogLevel,
          }) => _configureLogLevel(
            logger: logger,
            parsedLogLevel: parsedLogLevel,
            commandName: commandName,
          ),
    );

    // Add commands (which may in turn have their own options and subcommands)
    runner.addCommands([
      runner._versionCommand,
      CloudAuthCommand(logger: logger),
      CloudMeCommand(logger: logger),
      CloudProjectCommand(logger: logger),
      CloudContextCommand(logger: logger),
      CloudDeployCommand(logger: logger),
      CloudVariableCommand(logger: logger),
      CloudCustomDomainCommand(logger: logger),
      CloudLogCommand(logger: logger),
      CloudStatusCommand(logger: logger),
      CloudDeploymentsCommand(logger: logger),
      CloudPasswordCommand(logger: logger),
      CloudDbCommand(logger: logger),
      CloudLaunchCommand(logger: logger),
      CliUserSettingsCommand(logger: logger),
      if (adminUserMode) CloudAdminCommand(logger: logger, hidden: false),
    ]);

    return runner;
  }

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    try {
      try {
        _onRunContextResolved?.call(_runContext(topLevelResults));
      } catch (e, stackTrace) {
        logger.debug('Failed to resolve the run context: $e\n$stackTrace');
      }

      if (globalConfiguration.version) {
        await _versionCommand.run();
        return;
      }

      final latestVersion = await _fetchLatestCliVersion();

      if (latestVersion != null && version < latestVersion) {
        if (_isRequiredUpdate(latestVersion) &&
            _attemptedUpdateVersion != latestVersion) {
          final didRerun = await _updateAndRerunCommand(
            latestVersion: latestVersion,
            topLevelResults: topLevelResults,
          );
          if (didRerun) {
            return;
          }
        } else {
          _alertUpdateNotInstalled(latestVersion);
        }
      }

      await super.runCommand(topLevelResults);
    } finally {
      _serviceProvider.shutdown();
    }
  }

  Future<Version?> _fetchLatestCliVersion() async {
    try {
      return await CLIVersionChecker.fetchLatestCLIVersion(
        logger: logger,
        localStoragePath: globalConfiguration.scloudDir.path,
      );
    } catch (e) {
      logger.debug('Failed to fetch latest CLI version: $e');
      return null;
    }
  }

  /// Whether [latestVersion] is a breaking update that the user must install
  /// to continue.
  bool _isRequiredUpdate(Version latestVersion) =>
      CLIVersionChecker.isBreakingUpdate(
        currentVersion: version,
        latestVersion: latestVersion,
      ) &&
      globalConfiguration.breakingVersionCheck;

  /// Updates the CLI to [latestVersion] and reruns the command with it.
  ///
  /// Returns true if the command was rerun, and so must not be run again in
  /// this process. Returns false if the update failed and the command shall
  /// run on the current version.
  ///
  /// Throws [ErrorExitException] with [ExitCodeConstants.scloudUpdatedRerunRequired]
  /// if the rerun is turned off, with the rerun's exit code if the rerun
  /// failed, and with [ExitCodeConstants.scloudUpdateRequired] if a breaking
  /// update could not be installed.
  /// Throws [UnexpectedErrorExitException] if the rerun could not be started.
  Future<bool> _updateAndRerunCommand({
    required Version latestVersion,
    required ArgResults topLevelResults,
  }) async {
    if (!_cliUpdater.canSelfUpdate) {
      logger.debug('This CLI installation cannot update itself.');
      _alertUpdateNotInstalled(latestVersion);
      return false;
    }

    final updated = await logger.progress(
      'Updating Serverpod Cloud CLI to $latestVersion',
      () async {
        try {
          await _cliUpdater.install(latestVersion, logger: logger);
          return true;
        } on CliUpdateFailedException catch (e, stackTrace) {
          logger.debug('Failed to update the CLI: $e\n$stackTrace');
          await _reportError(e, stackTrace);
          return false;
        }
      },
      successMessage: 'Updated Serverpod Cloud CLI to $latestVersion',
    );

    if (!updated) {
      _alertUpdateNotInstalled(latestVersion);
      return false;
    }

    if (globalConfiguration.exitOnUpdated) {
      throw ErrorExitException.code(
        ExitCodeConstants.scloudUpdatedRerunRequired,
        'Updated to $latestVersion, the command must be run again.',
      );
    }

    final int rerunExitCode;
    try {
      rerunExitCode = await _cliUpdater.rerun(
        topLevelResults.arguments,
        installedVersion: latestVersion,
        logger: logger,
      );
    } on ProcessException catch (e, stackTrace) {
      await _reportError(e, stackTrace);
      logger.error(
        'The CLI was updated to $latestVersion,'
        ' but the command could not be run again.',
        hint: 'Run the command again.',
      );
      throw UnexpectedErrorExitException(e.message, e, stackTrace);
    }

    if (rerunExitCode != 0) {
      throw ErrorExitException.code(
        rerunExitCode,
        'The rerun of the command exited with $rerunExitCode.',
      );
    }

    return true;
  }

  /// Alerts that [latestVersion] is available but was not installed.
  ///
  /// Throws [ErrorExitException] with [ExitCodeConstants.scloudUpdateRequired]
  /// if the update is breaking and the breaking version check is enabled.
  void _alertUpdateNotInstalled(Version latestVersion) {
    final isRequiredUpdate = _isRequiredUpdate(latestVersion);

    _printUpdateCLIAlert(
      latestVersion: latestVersion,
      logger: logger,
      isRequiredUpdate: isRequiredUpdate,
    );

    if (isRequiredUpdate) {
      throw ErrorExitException.code(
        ExitCodeConstants.scloudUpdateRequired,
        'You need to update the CLI to continue.',
      );
    }
  }

  /// Reports [error] for diagnostics, if a reporter is configured.
  ///
  /// Never throws, so reporting cannot break the command being run.
  Future<void> _reportError(Object error, StackTrace stackTrace) async {
    try {
      await _onErrorReport?.call(error, stackTrace);
    } catch (e, s) {
      logger.debug('Failed to report the error: $e\n$s');
    }
  }

  CliRunContext _runContext(ArgResults topLevelResults) {
    final globalConfig = globalConfiguration;
    return (
      analyticsConsent: _analyticsConsent,
      command: CliRunContextResolver.commandPath(topLevelResults),
      flags: CliRunContextResolver.commandFlags(topLevelResults),
      apiServerUrl: globalConfig.apiServer,
      cloudUserId: CliRunContextResolver.fetchCloudUserId(
        globalConfig.scloudDir.path,
      ),
      baseCommand: _baseCommandInvocation,
    );
  }

  @override
  void sendAnalyticsEvent(
    String event, [
    Map<String, dynamic> properties = const {},
  ]) {
    final enrichedProperties = Map<String, dynamic>.from(properties);
    enrichedProperties['base_command'] = _baseCommandInvocation.reportedName;
    final globalConfig = _globalConfiguration;
    final cloudUserId = globalConfig != null
        ? CliRunContextResolver.fetchCloudUserId(globalConfig.scloudDir.path)
        : null;
    if (cloudUserId != null) {
      enrichedProperties['cloud_user_id'] = cloudUserId;
    }
    super.sendAnalyticsEvent(event, enrichedProperties);
  }

  @override
  Future<bool> determineAnalyticsSettings() async {
    final analyticsEnabled = await _resolveAnalyticsConsent();
    _analyticsConsent = analyticsEnabled;
    return analyticsEnabled;
  }

  Future<bool> _resolveAnalyticsConsent() async {
    if (onAnalyticsEvent == null) {
      return false;
    }

    final analyticsOptionValue = globalConfiguration.analytics;
    if (analyticsOptionValue != null) {
      // explicitly set via option for this run
      return analyticsOptionValue;
    }

    if (!_enableAnalyticsForAllEnvs && !_isTenantUser()) {
      return false;
    }

    final analyticsEnabled = await _getAnalyticsSetting();
    return analyticsEnabled;
  }

  Future<bool> _getAnalyticsSetting() async {
    final settings = serviceProvider.scloudSettings;
    final analyticsEnabled = await settings.enableAnalytics;
    if (analyticsEnabled != null) {
      return analyticsEnabled;
    }

    final confirm = await logger.confirm(
      'Do you agree to sending command usage analytics to Serverpod?',
      defaultValue: true,
    );
    await settings.setEnableAnalytics(confirm);
    return confirm;
  }

  /// Returns true if the user likely is a production tenant user.
  bool _isTenantUser() {
    if (_adminUserMode) {
      return false;
    }
    if (!isActivatedFromPub()) {
      return false;
    }
    if (globalConfiguration.apiServer != HostConstants.serverpodCloudApi) {
      return false;
    }
    return true;
  }

  @override
  String? get usageFooter =>
      '\nSee the full documentation at: https://docs.serverpod.dev/cloud';

  /// Selects and verifies the project directory that is either specified by the global
  /// configuration, or files found near the current directory.
  ///
  /// Verifies that the directory is a valid Serverpod server directory
  /// using [isServerpodServerDirectory] and gives feedback to the user.
  ///
  /// Throws [ExitException] if no valid project directory could be determined.
  Directory verifiedProjectDirectory() {
    final selectedProjectDir = selectProjectDirectory();
    if (selectedProjectDir == null) {
      logger.error(
        'No valid Serverpod server directory located.',
        hint:
            "Move to the project's server directory or use the `--project-dir` option and try again.",
      );
      throw ErrorExitException('No project directory selected.');
    }

    final projectDirectory = Directory(selectedProjectDir);

    if (!isServerpodServerDirectory(projectDirectory)) {
      logProjectDirIsNotAServerpodServerDirectory(logger, selectedProjectDir);
      throw ErrorExitException(
        'The directory is not a Serverpod server directory.',
      );
    }

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
      return specifiedDir.path;
    }

    // if scloud.<ext> is set or found, use its directory
    final configFile = globalConfiguration.projectConfigFile;
    if (configFile != null) {
      return configFile.parent.path;
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
      fileContentCondition: (filePath) =>
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
    required CommandLogger logger,
    required CommandRunnerLogLevel parsedLogLevel,
    String? commandName,
  }) {
    var logLevel = LogLevel.info;

    if (parsedLogLevel == CommandRunnerLogLevel.verbose) {
      logLevel = LogLevel.debug;
    } else if (parsedLogLevel == CommandRunnerLogLevel.quiet) {
      logLevel = LogLevel.nothing;
    }

    logger.logLevel = logLevel;
  }

  static void _printUpdateCLIAlert({
    required Version latestVersion,
    required CommandLogger logger,
    required bool isRequiredUpdate,
  }) {
    var infoMessage =
        '''A new version $latestVersion of Serverpod Cloud CLI is available!

To update to the latest version, run "dart install serverpod_cloud_cli".''';

    if (isRequiredUpdate) {
      infoMessage = '$infoMessage You need to update the CLI to continue.';
    }

    logger.box(infoMessage);
  }
}

Directory _getDefaultStorageDir() {
  return ResourceManager.localCloudStorageDirectory;
}

/// The global configuration options for the Serverpod Cloud CLI.
enum GlobalOption<V> implements OptionDefinition<V> {
  quiet(BetterCommandRunnerFlags.quietOption),
  verbose(BetterCommandRunnerFlags.verboseOption),

  analytics(
    FlagOption(
      argName: BetterCommandRunnerFlags.analytics,
      argAbbrev: BetterCommandRunnerFlags.analyticsAbbr,
      envName: 'SERVERPOD_CLOUD_COMMAND_ANALYTICS',
      negatable: true,
      helpText: 'Toggles if analytics data is sent.',
    ),
  ),

  version(
    FlagOption(
      argName: 'version',
      helpText: VersionCommand.usageDescription,
      negatable: false,
      defaultsTo: false,
    ),
  ),
  authToken(
    StringOption(
      argName: 'token',
      envName: 'SERVERPOD_CLOUD_TOKEN',
      helpText: 'The authentication token to use for the current command.',
    ),
  ),
  scloudDir(
    DirOption(
      argName: 'config-dir',
      envName: 'SERVERPOD_CLOUD_DIR',
      helpText:
          'Override the directory path where Serverpod Cloud cache/authentication files are stored.',
      fromDefault: _getDefaultStorageDir,
      // This is only hidden since it currently prints the resolved home directory
      // which is then included in the auto-generated CLI docs, which doesn't work.
      // TODO: Remove this once this cli_tools issue is fixed: https://github.com/serverpod/cli_tools/issues/80
      hide: true,
    ),
  ),
  projectDir(
    DirOption(
      argName: 'project-dir',
      argAbbrev: 'd',
      envName: 'SERVERPOD_CLOUD_PROJECT_DIR',
      helpText: 'The path to the Serverpod Cloud project server directory.',
      // (no general default value since significant whether explicitly specified)
      mode: PathExistMode.mustExist,
    ),
  ),
  projectConfigFile(
    FileOption(
      argName: 'project-config-file',
      envName: 'SERVERPOD_CLOUD_PROJECT_CONFIG_FILE',
      fromCustom: _projectConfigFileFinder,
      helpText:
          'The path to the Serverpod Cloud project configuration file (defaults to <server-package>/scloud.yaml)',
    ),
  ),
  connectionTimeout(
    DurationOption(
      argName: 'timeout',
      envName: 'SERVERPOD_CLOUD_CONNECTION_TIMEOUT',
      defaultsTo: Duration(seconds: 60),
      helpText: 'The timeout for the connection to the Serverpod Cloud API.',
    ),
  ),
  skipConfirmation(
    FlagOption(
      argName: 'yes',
      helpText:
          'Automatically accept confirmation prompts.'
          ' For use in non-interactive environments.',
      negatable: false,
      defaultsTo: false,
    ),
  ),

  // Developer options and flags
  projectConfigContent(
    StringOption(
      argName: 'project-config-content',
      envName: 'SERVERPOD_CLOUD_PROJECT_CONFIG_CONTENT',
      helpText: 'Override the scloud project configuration with a YAML string.',
      hide: true,
    ),
  ),
  apiServer(
    StringOption(
      argName: 'api-url',
      envName: 'SERVERPOD_CLOUD_API_SERVER_URL',
      helpText: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    ),
  ),
  browserOpt(
    FlagOption(
      argName: 'browser',
      helpText: 'Allow CLI to open browser for logging in.',
      defaultsTo: true,
      negatable: true,
      hide: true,
    ),
  ),
  warnBillingOverdue(
    FlagOption(
      argName: 'warn-billing-overdue',
      helpText: 'Enable / disable warning if the account has overdue payments.',
      defaultsTo: true,
      negatable: true,
      hide: true,
    ),
  ),
  breakingVersionCheck(
    FlagOption(
      argName: 'breaking-version-check',
      helpText: 'Enable / disable error if the CLI version is not the latest.',
      defaultsTo: true,
      negatable: true,
      hide: true,
    ),
  ),
  exitOnUpdated(
    FlagOption(
      argName: 'exit-on-updated',
      envName: 'SERVERPOD_CLOUD_EXIT_ON_UPDATED',
      helpText:
          'Exit with code '
          '${ExitCodeConstants.scloudUpdatedRerunRequired} after updating the '
          'CLI instead of rerunning the command.',
      defaultsTo: false,
      negatable: false,
      hide: true,
    ),
  ),
  consoleServer(
    StringOption(
      argName: 'console-url',
      envName: 'SERVERPOD_CLOUD_CONSOLE_SERVER_URL',
      helpText: 'The URL to the Serverpod cloud console server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudConsole,
    ),
  ),
  signInPath(
    StringOption(
      argName: 'sign-in-path',
      helpText: 'The path to the sign-in endpoint on the server.',
      hide: true,
      defaultsTo: ConsoleRoutes.login,
    ),
  );

  const GlobalOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

File? _projectConfigFileFinder(Configuration cfg) {
  // if the dir option is set, we use it as starting directory
  final finder = scloudFileFinder<Configuration>(
    fileBaseName: ProjectConfigFileConstants.fileBaseName,
    supportedExtensions: ['yaml', 'yml', 'json'],
    startingDirectory: (cfg) {
      return cfg.optionalValue(GlobalOption.projectDir)?.path;
    },
  );
  final path = finder(cfg);
  return path != null ? File(path) : null;
}

/// The current global configuration values for the Serverpod Cloud CLI.
class GlobalConfiguration extends Configuration<GlobalOption> {
  GlobalConfiguration.from({required super.configuration}) : super.from();

  GlobalConfiguration.resolve({super.argResults, super.args, super.env})
    : super.resolve(options: GlobalOption.values);

  bool get quiet => value(GlobalOption.quiet);

  bool get browser => value(GlobalOption.browserOpt);

  bool get verbose => value(GlobalOption.verbose);

  bool get version => value(GlobalOption.version);

  bool? get analytics => optionalValue(GlobalOption.analytics);

  Directory get scloudDir => value(GlobalOption.scloudDir);

  Directory? get projectDir => optionalValue(GlobalOption.projectDir);

  File? get projectConfigFile => optionalValue(GlobalOption.projectConfigFile);

  String? get projectConfigContent =>
      optionalValue(GlobalOption.projectConfigContent);

  Duration get connectionTimeout => value(GlobalOption.connectionTimeout);

  String get apiServer => value(GlobalOption.apiServer);

  String get consoleServer => value(GlobalOption.consoleServer);

  String get signInPath => value(GlobalOption.signInPath);

  bool get skipConfirmation => value(GlobalOption.skipConfirmation);

  bool get warnBillingOverdue => value(GlobalOption.warnBillingOverdue);

  bool get breakingVersionCheck => value(GlobalOption.breakingVersionCheck);

  bool get exitOnUpdated => value(GlobalOption.exitOnUpdated);

  String? get authToken => optionalValue(GlobalOption.authToken);
}

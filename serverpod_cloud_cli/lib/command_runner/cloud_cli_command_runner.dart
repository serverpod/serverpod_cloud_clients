import 'dart:io';

import 'package:cli_tools/analytics.dart'
    show buildCommandLinePropertiesForAnalytics;
import 'package:cli_tools/better_command_runner.dart';
import 'package:config/command.dart'
    show
        CommandContext,
        Middlewares,
        UsageOutputHandler,
        OutputSinks,
        CommandMiddleware;
import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show ConsoleRoutes;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_login.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/builds/builds_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain/custom_domain_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch/launch_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/me/me_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/variable/variable_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version/version_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_auto_update.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_run_context_resolver.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_updater.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/activation_checker.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show OutputFormat;
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

import 'commands/admin/admin_command.dart';
import 'commands/settings/settings_command.dart';

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

/// Reports an analytics event with its [properties].
///
/// [userAuthId] is the auth id of the logged in cloud user, or null when the
/// user is not logged in or the id is not stored.
typedef OnCloudAnalyticsEvent =
    void Function(
      String event,
      Map<String, dynamic> properties, {
      String? userAuthId,
    });

/// Reports an error for diagnostics.
typedef OnErrorReport =
    Future<void> Function(Object error, StackTrace stackTrace);

/// Represents the Serverpod Cloud CLI main command, its global options, and subcommands.
class CloudCliCommandRunner extends BetterCommandRunner<GlobalOption, void> {
  final Version version;
  final CommandLogger logger;
  final CloudCliServiceProvider _serviceProvider;

  // /// Called with the resolved run context each time [runCommand] is entered,
  // /// which is after the global configuration and the analytics consent are
  // /// resolved.
  // ///
  // /// An error thrown by the callback is logged and ignored, so telemetry
  // /// cannot break the command being run.
  // final OnRunContextResolved? _onRunContextResolved;
  // /// Called with the resolved run context each time [runCommand] is entered,
  // /// which is after the global configuration and the analytics consent are
  // /// resolved.
  // ///
  // /// An error thrown by the callback is logged and ignored, so telemetry
  // /// cannot break the command being run.
  // final OnRunContextResolved? _onRunContextResolved;

  /// If true, analytics will be not be suppressed for non-production usage.
  final bool _enableAnalyticsForAllEnvs;

  /// If true, the admin subcommands are enabled.
  final bool _adminUserMode;

  /// The invocation path the CLI was run through, as reported to telemetry.
  final BaseCommandInvocation _baseCommandInvocation;

  // final VersionCommand _versionCommand;

  GlobalConfiguration? _globalConfiguration;

  /// Whether this run may send analytics, as resolved before the command.
  bool _analyticsConsent = false;

  /// The curremt global configuration for the Serverpod Cloud CLI.
  @Deprecated('Use CommandContext.globalConfiguration instead')
  GlobalConfiguration get globalConfiguration {
    final globalConfig = _globalConfiguration;
    if (globalConfig == null) {
      throw StateError('Global configuration not initialized');
    }
    return globalConfig;
  }

  // /// Sets the curremt global configuration for the Serverpod Cloud CLI.
  // /// (Since this object is re-entrant, the global config is regenerated
  // /// each call to [run].)
  // @override
  // set globalConfiguration(Configuration<GlobalOption> configuration) {
  //   _globalConfiguration = GlobalConfiguration.from(
  //     configuration: configuration,
  //   );
  //   logger.configuration = _globalConfiguration;
  // }
  // /// Sets the curremt global configuration for the Serverpod Cloud CLI.
  // /// (Since this object is re-entrant, the global config is regenerated
  // /// each call to [run].)
  // @override
  // set globalConfiguration(Configuration<GlobalOption> configuration) {
  //   _globalConfiguration = GlobalConfiguration.from(
  //     configuration: configuration,
  //   );
  //   logger.configuration = _globalConfiguration;
  // }

  /// Gets the initialized service provider for the Serverpod Cloud CLI.
  /// Must not be called before the [run] method has been invoked.
  @Deprecated('Use CommandContext.serviceProvider instead')
  CloudCliServiceProvider get serviceProvider {
    return _serviceProvider;
  }

  CloudCliCommandRunner._({
    required this.logger,
    required this.version,
    required String baseCommand,
    required CloudCliServiceProvider serviceProvider,
    required bool enableAnalyticsForAllEnvs,
    required bool adminUserMode,
    OnRunContextResolved? onRunContextResolved,
    super.onAnalyticsEvent,
    super.setLogLevel,
    super.prependMiddlewares,
  }) : _serviceProvider = serviceProvider,
       _enableAnalyticsForAllEnvs = enableAnalyticsForAllEnvs,
       _adminUserMode = adminUserMode,
       _baseCommandInvocation = BaseCommandInvocation.from(baseCommand),
       super(
         baseCommand,
         'Manage your Serverpod Cloud projects',
         rootFooter:
             '\nSee the full documentation at: https://docs.serverpod.dev/cloud',
         buildAnalyticsProperties: _buildEnrichedAnalyticsProperties(
           buildCommandLinePropertiesForAnalytics,
           BaseCommandInvocation.from(baseCommand).reportedName,
         ),
         globalOptions: GlobalOption.values,
         wrapTextColumn: logger.wrapTextColumn,
         usageOutput: UsageOutputHandler(
           sinks: OutputSinks(
             out: _LoggerStringSink(logger.info),
             err: _LoggerStringSink(logger.error),
           ),
         ),
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
    OnCloudAnalyticsEvent? onAnalyticsEvent,
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

    final actualServiceProvider = serviceProvider ?? CloudCliServiceProvider();

    final resolvedVersion = version ?? cliVersion;
    final autoUpdate = CliAutoUpdate(
      logger: logger,
      currentVersion: resolvedVersion,
      updater: cliUpdater ?? const DartCliUpdater(),
      attemptedVersion: attemptedUpdateVersion ?? attemptedCliUpdateVersion(),
      onErrorReport: onErrorReport,
    );

    late final CloudCliCommandRunner runner;

    final middlewares = <CommandMiddleware<GlobalOption, void>>[
      Middlewares.onBeforeRun((context) {
        final gc = GlobalConfiguration.from(configuration: context.config);
        context.provider.store(gc);
        logger.configuration = gc;
        runner._globalConfiguration = gc;
      }),
      (final next) {
        return (final context) async {
          if (context.isCompletion) return next(context);
          final updatedAndReran = await autoUpdate.attempt(context);
          if (updatedAndReran) return;
          return next(context);
        };
      },
      Middlewares.withHooks(
        onRun: (context) {
          context.provider.store(actualServiceProvider);
          if (!actualServiceProvider.initialized) {
            final gc = context.provider.fetch<GlobalConfiguration>();
            actualServiceProvider.initialize(
              globalConfiguration: gc,
              logger: logger,
            );
          }
          return context;
        },
        onReturn: (context, ret) {
          context.provider.fetch<CloudCliServiceProvider>().shutdown();
          return ret;
        },
        onError: (error, stackTrace, context) {
          context.provider.fetch<CloudCliServiceProvider>().shutdown();
          Error.throwWithStackTrace(error, stackTrace);
        },
      ),
    ];

    runner = CloudCliCommandRunner._(
      logger: logger,
      version: resolvedVersion,
      baseCommand: resolvedBaseCommand,
      serviceProvider: actualServiceProvider,
      enableAnalyticsForAllEnvs: enableAnalyticsForAllEnvs,
      adminUserMode: adminUserMode,
      onRunContextResolved: onRunContextResolved,
      onAnalyticsEvent: onAnalyticsEvent == null
          ? null
          : (event, properties) => onAnalyticsEvent(
              event,
              properties,
              userAuthId: runner._storedUserAuthId(),
            ),
      setLogLevel:
          ({
            String? commandName,
            required CommandRunnerLogLevel parsedLogLevel,
          }) => _configureLogLevel(
            logger: logger,
            parsedLogLevel: parsedLogLevel,
            commandName: commandName,
          ),
      prependMiddlewares: middlewares,
    );

    runner.addMiddleware(
      Middlewares.onBeforeRun((context) {
        final gc = GlobalConfiguration.from(configuration: context.config);
        runner._globalConfiguration = gc;
      }),
    );

    if (onRunContextResolved != null) {
      runner.addMiddleware(
        Middlewares.onBeforeRun((context) {
          try {
            onRunContextResolved(runner._makeRunContext(context));
          } catch (e, stackTrace) {
            logger.debug('Failed to resolve the run context: $e\n$stackTrace');
          }
        }),
      );
    }

    // Add commands (which may in turn have their own options and subcommands)
    runner.addCommands([
      VersionCommand(logger: logger),
      CloudAuthCommand(logger: logger),
      CloudMeCommand(logger: logger),
      CloudProjectCommand(logger: logger),
      CloudDeployCommand(logger: logger),
      CloudAppCommand(logger: logger),
      CloudVariableCommand(logger: logger),
      CloudCustomDomainCommand(logger: logger),
      CloudLogCommand(logger: logger),
      CloudStatusCommand(logger: logger),
      CloudTopCommand(logger: logger),
      CloudBuildCommand(logger: logger),
      CloudDeploymentsCommand(logger: logger, asOldAlias: true),
      CloudPasswordCommand(logger: logger),
      CloudDbCommand(logger: logger),
      CloudStorageCommand(logger: logger),
      CloudLaunchCommand(logger: logger),
      CloudSettingsCommand(logger: logger),
      if (adminUserMode) CloudAdminCommand(logger: logger, hidden: false),
    ]);

    return runner;
  }

  CliRunContext _makeRunContext(
    final CommandContext<GlobalOption, void> context,
  ) {
    final globalConfig = context.provider.fetch<GlobalConfiguration>();
    return (
      analyticsConsent: context.provider.fetch<AnalyticsEnabled>().enabled,
      command: CliRunContextResolver.commandPath(context),
      flags: CliRunContextResolver.commandFlags(context),
      apiServerUrl: globalConfig.apiServer,
      cloudUserId: CliRunContextResolver.fetchCloudUserId(
        globalConfig.scloudDir.path,
      ),
      baseCommand: _baseCommandInvocation,
    );
  }

  static const _signedInAnalyticsEvent = 'serverpod_cli_signed_in';

  /// Sends the `serverpod_cli_signed_in` analytics event, provided the
  /// analytics are enabled and the auth id of the signed in user is stored.
  void sendSignedInAnalyticsEvent() {
    if (!_analyticsConsent || _storedUserAuthId() == null) {
      return;
    }
    sendAnalyticsEvent(_signedInAnalyticsEvent);
  }

  /// Stores the user auth id of the logged in user if it is missing from
  /// the stored user data.
  ///
  /// Never throws, so the backfill cannot break the command being run.
  Future<void> _backfillUserAuthId(
    final CommandContext<GlobalOption, void> context,
  ) async {
    try {
      final client = context.provider
          .fetch<CloudCliServiceProvider>()
          .cloudApiClient;
      if (await client.authKeyProvider?.isAuthenticated != true) {
        return;
      }
      final globalConfig = context.provider.fetch<GlobalConfiguration>();
      await AuthLoginCommands.backfillUserAuthId(
        cloudApiClient: client,
        localStoragePath: globalConfig.scloudDir.path,
        logger: logger,
      );
    } catch (e, stackTrace) {
      logger.debug('Failed to backfill the user auth id: $e\n$stackTrace');
    }
  }

  /// Returns the auth id of the logged in cloud user, or null if the user is
  /// not logged in, the id is not stored, or the configuration is not
  /// resolved yet.
  String? _storedUserAuthId() {
    final globalConfig = _globalConfiguration;
    if (globalConfig == null) {
      return null;
    }
    return CliRunContextResolver.fetchUserAuthId(globalConfig.scloudDir.path);
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

  static BuildCommandLinePropertiesForAnalytics
  _buildEnrichedAnalyticsProperties(
    final BuildCommandLinePropertiesForAnalytics buildAnalyticsProperties,
    final String baseCommand,
  ) {
    return <O extends OptionDefinition, T>(final CommandContext<O, T> context) {
      final properties = buildAnalyticsProperties(context);

      final enrichedProperties = Map<String, dynamic>.from(properties);
      enrichedProperties['base_command'] = baseCommand;
      final globalConfig = context.provider.fetch<GlobalConfiguration>();
      final cloudUserId = CliRunContextResolver.fetchCloudUserId(
        globalConfig.scloudDir.path,
      );
      if (cloudUserId != null) {
        enrichedProperties['cloud_user_id'] = cloudUserId;
      }
      return enrichedProperties;
    };
  }

  @override
  Future<bool> determineAnalyticsSettings(
    final CommandContext<GlobalOption, void> context,
  ) async {
    final analyticsEnabled = await _resolveAnalyticsConsent(context);
    _analyticsConsent = analyticsEnabled;
    if (analyticsEnabled) {
      await _backfillUserAuthId(context);
    }
    return analyticsEnabled;
  }

  Future<bool> _resolveAnalyticsConsent(
    final CommandContext<GlobalOption, void> context,
  ) async {
    if (onAnalyticsEvent == null) {
      return false;
    }

    final analyticsOptionValue = context.config.optionalValue(
      GlobalOption.analytics,
    );
    if (analyticsOptionValue != null) {
      // explicitly set via option for this run
      return analyticsOptionValue;
    }

    if (!_enableAnalyticsForAllEnvs && !_isTenantUser(context)) {
      return false;
    }

    final analyticsEnabled = await _getAnalyticsSetting(context);
    return analyticsEnabled;
  }

  Future<bool> _getAnalyticsSetting(
    final CommandContext<GlobalOption, void> context,
  ) async {
    final serviceProvider = context.provider.fetch<CloudCliServiceProvider>();
    final settings = serviceProvider.scloudSettings;
    final analyticsEnabled = await settings.enableAnalytics;
    if (analyticsEnabled != null) {
      return analyticsEnabled;
    }

    final globalConfiguration = context.provider.fetch<GlobalConfiguration>();
    if (globalConfiguration.nonInteractive) {
      return false;
    }

    final confirm = await logger.confirm(
      'Do you agree to sending command usage analytics to Serverpod?',
      defaultValue: true,
    );
    await settings.setEnableAnalytics(confirm);
    return confirm;
  }

  /// Returns true if the user likely is a production tenant user.
  bool _isTenantUser(final CommandContext<GlobalOption, void> context) {
    if (_adminUserMode) {
      return false;
    }
    if (!isActivatedFromPub()) {
      return false;
    }
    final globalConfiguration = context.provider.fetch<GlobalConfiguration>();
    if (globalConfiguration.apiServer != HostConstants.serverpodCloudApi) {
      return false;
    }
    return true;
  }

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
}

Directory _getDefaultStorageDir() {
  return ResourceManager.localCloudStorageDirectory;
}

class _LoggerStringSink implements StringSink {
  final void Function(String message) log;

  const _LoggerStringSink(this.log);

  @override
  void write(final Object? object) {
    log('$object');
  }

  @override
  void writeAll(final Iterable objects, [final String separator = '']) {
    log(objects.join(separator));
  }

  @override
  void writeln([final Object? object = '']) {
    log('$object');
  }

  @override
  void writeCharCode(final int charCode) {
    throw UnimplementedError('writeCharCode unsupported by $runtimeType');
  }
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
      helpText:
          'The timeout for connections to the Serverpod Cloud API, '
          'and for an upload that makes no progress.',
    ),
  ),
  skipConfirmation(
    FlagOption(
      argName: 'yes',
      helpText: 'Automatically accept confirmation prompts.',
      negatable: false,
      defaultsTo: false,
    ),
  ),
  nonInteractive(
    FlagOption(
      argName: 'non-interactive',
      helpText:
          'Never wait for user input, fail with an error instead.'
          ' For use in non-interactive environments such as CI.'
          ' Combine with --yes to accept confirmation prompts.',
      negatable: false,
      defaultsTo: false,
    ),
  ),
  format(
    EnumOption<OutputFormat>(
      argName: 'format',
      envName: 'SERVERPOD_CLOUD_FORMAT',
      enumParser: EnumParser(OutputFormat.values),
      defaultsTo: OutputFormat.text,
      helpText: 'Selects the command output format.',
    ),
  ),
  autoCliUpgrade(
    FlagOption(
      argName: 'auto-cli-upgrade',
      helpText:
          'Automatically update the CLI when a newer version is available.',
      defaultsTo: true,
      negatable: true,
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
      helpText: 'The URL to the Serverpod Cloud api server.',
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
      helpText: 'The URL to the Serverpod Cloud console server.',
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
typedef GlobalConfiguration = Configuration<GlobalOption>;

extension GlobalConfigurationOptions on Configuration<GlobalOption> {
  bool get quiet => value(GlobalOption.quiet);

  bool get browser => value(GlobalOption.browserOpt);

  bool get verbose => value(GlobalOption.verbose);

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

  bool get nonInteractive => value(GlobalOption.nonInteractive);

  OutputFormat get format => value(GlobalOption.format);

  bool get warnBillingOverdue => value(GlobalOption.warnBillingOverdue);

  bool get autoCliUpgrade => value(GlobalOption.autoCliUpgrade);

  bool get breakingVersionCheck => value(GlobalOption.breakingVersionCheck);

  bool get exitOnUpdated => value(GlobalOption.exitOnUpdated);

  String? get authToken => optionalValue(GlobalOption.authToken);
}

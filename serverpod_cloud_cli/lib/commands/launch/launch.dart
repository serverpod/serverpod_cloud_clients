import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/app.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state_holder.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart'
    show SelectList, SelectListStyle;
import 'package:serverpod_cloud_cli/util/listener_server.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/project_id_validator.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart'
    show TenantProjectPubspec;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_model.dart';
import 'package:serverpod_logging_cli/serverpod_logging_cli.dart';
import 'package:serverpod_tui/serverpod_tui.dart';
import 'package:yaml_codec/yaml_codec.dart' show yamlDecode;

abstract class Launch {
  static const _projectFactStyle = cli.AnsiStyle.cyan;

  static Future<void> launch(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final Directory projectDirectory,
    required final String? projectId,
    required final bool includePreDeployScripts,
    required final bool performDeploy,
    required final bool tui,
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
    final String? dartVersionOverride,
  }) async {
    logger.init('Launching a Serverpod Cloud project.\n');

    final pubspec = _validateProjectDir(logger, projectDirectory);

    final dirPath = logger.wrapStyle(projectDirectory.path, _projectFactStyle);
    logger.info('Project directory: $dirPath\n');

    final usesDatabase = _usesDatabase(projectDirectory);

    final projectSetup = ProjectLaunch(
      projectDir: projectDirectory,
      projectPubspec: pubspec,
      usesDb: usesDatabase,
      includePreDeployScripts: includePreDeployScripts,
      projectId: projectId,
      dartVersionOverride: dartVersionOverride,
      performDeploy: performDeploy,
    );

    if (tui) {
      await launchWithTui(
        cloudApiClient,
        fileUploaderFactory,
        logger: logger,
        projectSetup: projectSetup,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        deployConcurrency: deployConcurrency,
        deployDryRun: deployDryRun,
        deployShowFiles: deployShowFiles,
        deployOutputPath: deployOutputPath,
        deploySkipTailingStatus: deploySkipTailingStatus,
      );
    } else {
      await launchWithoutTui(
        cloudApiClient,
        fileUploaderFactory,
        logger: logger,
        projectSetup: projectSetup,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        deployConcurrency: deployConcurrency,
        deployDryRun: deployDryRun,
        deployShowFiles: deployShowFiles,
        deployOutputPath: deployOutputPath,
        deploySkipTailingStatus: deploySkipTailingStatus,
      );
    }
  }

  static Future<void> launchWithoutTui(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final ProjectLaunch projectSetup,
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
  }) async {
    await selectProjectId(cloudApiClient, logger, projectSetup);

    await suggestCodeGenerationPreDeployHook(logger, projectSetup);

    await suggestFlutterBuildPreDeployHook(logger, projectSetup);

    await performLaunch(
      cloudApiClient,
      fileUploaderFactory,
      logger,
      projectSetup,
      consoleServer: consoleServer,
      openBrowser: openBrowser,
      deployConcurrency: deployConcurrency,
      deployDryRun: deployDryRun,
      deployShowFiles: deployShowFiles,
      deployOutputPath: deployOutputPath,
      deploySkipTailingStatus: deploySkipTailingStatus,
    );
  }

  static Future<void> launchWithTui(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final ProjectLaunch projectSetup,
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
  }) async {
    final defaultProjectId = _getDefaultProjectId(projectSetup);

    final existingProjects = await _fetchExistingUndeployedProjects(
      cloudApiClient,
    );
    final existingProjectIds = existingProjects
        .map((final p) => p.cloudProjectId)
        .toList();

    final state = LaunchConfigState(
      projectSetup: projectSetup,
      defaultProjectId: defaultProjectId,
      existingProjectIds: existingProjectIds,
    );
    final holder = LaunchAppStateHolder(state);

    final tuiWriter = TuiLogWriter()..attach(holder);
    final tuiLogger = ServerpodCliLogger(tuiWriter);

    // Hook up the TUI logger for structured logs in the TUI.
    logger.initializeWith(tuiLogger);

    await runTuiApp(
      ScloudLaunchApp(
        holder: holder,
        onLaunch: () async {
          // Update UI to show logs from the launch
          state.markLaunchingProject();
          holder.markDirty();

          final stdoutController = StreamController<List<int>>();
          stdoutController.stream
              .transform(const Utf8Decoder(allowMalformed: true))
              .transform(const LineSplitter())
              .listen(logger.debug);
          final toDebugLog = IOSink(stdoutController);
          final stderrController = StreamController<List<int>>();
          stderrController.stream
              .transform(const Utf8Decoder(allowMalformed: true))
              .transform(const LineSplitter())
              .listen(logger.error);
          final toErrorLog = IOSink(stderrController);

          await performLaunch(
            cloudApiClient,
            fileUploaderFactory,
            logger,
            state.projectSetup,
            consoleServer: consoleServer,
            openBrowser: openBrowser,
            stdout: toDebugLog,
            stderr: toErrorLog,
            deployConcurrency: deployConcurrency,
            deployDryRun: deployDryRun,
            deployShowFiles: deployShowFiles,
            deployOutputPath: deployOutputPath,
            deploySkipTailingStatus: deploySkipTailingStatus,
          );
        },
        onQuit: () {
          /// Reset to the default logger for post-tui logs.
          logger.reset();
          shutdownTuiApp();
        },
      ),
    );
  }

  /// Validates that the project directory is a valid Serverpod server directory
  /// and that it has supported dependencies.
  ///
  /// Returns the [TenantProjectPubspec] if the project is valid,
  /// otherwise throws a [FailureException].
  static TenantProjectPubspec _validateProjectDir(
    final CommandLogger logger,
    final Directory projectDir,
  ) {
    final pubspecValidator = TenantProjectPubspec.fromProjectDir(projectDir);

    if (!pubspecValidator.isServerpodServer()) {
      throw FailureException(
        error: '`${projectDir.path}` is not a Serverpod server directory.',
        hint: "Provide the project's server directory and try again.",
      );
    }

    final issues = pubspecValidator.projectDependencyIssues();
    if (issues.isEmpty) {
      return pubspecValidator;
    }

    throw FailureException(
      error:
          '`${projectDir.path}` is a Serverpod server directory, but it is not valid:',
      errors: issues,
      hint: 'Resolve the issues and try again.',
    );
  }

  static bool _usesDatabase(final Directory projectDir) {
    const configFiles = [
      'development.yaml',
      'production.yaml',
      'staging.yaml',
      'test.yaml',
    ];
    for (final filename in configFiles) {
      final configFile = File(p.join(projectDir.path, 'config', filename));
      if (configFile.existsSync()) {
        final config = yamlDecode(configFile.readAsStringSync());
        if (config case final Map<dynamic, dynamic> cfgMap) {
          if (cfgMap.containsKey('database')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static Future<void> selectProjectId(
    final Client cloudApiClient,
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    const invalidProjectIdMessage =
        'Invalid project ID. Must be 6-32 characters long '
        'and contain only lowercase letters, numbers, and hyphens.';

    final existingProjects = await cloudApiClient.projects.listProjectsInfo(
      includeLatestDeployAttemptTime: true,
    );

    final specifiedProjectId = projectSetup.projectId;
    if (specifiedProjectId != null) {
      if (existingProjects.any(
        (final p) => p.project.cloudProjectId == specifiedProjectId,
      )) {
        projectSetup.preexistingProject = true;
        return;
      }

      if (isValidProjectIdFormat(specifiedProjectId)) {
        final confirm = await logger.confirm(
          'Open the browser and create a new Serverpod Cloud project?',
          defaultValue: true,
        );
        if (!confirm) {
          logger.info('Setup cancelled.');
          throw UserAbortException();
        }
        return;
      }

      throw FailureException(error: invalidProjectIdMessage);
    }

    final selectedId = await _selectExistingProject(
      cloudApiClient,
      existingProjects,
      logger,
    );
    if (selectedId != null) {
      projectSetup.projectId = selectedId;
      projectSetup.preexistingProject = true;
      return;
    }

    projectSetup.projectId = _getDefaultProjectId(projectSetup);
    return;
  }

  static Future<String?> _selectExistingProject(
    final Client cloudApiClient,
    final List<ProjectInfo> existingProjects,
    final CommandLogger logger,
  ) async {
    if (existingProjects.isEmpty) {
      final confirm = await logger.confirm(
        'Open the browser and create a new Serverpod Cloud project?',
        defaultValue: true,
      );
      if (!confirm) {
        logger.info('Setup cancelled.');
        throw UserAbortException();
      }
      return null; // create a new project
    }

    existingProjects.sort((final a, final b) {
      // if both or neither are null, keep the order
      if ((a.latestDeployAttemptTime?.timestamp == null) ==
          (b.latestDeployAttemptTime?.timestamp == null)) {
        return 0;
      }
      // if one is null and the other is not, put the null one first
      return (a.latestDeployAttemptTime?.timestamp == null) ? -1 : 1;
    });

    final projectLabels = existingProjects.map((final p) {
      final lastDeployedTime = p.latestDeployAttemptTime?.timestamp;
      final lastDeployed = lastDeployedTime == null
          ? 'available for first deployment'
          : 'available for redeploy (last deployed ${lastDeployedTime.toString().substring(0, 16)})';
      return '${p.project.cloudProjectId.padRight(30)}$lastDeployed';
    });
    final optionLabels = [
      ...projectLabels,
      'Open the browser and create a new project',
    ];
    final options = optionLabels
        .mapIndexed((final i, final r) => (i, r))
        .toList();

    final selected = await SelectList.choose(
      prompt:
          'Select a Severpod Cloud project to deploy to, or create a new project:\n',
      options: options,
      label: (final o) => o.$2,
      terminal: logger.inlineTerminal,
      style: SelectListStyle(highlightStyle: _projectFactStyle.ansiCode),
    );
    if (selected == null) {
      logger.info('Setup cancelled.');
      return throw UserAbortException();
    }
    if (selected.$1 == existingProjects.length) {
      return null; // create a new project
    }
    return existingProjects[selected.$1].project.cloudProjectId;
  }

  static Future<List<Project>> _fetchExistingUndeployedProjects(
    final Client cloudApiClient,
  ) async {
    try {
      final projects = await cloudApiClient.projects.listProjectsInfo(
        includeLatestDeployAttemptTime: true,
      );
      return projects
          .where((final p) => p.project.archivedAt == null)
          .where((final p) => p.latestDeployAttemptTime?.timestamp == null)
          .map((final p) => p.project)
          .toList();
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Request to list projects failed');
    }
  }

  static String? _getDefaultProjectId(final ProjectLaunch projectSetup) {
    final projectPubspec = projectSetup.projectPubspec;
    if (projectPubspec.isServerpodServer()) {
      var name = projectPubspec.pubspec.name.toLowerCase().replaceAll('_', '-');

      const serverSuffix = '-server';
      if (name.length > serverSuffix.length && name.endsWith(serverSuffix)) {
        name = name.substring(0, name.length - serverSuffix.length);
      }

      if (isValidProjectIdFormat(name)) {
        return name;
      }
    }
    return null;
  }

  static Future<void> suggestFlutterBuildPreDeployHook(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    if (!projectSetup.includePreDeployScripts) return;

    final projectPubspec = projectSetup.projectPubspec;
    final configFilePath = projectSetup.configFilePath;

    if (!projectPubspec.hasFlutterBuildScript()) return;

    ScloudConfig? existingConfig;
    try {
      existingConfig = ScloudConfigIO.readFromFile(configFilePath);
    } catch (_) {
      logger.debug('Failed to read config file at $configFilePath');
      return;
    }

    final flutterBuildHook = 'serverpod run flutter_build';

    final existingPreDeploy = existingConfig?.scripts.preDeploy ?? [];
    if (existingPreDeploy.contains(flutterBuildHook)) return;

    logger.debug(
      "Detected 'flutter_build' script. Adding it as a pre-deploy hook.",
    );
    projectSetup.suggestedPreDeployScripts.add(flutterBuildHook);
  }

  static Future<void> suggestCodeGenerationPreDeployHook(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    if (!projectSetup.includePreDeployScripts) return;

    final configFilePath = projectSetup.configFilePath;
    ScloudConfig? existingConfig;
    try {
      existingConfig = ScloudConfigIO.readFromFile(configFilePath);
    } catch (_) {
      logger.debug('Failed to read config file at $configFilePath');
    }

    final codeGenerationHook = 'serverpod generate';

    final existingPreDeploy = existingConfig?.scripts.preDeploy ?? [];
    if (existingPreDeploy.contains(codeGenerationHook)) return;

    logger.debug(
      "Adding code generation ('serverpod generate') as a pre-deploy hook.",
    );
    projectSetup.suggestedPreDeployScripts.add(codeGenerationHook);
  }

  static Future<void> performLaunch(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory,
    final CommandLogger logger,
    final ProjectLaunch projectSetup, {
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
    final IOSink? stdout,
    final IOSink? stderr,
  }) async {
    final projectId = projectSetup.projectId;
    final projectDir = projectSetup.projectDir;
    final usesDb = projectSetup.usesDb;
    final configFilePath = projectSetup.configFilePath;
    final performDeploy = projectSetup.performDeploy;

    String actualProjectId;
    if (projectSetup.preexistingProject != true) {
      actualProjectId = await createProject(
        logger,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        projectName: projectId ?? '',
        usesDb: usesDb,
      );
    } else {
      if (projectId == null) {
        throw StateError('For preexisting projects, projectId must be set.');
      }
      actualProjectId = projectId;
    }

    final safeDartSdk = await ProjectCommands.linkProject(
      cloudApiClient,
      logger: logger,
      projectId: actualProjectId,
      projectDirectory: projectDir.path,
      configFilePath: configFilePath,
      dartVersionOverride: projectSetup.dartVersionOverride,
      preDeployScripts: projectSetup.suggestedPreDeployScripts,
      suppressCommandMessages: true,
    );

    final projectIdStr = logger.wrapStyle(actualProjectId, _projectFactStyle);
    logger.info(
      'Your Serverpod Cloud project ID is: $projectIdStr',
      newParagraph: true,
    );

    final webUrl = logger.wrapStyle(
      'https://$actualProjectId.${HostConstants.tenantDomain}/',
      _projectFactStyle,
    );
    final apiUrl = logger.wrapStyle(
      'https://$actualProjectId.api.${HostConstants.tenantDomain}/',
      _projectFactStyle,
    );
    final insightsUrl = logger.wrapStyle(
      'https://$actualProjectId.insights.${HostConstants.tenantDomain}/',
      _projectFactStyle,
    );
    logger.info(
      'When the server has started, you can access it at:\n'
      '   Web:      $webUrl\n'
      '   API:      $apiUrl\n'
      '   Insights: $insightsUrl',
      newParagraph: true,
    );

    if (!performDeploy) {
      logger.terminalCommand(
        'scloud launch',
        message:
            'Deployment skipped. Run this command again to deploy to the cloud:',
        newParagraph: true,
      );
      return;
    }

    await Deploy.deploy(
      cloudApiClient,
      fileUploaderFactory,
      logger: logger,
      projectId: actualProjectId,
      projectDir: projectDir.path,
      projectConfigFilePath: configFilePath,
      concurrency: deployConcurrency,
      dryRun: deployDryRun,
      showFiles: deployShowFiles,
      outputPath: deployOutputPath,
      skipTailingStatus: deploySkipTailingStatus,
      suppressCommandMessages: true,
      dartVersionOverride: safeDartSdk,
      stdout: stdout,
      stderr: stderr,
    );

    logger.terminalCommand(
      'scloud help deployment',
      message: 'To see how to view deployment statuses, run this command:',
      newParagraph: true,
    );
  }

  /// Hands off project creation to the Serverpod Cloud console.
  ///
  /// Opens the console's create-project page, forwarding the analyzed project
  /// information ([projectName] and whether the project [usesDb]), and waits
  /// for the console to redirect back to a local callback server with the id of
  /// the created project. Returns the created project id.
  static Future<String> createProject(
    final CommandLogger logger, {
    required final String consoleServer,
    required final bool openBrowser,
    required final String projectName,
    required final bool usesDb,
    final Duration timeLimit = const Duration(minutes: 5),
  }) async {
    final callbackUrlFuture = Completer<Uri>();
    final projectIdFuture = ListenerServer.listenForCallback(
      queryParameter: 'projectId',
      logger: logger,
      onConnected: callbackUrlFuture.complete,
      timeLimit: timeLimit,
      successMessage:
          'The Serverpod Cloud project has been created, you may now close this window and return to the CLI.',
      failureMessage:
          'The Serverpod Cloud project creation failed, please try again or contact support.',
    );

    final callbackUrl = await callbackUrlFuture.future;
    final createProjectUrl = Uri.parse(consoleServer).replace(
      path: ConsoleRoutes.createProject,
      queryParameters: {
        'project-name': projectName,
        'database-enabled': usesDb.toString(),
        'return-url': callbackUrl.toString(),
      },
    );

    logger.info(
      'Create your Serverpod Cloud project in the opened browser or through this link:\n'
      '$createProjectUrl',
    );

    if (openBrowser) {
      try {
        await BrowserLauncher.openUrl(createProjectUrl);
      } on Exception catch (e) {
        logger.error('Failed to open browser', exception: e);
      }
    }

    String? createdProjectId;
    await logger.progress(
      'Waiting for project creation',
      successMessage: 'Serverpod Cloud project created.',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        createdProjectId = await projectIdFuture;
        return createdProjectId != null;
      },
    );

    final projectId = createdProjectId;
    if (projectId == null) {
      throw FailureException(
        error: 'Failed to create project.',
        hint: 'Please try again.',
      );
    }

    return projectId;
  }
}

class ProjectLaunch {
  final Directory projectDir;
  final TenantProjectPubspec projectPubspec;
  final bool usesDb;
  late final String configFilePath;
  String? projectId;
  String? dartVersionOverride;
  bool? preexistingProject;
  final bool performDeploy;
  final bool includePreDeployScripts;
  final List<String> suggestedPreDeployScripts;

  ProjectLaunch({
    required this.projectDir,
    required this.projectPubspec,
    required this.usesDb,
    required this.includePreDeployScripts,
    this.projectId,
    this.dartVersionOverride,
    this.preexistingProject,
    this.performDeploy = true,
    final List<String>? suggestedPreDeployScripts,
  }) : suggestedPreDeployScripts = suggestedPreDeployScripts ?? [] {
    configFilePath = _constructConfigFilePath(projectDir.path);
  }

  String _constructConfigFilePath(final String projectDir) {
    return p.join(projectDir, ProjectConfigFileConstants.defaultFileName);
  }

  @override
  String toString() {
    final text = TablePrinter.columns(
      rows: [
        ['Project directory', projectDir.path],
        if (preexistingProject != true) ...[
          ['Create new project', 'yes'],
          ['Uses DB', usesDb ? 'yes' : 'no'],
        ] else
          ['Existing project', projectId],
        if (suggestedPreDeployScripts.isNotEmpty) ...[
          [
            'Pre-deploy hooks',
            suggestedPreDeployScripts
                .map((final hook) => "- '$hook'")
                .join('\n                    '),
          ],
        ],
      ],
      columnSeparator: '  ',
    ).toString();
    return text.substring(0, text.length - 1); // trims last newline
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart' as cli;
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
    logger.init('Launching new Serverpod Cloud project.\n');

    final pubspec = _validateProjectDir(logger, projectDirectory);

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

    await confirmSetupAndContinue(logger, projectSetup);

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
    const defaultPrefix = 'default: ';
    const invalidProjectIdMessage =
        'Invalid project ID. Must be 6-32 characters long '
        'and contain only lowercase letters, numbers, and hyphens.';

    final specifiedProjectId = projectSetup.projectId;
    if (specifiedProjectId != null) {
      if (isValidProjectIdFormat(specifiedProjectId)) {
        return;
      }

      logger.error(invalidProjectIdMessage);
    }

    final selectedId = await _selectExistingProject(cloudApiClient, logger);
    if (selectedId != null) {
      projectSetup.projectId = selectedId;
      projectSetup.preexistingProject = true;
      return;
    }

    final defaultProjectId = _getDefaultProjectId(projectSetup);

    logger.raw(r'''
The project id is the unique identifier for the project.
The default API domain will be: <project-id>.api.serverpod.space
''', style: cli.AnsiStyle.darkGray);

    do {
      final defaultValue = defaultProjectId != null
          ? '$defaultPrefix$defaultProjectId'
          : null;
      var projectId = await logger.input(
        'Enter a new project id',
        defaultValue: defaultValue,
      );

      if (projectId.isEmpty) {
        logger.error('Project ID is required.');
        continue;
      }

      if (defaultProjectId != null && projectId.startsWith(defaultPrefix)) {
        projectId = defaultProjectId;
      }

      if (isValidProjectIdFormat(projectId)) {
        projectSetup.projectId = projectId;
        return;
      }

      logger.error(invalidProjectIdMessage);
    } while (true);
  }

  static Future<String?> _selectExistingProject(
    final Client cloudApiClient,
    final CommandLogger logger,
  ) async {
    final projects = await _fetchExistingUndeployedProjects(cloudApiClient);
    if (projects.isEmpty) {
      return null;
    }
    if (projects.length == 1) {
      return _confirmSingleExistingProject(logger, projects.single);
    }
    return _selectFromSeveralExistingProjects(logger, projects);
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

  static Future<String?> _confirmSingleExistingProject(
    final CommandLogger logger,
    final Project project,
  ) async {
    logger.info(
      'Found an existing undeployed Cloud project: ${project.cloudProjectId}',
    );

    final confirm = await logger.confirm(
      'Continue with ${project.cloudProjectId}?',
    );
    logger.info(' ');
    return confirm ? project.cloudProjectId : null;
  }

  static Future<String?> _selectFromSeveralExistingProjects(
    final CommandLogger logger,
    final List<Project> projects,
  ) async {
    final existingIds = projects.map((final p) => p.cloudProjectId).toList();
    logger.info(
      'Found existing undeployed Cloud projects.\n'
      'Do you want to deploy to one of them instead of creating a new one?',
    );
    for (int i = 0; i < existingIds.length; i++) {
      logger.info('${i + 1}. ${existingIds[i]}');
    }
    logger.info('(blank - create a new project)');

    do {
      final projectNum = await logger.input(
        'Enter a project number from the list, or blank',
      );

      if (projectNum.isEmpty || projectNum == 'q') {
        logger.info(' ');
        return null;
      }

      final projectIx = int.tryParse(projectNum);
      if (projectIx != null &&
          projectIx >= 1 &&
          projectIx <= existingIds.length) {
        logger.info(' ');
        return existingIds[projectIx - 1];
      }

      logger.error('Value must be a number from the list, or empty to skip.');
    } while (true);
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

  static Future<void> confirmSetupAndContinue(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    logger.box('Project setup\n\n$projectSetup');

    final prompt = projectSetup.preexistingProject == true
        ? 'Continue and apply this setup?'
        : 'Continue and open the browser to create this new project?';
    final confirm = await logger.confirm(prompt, defaultValue: true);

    if (!confirm) {
      logger.info('Setup cancelled.');
      throw UserAbortException();
    }
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

    if (projectId == null) {
      throw StateError('ProjectId must be set.');
    }

    logger.info(' ');

    String actualProjectId;
    if (projectSetup.preexistingProject != true) {
      actualProjectId = await createProject(
        logger,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        projectName: projectId,
        usesDb: usesDb,
      );
    } else {
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

    logger.info(
      'When the server has started, you can access it at:\n'
      '   Web:      https://$actualProjectId.${HostConstants.tenantDomain}/\n'
      '   API:      https://$actualProjectId.api.${HostConstants.tenantDomain}/\n'
      '   Insights: https://$actualProjectId.insights.${HostConstants.tenantDomain}/',
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
          'Project created, you may now close this window and return to the CLI.',
      failureMessage:
          'Project creation failed, please try again or contact support.',
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
      'Please create your project in the opened browser or through this link:\n'
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
      successMessage: 'Project created.',
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

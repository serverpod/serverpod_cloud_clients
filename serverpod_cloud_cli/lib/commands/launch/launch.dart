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
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/user_interaction/user_confirmations.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/project_id_validator.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart'
    show TenantProjectPubspec;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_model.dart';
import 'package:serverpod_logging_cli/serverpod_logging_cli.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

abstract class Launch {
  static Future<void> launch(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final Directory projectDirectory,
    required final String? projectId,
    required final PlanProfile? plan,
    required final bool? enableDb,
    required final bool performDeploy,
    required final bool tui,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
    final String? dartVersionOverride,
  }) async {
    logger.init('Launching new Serverpod Cloud project.\n');

    logger.info('Project directory is: ${projectDirectory.path}');

    if (!_validateProjectDir(logger, projectDirectory)) return;

    final projectSetup = ProjectLaunch(
      projectDir: projectDirectory,
      projectId: projectId,
      plan: plan,
      dartVersionOverride: dartVersionOverride,
      enableDb: enableDb,
      performDeploy: performDeploy,
    );

    if (tui) {
      await launchWithTui(
        cloudApiClient,
        fileUploaderFactory,
        logger: logger,
        projectSetup: projectSetup,
        projectDir: projectDirectory,
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
        projectDir: projectDirectory,
        projectSetup: projectSetup,
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
    required final Directory projectDir,
    required final ProjectLaunch projectSetup,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
  }) async {
    await selectProjectId(cloudApiClient, logger, projectSetup);

    if (projectSetup.preexistingProject != true) {
      await selectPlan(cloudApiClient, logger, projectSetup);

      await selectEnableDb(logger, projectSetup);
    }

    final configFilePath = projectSetup.configFilePath;

    await suggestCodeGenerationPreDeployHook(
      logger,
      projectSetup,
      configFilePath,
    );

    await suggestFlutterBuildPreDeployHook(
      logger,
      projectSetup,
      configFilePath,
    );

    await confirmSetupAndContinue(logger, projectSetup);

    await performLaunch(
      cloudApiClient,
      fileUploaderFactory,
      logger,
      projectSetup,
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
    required final Directory projectDir,
    required final int deployConcurrency,
    required final bool deployDryRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
  }) async {
    final defaultProjectId = _getDefaultProjectId(projectDir);

    final existingProjects = await _fetchExistingUndeployedProjects(
      cloudApiClient,
    );
    final existingProjectIds = existingProjects
        .map((final p) => p.cloudProjectId)
        .toList();

    final state = LaunchConfigState(
      projectSetup: projectSetup,
      projectDir: projectDir.path,
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

  static bool _validateProjectDir(
    final CommandLogger logger,
    final Directory projectDir,
  ) {
    final TenantProjectPubspec pubspecValidator;
    try {
      pubspecValidator = TenantProjectPubspec.fromProjectDir(projectDir);
    } on FailureException catch (e) {
      logger.error(e.errors.join('\n'), hint: e.hint);
      return false;
    } on Exception catch (_) {
      return false;
    }

    if (pubspecValidator.isServerpodServer()) {
      final issues = pubspecValidator.projectDependencyIssues();
      if (issues.isEmpty) {
        return true;
      }

      throw FailureException(
        error:
            '`${projectDir.path}` is a Serverpod server directory, but it is not valid:',
        errors: issues,
        hint: 'Resolve the issues and try again.',
      );
    } else {
      logProjectDirIsNotAServerpodServerDirectory(logger, projectDir.path);
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

    await UserConfirmations.confirmNewProjectCostAcceptance(logger);

    final defaultProjectId = _getDefaultProjectId(projectSetup.projectDir);

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

  static String? _getDefaultProjectId(final Directory projectDir) {
    final pubspec = TenantProjectPubspec.fromProjectDir(projectDir);
    if (pubspec.isServerpodServer()) {
      var name = pubspec.pubspec.name.toLowerCase().replaceAll('_', '-');

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

  static Future<void> selectPlan(
    final Client cloudApiClient,
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    final validPlanNames = PlanProfile.values
        .map((final p) => p.name)
        .join(', ');

    var planProfile = projectSetup.plan;

    do {
      if (planProfile != null) {
        projectSetup.plan = planProfile;
        return;
      }

      final projectPlanName = await logger.input('Enter the plan');

      if (projectPlanName.isEmpty) {
        logger.error('Plan is required. Must be one of: $validPlanNames');
        continue;
      }

      planProfile = PlanProfile.values
          .where((final p) => p.name == projectPlanName)
          .firstOrNull;
      if (planProfile == null) {
        logger.error('Invalid plan. Must be one of: $validPlanNames');
        continue;
      }
    } while (true);
  }

  static Future<void> selectEnableDb(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    if (projectSetup.enableDb != null) {
      return;
    }

    final enableDb = await logger.confirm(
      'Enable the database for the project?',
      defaultValue: true,
    );

    projectSetup.enableDb = enableDb;
  }

  static Future<void> suggestFlutterBuildPreDeployHook(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
    final String configFilePath,
  ) async {
    final projectDir = projectSetup.projectDir;
    final pubspecValidator = TenantProjectPubspec.fromProjectDir(projectDir);

    if (!pubspecValidator.hasFlutterBuildScript()) return;

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

    final shouldAdd = await logger.confirm(
      "Detected 'flutter_build' script. Add it as a pre-deploy hook?",
      defaultValue: true,
    );

    if (!shouldAdd) return;
    projectSetup.suggestedPreDeployScripts.add(flutterBuildHook);
  }

  static Future<void> suggestCodeGenerationPreDeployHook(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
    final String configFilePath,
  ) async {
    ScloudConfig? existingConfig;
    try {
      existingConfig = ScloudConfigIO.readFromFile(configFilePath);
    } catch (_) {
      logger.debug('Failed to read config file at $configFilePath');
    }

    final codeGenerationHook = 'serverpod generate';

    final existingPreDeploy = existingConfig?.scripts.preDeploy ?? [];
    if (existingPreDeploy.contains(codeGenerationHook)) return;

    final shouldAdd = await logger.confirm(
      'Add code generation (`serverpod generate`) as a pre-deploy hook?',
      defaultValue: false,
    );

    if (!shouldAdd) return;
    projectSetup.suggestedPreDeployScripts.add(codeGenerationHook);
  }

  static Future<void> confirmSetupAndContinue(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    logger.box('Project setup\n\n$projectSetup');
    final confirm = await logger.confirm(
      'Continue and apply this setup?',
      defaultValue: true,
    );

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
    final configFilePath = projectSetup.configFilePath;
    final performDeploy = projectSetup.performDeploy;
    final planProfile = projectSetup.plan;

    if (projectId == null) {
      throw StateError('ProjectId must be set.');
    }

    logger.info(
      'When the server has started, you can access it at:\n'
      '   Web:      https://$projectId.${HostConstants.tenantDomain}/\n'
      '   API:      https://$projectId.api.${HostConstants.tenantDomain}/\n'
      '   Insights: https://$projectId.insights.${HostConstants.tenantDomain}/',
      newParagraph: true,
    );

    if (projectSetup.preexistingProject != true) {
      if (planProfile == null) {
        throw StateError('PlanProfile must be set.');
      }

      final enableDb = projectSetup.enableDb!;
      await ProjectCommands.createProject(
        cloudApiClient,
        logger: logger,
        projectId: projectId,
        plan: planProfile,
        enableDb: enableDb,
        skipConfirmation: true,
        suppressCommandMessages: true,
      );
    }

    final safeDartSdk = await ProjectCommands.linkProject(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      projectDirectory: projectDir.path,
      configFilePath: configFilePath,
      dartVersionOverride: projectSetup.dartVersionOverride,
      preDeployScripts: projectSetup.suggestedPreDeployScripts,
      suppressCommandMessages: true,
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
      projectId: projectId,
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
}

class ProjectLaunch {
  final Directory projectDir;
  late final String configFilePath;
  String? projectId;
  PlanProfile? plan;
  String? dartVersionOverride;
  bool? enableDb;
  bool? preexistingProject;
  final bool performDeploy;
  List<String> suggestedPreDeployScripts;

  ProjectLaunch({
    required this.projectDir,
    this.projectId,
    this.plan,
    this.dartVersionOverride,
    this.enableDb,
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
          ['New project id', projectId],
          ['Project plan', plan?.name ?? ''],
          ['Enable DB', enableDb == true ? 'yes' : 'no'],
        ] else
          ['Existing project id', projectId],
        if (suggestedPreDeployScripts.isNotEmpty) ...[
          [
            'Pre-deploy hooks',
            suggestedPreDeployScripts
                .map((final hook) => '  - $hook')
                .join('\n'),
          ],
        ],
      ],
      columnSeparator: '  ',
    ).toString();
    return text.substring(0, text.length - 1); // trims last newline
  }
}

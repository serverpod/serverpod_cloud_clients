import 'dart:io';

import 'package:cli_tools/cli_tools.dart' as cli;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/commands/status/status_feature.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/user_interaction/user_confirmations.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/project_id_validator.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';

abstract class Launch {
  static Future<void> launch(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final String? specifiedProjectDir,
    required final String? foundProjectDir,
    required final String? newProjectId,
    required final String? existingProjectId,
    required final bool? enableDb,
    required final bool? performDeploy,
  }) async {
    await ProjectCommands.checkPlanAvailability(cloudApiClient, logger: logger);

    if (newProjectId != null && existingProjectId != null) {
      throw ArgumentError(
        'Cannot specify both newProjectId and existingProjectId.',
      );
    }

    logger.init('Launching new Serverpod Cloud project.\n');

    final projectSetup = ProjectLaunch(
      projectDir: specifiedProjectDir,
      projectId: newProjectId ?? existingProjectId,
      enableDb: enableDb,
      preexistingProject: existingProjectId != null,
      performDeploy: performDeploy,
    );

    await selectProjectDir(logger, projectSetup, foundProjectDir);

    await selectProjectId(cloudApiClient, logger, projectSetup);

    if (projectSetup.preexistingProject != true) {
      await selectEnableDb(logger, projectSetup);
    }

    await selectPerformDeploy(logger, projectSetup);

    await confirmSetupAndContinue(logger, projectSetup);

    await performLaunch(
      cloudApiClient,
      fileUploaderFactory,
      logger,
      projectSetup,
    );
  }

  static Future<void> selectProjectDir(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
    final String? foundProjectDir,
  ) async {
    final specifiedProjectDir = projectSetup.projectDir;
    if (specifiedProjectDir != null) {
      if (_validateProjectDir(logger, specifiedProjectDir)) {
        return;
      }
    }

    if (foundProjectDir != null) {
      if (_validateProjectDir(logger, foundProjectDir)) {
        projectSetup.projectDir = p.relative(foundProjectDir);
        logger.info('Found project directory: ${projectSetup.projectDir}');
        return;
      }
    }

    do {
      final projectDir = await logger.input('Enter the project directory');

      if (projectDir.isEmpty) {
        logger.error('Project directory is required.');
        continue;
      }

      if (_validateProjectDir(logger, projectDir)) {
        projectSetup.projectDir = projectDir;
        return;
      }

      logProjectDirIsNotAServerpodServerDirectory(logger, projectDir);
    } while (true);
  }

  static bool _validateProjectDir(
    final CommandLogger logger,
    final String projectDir,
  ) {
    final TenantProjectPubspec pubspecValidator;
    try {
      pubspecValidator = TenantProjectPubspec.fromProjectDir(
        Directory(projectDir),
      );
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
            '`$projectDir` is a Serverpod server directory, but it is not valid:',
        errors: issues,
        hint: 'Resolve the issues and try again.',
      );
    } else {
      logProjectDirIsNotAServerpodServerDirectory(logger, projectDir);
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
      if (projectSetup.preexistingProject == true ||
          isValidProjectIdFormat(specifiedProjectId)) {
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

  static String? _getDefaultProjectId(final String? projectDir) {
    if (projectDir != null) {
      final pubspec = TenantProjectPubspec.fromProjectDir(
        Directory(projectDir),
      );
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
    }
    return null;
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

  static Future<void> selectPerformDeploy(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    if (projectSetup.performDeploy != null) {
      return;
    }

    final projectId = projectSetup.projectId;
    final confirmationMessage = projectId != null
        ? "Deploy '$projectId' project right away?"
        : 'Deploy the project right away?';

    final performDeploy = await logger.confirm(
      confirmationMessage,
      defaultValue: true,
    );

    projectSetup.performDeploy = performDeploy;
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
    final ProjectLaunch projectSetup,
  ) async {
    logger.info('Launching project...');

    final projectId = projectSetup.projectId;
    final projectDir = projectSetup.projectDir;
    final configFilePath = projectSetup.configFilePath;
    final performDeploy = projectSetup.performDeploy;

    if (projectId == null) {
      throw StateError('ProjectId must be set.');
    }

    if (projectDir == null) {
      throw StateError('ProjectDir must be set.');
    }

    if (configFilePath == null) {
      throw StateError('ConfigFilePath must be set.');
    }

    if (performDeploy == null) {
      throw StateError('PerformDeploy must be set.');
    }

    if (projectSetup.preexistingProject != true) {
      final enableDb = projectSetup.enableDb!;
      await ProjectCommands.createProject(
        cloudApiClient,
        logger: logger,
        projectId: projectId,
        enableDb: enableDb,
        projectDir: projectDir,
        configFilePath: configFilePath,
        skipConfirmation: true,
      );
    }

    if (!performDeploy) {
      logger.terminalCommand(
        'scloud deploy -d $projectDir $projectId',
        message: 'Run this command to deploy the project to the cloud:',
      );
      return;
    }

    await Deploy.deploy(
      cloudApiClient,
      fileUploaderFactory,
      logger: logger,
      projectId: projectId,
      projectDir: projectDir,
      projectConfigFilePath: configFilePath,
      concurrency: 5,
      dryRun: false,
      showFiles: false,
    );

    logger.info(' '); // blank line

    final attemptId = await _getDeployAttemptId(
      cloudApiClient,
      logger,
      projectId,
    );

    await StatusCommands.showDeploymentStatus(
      cloudApiClient,
      logger: logger,
      cloudCapsuleId: projectId,
      attemptId: attemptId,
    );

    const tenantHost = 'serverpod.space';

    logger.success(
      'When the server has started, you can access it at:\n',
      trailingRocket: true,
      newParagraph: true,
      followUp:
          '   Web:      https://$projectId.$tenantHost/\n'
          '   API:      https://$projectId.api.$tenantHost/\n'
          '   Insights: https://$projectId.insights.$tenantHost/',
    );

    logger.terminalCommand(
      'scloud deployment show',
      message: 'View the deployment status:',
    );
  }

  static Future<String> _getDeployAttemptId(
    final Client cloudApiClient,
    final CommandLogger logger,
    final String projectId,
  ) async {
    String? attemptId;
    await logger.progress('Waiting for deployment status.', () async {
      for (int i = 0; i < 3; i++) {
        try {
          attemptId = await StatusFeature.getDeployAttemptId(
            cloudApiClient,
            cloudCapsuleId: projectId,
            attemptNumber: 0,
          );
          return true;
        } on NotFoundException catch (_) {
          logger.debug('Waiting for deployment status...');
          await Future.delayed(const Duration(seconds: 5));
        }
      }
      return false;
    });
    final id = attemptId;
    if (id == null) {
      throw FailureException(
        error: 'Failed to get deployment status.',
        hint:
            'Run this command to see recent deployments: '
            'scloud deployment list',
      );
    }
    return id;
  }
}

class ProjectLaunch {
  String? _projectDir;
  String? configFilePath;
  String? projectId;
  bool? enableDb;
  bool? preexistingProject;
  bool? performDeploy;

  ProjectLaunch({
    final String? projectDir,
    this.projectId,
    this.enableDb,
    this.preexistingProject,
    this.performDeploy,
  }) : _projectDir = projectDir {
    if (projectDir != null) {
      configFilePath = _constructConfigFilePath(projectDir);
    }
  }

  set projectDir(final String projectDir) {
    _projectDir = projectDir;
    configFilePath = _constructConfigFilePath(projectDir);
  }

  String? get projectDir => _projectDir;

  String _constructConfigFilePath(final String projectDir) {
    return p.join(projectDir, ProjectConfigFileConstants.defaultFileName);
  }

  @override
  String toString() {
    final text = TablePrinter.columns(
      rows: [
        ['Project directory', projectDir],
        if (preexistingProject != true) ...[
          ['New project id', projectId],
          ['Enable DB', enableDb == true ? 'yes' : 'no'],
        ] else
          ['Existing project id', projectId],
        ['Perform deploy', performDeploy == true ? 'yes' : 'no'],
      ],
      columnSeparator: '  ',
    ).toString();
    return text.substring(0, text.length - 1); // trims last newline
  }
}

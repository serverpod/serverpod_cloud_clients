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
    required final String? projectId,
    required final bool? enableDb,
    required final bool? performDeploy,
  }) async {
    logger.init('Launching new Serverpod Cloud project.\n');

    final projectSetup = ProjectLaunch(
      projectDir: specifiedProjectDir,
      projectId: projectId,
      enableDb: enableDb,
      performDeploy: performDeploy,
    );

    await selectProjectDir(
      logger,
      projectSetup,
      foundProjectDir,
    );

    await selectProjectId(
      logger,
      projectSetup,
    );

    await selectEnableDb(
      logger,
      projectSetup,
    );

    await selectPerformDeploy(
      logger,
      projectSetup,
    );

    await confirmSetupAndContinue(
      logger,
      projectSetup,
    );

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
      final projectDir = await logger.input(
        'Enter the project directory',
      );

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
        projectSetup.projectId = specifiedProjectId;
        return;
      }

      logger.error(invalidProjectIdMessage);
    }

    final defaultProjectId = _getDefaultProjectId(projectSetup.projectDir);

    logger.raw(
      r'''
The project id is the unique identifier for the project.
The default API domain will be: <project-id>.api.serverpod.space
''',
      style: cli.AnsiStyle.darkGray,
    );

    do {
      final defaultValue =
          defaultProjectId != null ? '$defaultPrefix$defaultProjectId' : null;
      var projectId = await logger.input(
        'Choose project id',
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

    final performDeploy = await logger.confirm(
      'Deploy the project right away?',
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

    final projectId = projectSetup.projectId!;
    final projectDir = projectSetup.projectDir!;
    final enableDb = projectSetup.enableDb!;
    final performDeploy = projectSetup.performDeploy!;

    await ProjectCommands.createProject(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      enableDb: enableDb,
      projectDir: projectDir,
      configFilePath: p.join(
        projectDir,
        ProjectConfigFileConstants.defaultFileName,
      ),
    );

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
      concurrency: 5,
      dryRun: false,
    );

    logger.info(' '); // blank line

    String? attemptId;
    do {
      try {
        attemptId = await StatusFeature.getDeployAttemptId(
          cloudApiClient,
          cloudCapsuleId: projectId,
          attemptNumber: 0,
        );
      } on NotFoundException catch (_) {
        logger.debug('Waiting for deployment status...');
        await Future.delayed(const Duration(seconds: 5));
      }
    } while (attemptId == null);

    await StatusCommands.showDeploymentStatus(
      cloudApiClient,
      logger: logger,
      cloudCapsuleId: projectId,
      attemptId: attemptId,
    );
    logger.terminalCommand(
      'scloud status deploy -p $projectId',
      message: 'Run this command to see the current deployment status:',
    );
  }
}

class ProjectLaunch {
  String? projectDir;
  String? projectId;
  bool? enableDb;
  bool? performDeploy;

  ProjectLaunch({
    this.projectDir,
    this.projectId,
    this.enableDb,
    this.performDeploy,
  });

  @override
  String toString() {
    final text = TablePrinter.columns(rows: [
      ['Project directory', projectDir],
      ['Project Id', projectId],
      ['Enable DB', enableDb == true ? 'yes' : 'no'],
      ['Perform deploy', performDeploy == true ? 'yes' : 'no'],
    ]).toString();
    return text.substring(0, text.length - 1); // trims last newline
  }
}

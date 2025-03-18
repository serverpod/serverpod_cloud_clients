import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/commands/status/status_feature.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/project_id_validator.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';

abstract class Launch {
  static Future<void> launch(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String? specifiedProjectDir,
    required final String? foundProjectDir,
    required final String? projectId,
    required final bool? enableDb,
    required final bool? performDeploy,
  }) async {
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

    await handleCommonClientExceptions(logger, () async {
      await performLaunch(cloudApiClient, logger, projectSetup);
    }, (final e) {
      logger.error('Failed to perform launch', exception: e);
      throw ErrorExitException();
    });
  }

  static Future<void> selectProjectDir(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
    final String? foundProjectDir,
  ) async {
    final specifiedProjectDir = projectSetup.projectDir;
    if (specifiedProjectDir != null) {
      if (isServerpodServerDirectory(Directory(specifiedProjectDir))) {
        return;
      }
      logProjectDirIsNotAServerpodServerDirectory(logger, specifiedProjectDir);
    }

    String? defaultProjectDir = foundProjectDir;
    if (defaultProjectDir != null) {
      defaultProjectDir = p.relative(defaultProjectDir, from: p.current);
    }

    do {
      final projectDir = await logger.input(
        'Enter the project directory',
        defaultValue: defaultProjectDir,
      );
      defaultProjectDir = null;

      if (projectDir.isEmpty) {
        logger.error('Project directory is required.');
        continue;
      }

      if (isServerpodServerDirectory(Directory(projectDir))) {
        projectSetup.projectDir = projectDir;
        return;
      }

      logProjectDirIsNotAServerpodServerDirectory(logger, projectDir);
    } while (true);
  }

  static Future<void> selectProjectId(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    final specifiedProjectId = projectSetup.projectId;
    if (specifiedProjectId != null) {
      try {
        validateProjectIdFormat(specifiedProjectId);
        return;
      } on FormatException catch (e) {
        logger.error(e.message);
      }
    }

    do {
      final projectId = await logger.input('Enter the project ID');

      if (projectId.isEmpty) {
        logger.error('Project ID is required.');
        continue;
      }

      try {
        validateProjectIdFormat(projectId);
        projectSetup.projectId = projectId;
        return;
      } on FormatException catch (e) {
        logger.error(e.message);
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
      'Do you want to enable the database for the project?',
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
      'Do you want to deploy the project right away?',
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
      throw ErrorExitException();
    }
  }

  static Future<void> performLaunch(
    final Client cloudApiClient,
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

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_file.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';

abstract class ProjectCommands {
  /// Subcommand to create a new tenant project.
  static Future<void> createProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final bool enableDb,
    required final String projectDir,
    required final String configFilePath,
  }) async {
    await handleCommonClientExceptions(logger, () async {
      await cloudApiClient.projects.createProject(cloudProjectId: projectId);
    }, (final e) {
      logger.error(
        'Request to create a new project failed',
        exception: e,
      );

      throw ErrorExitException();
    });

    logger.success("Successfully created new project '$projectId'.");

    if (enableDb) {
      await logger.progress('Requesting database creation...', () async {
        await handleCommonClientExceptions(logger, () async {
          await cloudApiClient.infraResources
              .enableDatabase(cloudCapsuleId: projectId);
        }, (final e) {
          logger.error(
            'Request to create a database for the new project failed',
            exception: e,
          );
          throw ErrorExitException();
        });
        return true;
      });

      logger.success(
        "Successfully requested to create a database for the new project '$projectId'.",
      );
    }

    if (isServerpodServerDirectory(Directory(projectDir))) {
      // write scloud-config and scloud-ignore files unless the config file already exists

      final scloudYamlFile = File(configFilePath);
      if (scloudYamlFile.existsSync()) {
        return;
      }

      await handleCommonClientExceptions(logger, () async {
        final projectConfig = await cloudApiClient.projects
            .fetchProjectConfig(cloudProjectId: projectId);

        ScloudConfigFile.writeToFile(projectConfig, configFilePath);
      }, (final e) {
        logger.error(
          'Failed to fetch project config',
          exception: e,
        );
        throw ErrorExitException();
      });

      try {
        ScloudIgnore.writeTemplateIfNotExists(
          rootFolder: projectDir,
        );
      } on Exception catch (e, s) {
        final message = 'Failed to write to ${ScloudIgnore.fileName} file';
        logger.error(message, exception: e);
        throw ErrorExitException(message, e, s);
      }

      logger.success(
        "Successfully created the '$configFilePath' configuration file for '$projectId'.",
      );
    } else {
      logger.terminalCommand(
        message: 'Since no Serverpod server directory was identified, '
            'an scloud.yaml configuration file has not been created. '
            'Use the link command to create it in the server '
            'directory of this project:',
        newParagraph: true,
        'scloud project link --project $projectId',
      );
    }
  }

  static Future<void> deleteProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw ErrorExitException();
    }

    await handleCommonClientExceptions(logger, () async {
      await cloudApiClient.projects.deleteProject(cloudProjectId: projectId);
    }, (final e) {
      logger.error(
        'Request to delete the project failed',
        exception: e,
      );

      throw ErrorExitException();
    });

    logger.success('Successfully deleted the project "$projectId".');
  }

  static Future<void> listProjects(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final bool showArchived = false,
  }) async {
    late List<Project> projects;
    await handleCommonClientExceptions(logger, () async {
      projects = await cloudApiClient.projects.listProjects();
    }, (final e) {
      logger.error(
        'Request to list projects failed',
        exception: e,
      );
      throw ErrorExitException();
    });

    final activeProjects = showArchived
        ? projects
        : projects.where((final p) => p.archivedAt == null);

    if (activeProjects.isEmpty) {
      logger.info('No projects available.');
      return;
    }

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders([
      'Project Id',
      'Created At',
      if (showArchived) 'Deleted At',
    ]);
    for (final project in activeProjects.sortedBy((final p) => p.createdAt)) {
      tablePrinter.addRow([
        project.cloudProjectId,
        project.createdAt.toString().substring(0, 19),
        if (showArchived) project.archivedAt?.toString().substring(0, 19),
      ]);
    }
    tablePrinter.writeLines(logger.line);
  }

  static Future<void> linkProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String projectDirectory,
    required final String configFilePath,
  }) async {
    late final ProjectConfig projectConfig;
    await handleCommonClientExceptions(logger, () async {
      projectConfig = await cloudApiClient.projects.fetchProjectConfig(
        cloudProjectId: projectId,
      );
    }, (final e) {
      logger.error(
        'Failed to fetch project config',
        exception: e,
      );
      throw ErrorExitException();
    });

    try {
      ScloudConfigFile.writeToFile(
        projectConfig,
        configFilePath,
      );
      logger.info(
        "Wrote the '$configFilePath' configuration file for '$projectId'.",
      );
    } on Exception catch (e) {
      logger.error(
        'Failed to write to $configFilePath file',
        exception: e,
      );
      throw ErrorExitException();
    }

    try {
      ScloudIgnore.writeTemplateIfNotExists(
        rootFolder: projectDirectory,
      );
    } on Exception catch (e, s) {
      final message = 'Failed to write to ${ScloudIgnore.fileName} file';
      logger.error(message, exception: e);
      throw ErrorExitException(message, e, s);
    }

    logger.success('Successfully linked project!');
  }
}

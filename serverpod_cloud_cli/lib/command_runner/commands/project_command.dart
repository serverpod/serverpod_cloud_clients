import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_cloud_cli/util/serverpod_server_folder_detection.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class CloudProjectCommand extends CloudCliCommand {
  @override
  final name = 'project';

  @override
  final description = 'Manage Serverpod Cloud projects.';

  CloudProjectCommand({required super.logger}) {
    // Subcommands
    addSubcommand(CloudProjectCreateCommand(logger: logger));
    addSubcommand(CloudProjectDeleteCommand(logger: logger));
    addSubcommand(CloudProjectListCommand(logger: logger));
  }
}

abstract final class _ProjectOptions {
  static const projectId = ConfigOption(
    argName: 'project-id',
    argAbbrev: 'i',
    argPos: 0,
    helpText:
        'The ID of the project. Can also be specified as the first argument.',
    mandatory: true,
    envName: 'SERVERPOD_CLOUD_PROJECT_ID',
  );

  static const enableDb = ConfigOption(
    argName: 'enable-db',
    isFlag: true,
    negatable: true,
    defaultsTo: 'false',
    helpText: 'Flag to enable the database for the project.',
  );
}

enum ProjectCreateOption implements OptionDefinition {
  projectId(_ProjectOptions.projectId),
  enableDb(_ProjectOptions.enableDb);

  const ProjectCreateOption(this.option);

  @override
  final ConfigOption option;
}

class CloudProjectCreateCommand extends CloudCliCommand<ProjectCreateOption> {
  @override
  final name = 'create';

  @override
  final description = 'Create a Serverpod Cloud project.';

  @override
  CloudProjectCreateCommand({required super.logger})
      : super(options: ProjectCreateOption.values);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(ProjectCreateOption.projectId);
    final enableDb = commandConfig.flag(ProjectCreateOption.enableDb);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    try {
      await apiCloudClient.projects.createProject(cloudProjectId: projectId);
    } catch (e) {
      logger.error(
        'Request to create a new project failed: $e',
      );
      throw ExitException();
    }

    logger.info("Successfully created new project '$projectId'.");

    if (enableDb) {
      try {
        await apiCloudClient.infraResources
            .enableDatabase(cloudEnvironmentId: projectId);
      } catch (e) {
        logger.error(
          'Request to create a database for the new project failed: $e',
        );
        throw ExitException();
      }

      logger.info(
        "Successfully requested to create a database for the new project '$projectId'.",
      );
    }

    if (isServerpodServerDirectory(Directory.current.path)) {
      try {
        if (File(ConfigFileConstants.fileName).existsSync()) {
          return;
        }

        final projectConfig = await apiCloudClient.projects
            .fetchProjectConfig(cloudProjectId: projectId);

        ScloudConfig.writeToFile(projectConfig, Directory.current);
      } catch (e) {
        logger.error(
          'Failed to fetch project config: $e',
        );
        throw ExitException();
      }

      logger.info(
        "Successfully created the ${ConfigFileConstants.fileName} configuration file for '$projectId'.",
      );
    } else {
      logger.info(
        'Since the current directory is not a Serverpod server directory '
        'an scloud.yaml configuration file has not been created. \n'
        'Use the scloud link command to create it in the server '
        'directory of this project.',
      );
    }
  }
}

class CloudProjectDeleteCommand extends CloudCliCommand {
  @override
  final name = 'delete';

  @override
  final description = 'Delete a Serverpod Cloud project.';

  CloudProjectDeleteCommand({required super.logger})
      : super(options: [_ProjectOptions.projectId]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(_ProjectOptions.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    try {
      await apiCloudClient.projects.deleteProject(cloudProjectId: projectId);
    } catch (e) {
      logger.error(
        'Request to delete a new project failed: $e',
      );
      throw ExitException();
    }

    logger.info("Successfully deleted the project '$projectId'.");
  }
}

class CloudProjectListCommand extends CloudCliCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the Serverpod Cloud projects.';

  @override
  final bool takesArguments = false;

  CloudProjectListCommand({required super.logger}) : super(options: []);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    late List<Project> projects;
    try {
      projects = await apiCloudClient.projects.listProjects();
    } catch (e) {
      logger.error(
        'Request to list projects failed: $e',
      );
      throw ExitException();
    }
    if (projects.isEmpty) {
      logger.info('No projects available.');
      return;
    }
    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Project Canonical Name', 'Created At']);
    for (final project in projects.sortedBy((final p) => p.createdAt)) {
      tablePrinter.addRow([
        project.cloudProjectId,
        project.createdAt.toString().substring(0, 19),
      ]);
    }
    tablePrinter.toString().split('\n').forEach(logger.info);
  }
}

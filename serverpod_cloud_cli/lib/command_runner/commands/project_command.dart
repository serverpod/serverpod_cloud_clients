import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'categories.dart';

class CloudProjectCommand extends CloudCliCommand {
  @override
  final name = 'project';

  @override
  final description = 'Manage Serverpod Cloud projects.';

  @override
  String get category => CommandCategories.manage;

  CloudProjectCommand({required super.logger}) {
    // Subcommands
    addSubcommand(CloudProjectCreateCommand(logger: logger));
    addSubcommand(CloudProjectDeleteCommand(logger: logger));
    addSubcommand(CloudProjectListCommand(logger: logger));
    addSubcommand(CloudProjectLinkCommand(logger: logger));
  }
}

abstract final class _ProjectOptions {
  static const projectIdForCreation = ProjectIdOption.argsOnly(
    helpText: 'The ID of the project. Can be passed as the first argument.',
    argPos: 0,
  );

  static const projectId = ProjectIdOption.argsOnly(
    helpText:
        '${CommandConfigConstants.projectIdHelpText} Can be passed as the first argument.',
    argPos: 0,
  );

  static const enableDb = ConfigOption(
    argName: 'enable-db',
    isFlag: true,
    helpText: 'Flag to enable the database for the project.',
    mandatory: true,
  );
}

enum ProjectCreateOption implements OptionDefinition {
  projectId(_ProjectOptions.projectIdForCreation),
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
    await handleCommonClientExceptions(logger, () async {
      await apiCloudClient.projects.createProject(cloudProjectId: projectId);
    }, (final e) {
      logger.error(
        'Request to create a new project failed: $e',
      );

      throw ErrorExitException();
    });

    logger.success("Successfully created new project '$projectId'.");

    if (enableDb) {
      await handleCommonClientExceptions(logger, () async {
        await apiCloudClient.infraResources
            .enableDatabase(cloudCapsuleId: projectId);
      }, (final e) {
        logger.error(
          'Request to create a database for the new project failed: $e',
        );
        throw ErrorExitException();
      });

      logger.info(
        "Successfully requested to create a database for the new project '$projectId'.",
      );
    }

    final projectDir = runner.selectProjectDirectory();

    if (isServerpodServerDirectory(Directory(projectDir))) {
      // write scloud-config and scloud-ignore files unless the config file already exists

      final configFilePath = globalConfiguration.projectConfigFile ??
          p.join(
            projectDir,
            ProjectConfigFileConstants.defaultFileName,
          );

      final scloudYamlFile = File(configFilePath);
      if (scloudYamlFile.existsSync()) {
        return;
      }

      await handleCommonClientExceptions(logger, () async {
        final projectConfig = await apiCloudClient.projects
            .fetchProjectConfig(cloudProjectId: projectId);

        ScloudConfigFile.writeToFile(projectConfig, configFilePath);
      }, (final e) {
        logger.error('Failed to fetch project config: $e');
        throw ErrorExitException();
      });

      try {
        if (!ScloudIgnore.fileExists(rootFolder: projectDir)) {
          ScloudIgnore.writeTemplate(rootFolder: projectDir);
        }
      } catch (e) {
        logger.error('Failed to write to ${ScloudIgnore.fileName} file: $e');
        throw ErrorExitException();
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

    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
      checkBypassFlag: runner.globalConfiguration.flag,
    );

    if (!shouldDelete) {
      throw ErrorExitException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    await handleCommonClientExceptions(logger, () async {
      await apiCloudClient.projects.deleteProject(cloudProjectId: projectId);
    }, (final e) {
      logger.error(
        'Request to delete the project failed: $e',
      );

      throw ErrorExitException();
    });

    logger.success('Successfully deleted the project "$projectId".');
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
    await handleCommonClientExceptions(logger, () async {
      projects = await apiCloudClient.projects.listProjects();
    }, (final e) {
      logger.error(
        'Request to list projects failed: $e',
      );
      throw ErrorExitException();
    });

    if (projects.isEmpty) {
      logger.info('No projects available.');
      return;
    }
    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Project Id', 'Created At']);
    for (final project in projects
        .where((final p) => p.archivedAt == null)
        .sortedBy((final p) => p.createdAt)) {
      tablePrinter.addRow([
        project.cloudProjectId,
        project.createdAt.toString().substring(0, 19),
      ]);
    }
    tablePrinter.writeLines(logger.line);
  }
}

enum ProjectLinkCommandOption implements OptionDefinition {
  projectId(
    ProjectIdOption(),
  );

  const ProjectLinkCommandOption(this.option);

  @override
  final ConfigOption option;
}

class CloudProjectLinkCommand
    extends CloudCliCommand<ProjectLinkCommandOption> {
  @override
  String get description =>
      'Link your local project to an existing Serverpod Cloud project.';

  @override
  String get name => 'link';

  CloudProjectLinkCommand({required super.logger})
      : super(options: ProjectLinkCommandOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectLinkCommandOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ProjectLinkCommandOption.projectId);
    final projectDirectory = runner.verifiedProjectDirectory();

    final configFilePath = globalConfiguration.projectConfigFile ??
        p.join(
          projectDirectory.path,
          ProjectConfigFileConstants.defaultFileName,
        );

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late final ProjectConfig projectConfig;
    await handleCommonClientExceptions(logger, () async {
      projectConfig = await apiCloudClient.projects.fetchProjectConfig(
        cloudProjectId: projectId,
      );
    }, (final e) {
      logger.error('Failed to fetch project config: $e');
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
    } catch (e) {
      logger.error('Failed to write to $configFilePath file: $e');
      throw ErrorExitException();
    }

    try {
      if (!ScloudIgnore.fileExists(rootFolder: projectDirectory.path)) {
        ScloudIgnore.writeTemplate(rootFolder: projectDirectory.path);
      }
    } catch (e) {
      logger.error('Failed to write to ${ScloudIgnore.fileName} file: $e');
      throw ErrorExitException();
    }

    logger.success('Successfully linked project!');
  }
}

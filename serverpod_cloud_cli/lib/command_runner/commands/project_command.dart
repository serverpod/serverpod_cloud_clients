import 'dart:io';

import 'package:config/config.dart';
import 'package:path/path.dart' as p;

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';

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
    addSubcommand(CloudProjectUserCommand(logger: logger));
  }
}

enum ProjectCreateOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  enableDb(FlagOption(
    argName: 'enable-db',
    helpText: 'Flag to enable the database for the project.',
    mandatory: true,
  ));

  const ProjectCreateOption(this.option);

  @override
  final ConfigOptionBase<V> option;
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
    final enableDb = commandConfig.value(ProjectCreateOption.enableDb);
    final projectDir =
        runner.selectProjectDirectory() ?? Directory.current.path;
    final configFilePath = globalConfiguration.projectConfigFile?.path ??
        p.join(projectDir, ProjectConfigFileConstants.defaultFileName);

    logger.debug('Using project directory `$projectDir`');

    await ProjectCommands.createProject(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      enableDb: enableDb,
      projectDir: projectDir,
      configFilePath: configFilePath,
    );
  }
}

enum ProjectDeleteOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const ProjectDeleteOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudProjectDeleteCommand extends CloudCliCommand {
  @override
  final name = 'delete';

  @override
  final description = 'Delete a Serverpod Cloud project.';

  CloudProjectDeleteCommand({required super.logger})
      : super(options: ProjectDeleteOption.values);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(ProjectDeleteOption.projectId);

    await ProjectCommands.deleteProject(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
    );
  }
}

enum ProjectListCommandOption<V> implements OptionDefinition<V> {
  all(FlagOption(
    argName: 'all',
    helpText: 'Include deleted projects.',
    defaultsTo: false,
    negatable: false,
  ));

  const ProjectListCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudProjectListCommand
    extends CloudCliCommand<ProjectListCommandOption> {
  @override
  final name = 'list';

  @override
  final description = 'List the Serverpod Cloud projects.';

  @override
  final bool takesArguments = false;

  CloudProjectListCommand({required super.logger})
      : super(options: ProjectListCommandOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectListCommandOption> commandConfig,
  ) async {
    final showArchived = commandConfig.value(ProjectListCommandOption.all);

    await ProjectCommands.listProjects(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      showArchived: showArchived,
    );
  }
}

enum ProjectLinkCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const ProjectLinkCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
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
    final configFilePath = globalConfiguration.projectConfigFile?.path ??
        p.join(
          projectDirectory.path,
          ProjectConfigFileConstants.defaultFileName,
        );

    logger.debug('Using project directory `${projectDirectory.path}`');

    await ProjectCommands.linkProject(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      projectDirectory: projectDirectory.path,
      configFilePath: configFilePath,
    );
  }
}

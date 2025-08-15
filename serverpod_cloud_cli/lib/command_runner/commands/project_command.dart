import 'dart:io';

import 'package:config/config.dart';
import 'package:email_validator/email_validator.dart';
import 'package:path/path.dart' as p;

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
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
    addSubcommand(ProjectInviteUserCommand(logger: logger));
    addSubcommand(ProjectRevokeUserCommand(logger: logger));
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

void _emailValidator(final value) {
  if (!EmailValidator.validate(value)) {
    throw FormatException('Invalid email address: $value');
  }
}

const _projectRoleNames = ['owners'];
const _projectRoleHelp = {'owners': 'Owners have full access to the project.'};

enum ProjectInviteUserOption<V> implements OptionDefinition<V> {
  projectId(
    ProjectIdOption(asFirstArg: true),
  ),
  user(
    StringOption(
      argName: 'user',
      argAbbrev: 'u',
      helpText: 'The email address of the user.',
      mandatory: true,
      customValidator: _emailValidator,
    ),
  ),
  roles(
    MultiStringOption(
      argName: 'role',
      argAbbrev: 'r',
      helpText: 'One or more project roles to assign.',
      allowedValues: _projectRoleNames,
      allowedHelp: _projectRoleHelp,
      mandatory: true,
    ),
  );

  const ProjectInviteUserOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class ProjectInviteUserCommand
    extends CloudCliCommand<ProjectInviteUserOption> {
  @override
  String get description => 'Invite a user to a Serverpod Cloud project.';

  @override
  String get name => 'invite';

  @override
  String get category => 'User Roles';

  ProjectInviteUserCommand({required super.logger})
      : super(options: ProjectInviteUserOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectInviteUserOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ProjectInviteUserOption.projectId);
    final userEmail = commandConfig.value(ProjectInviteUserOption.user);
    final roles = commandConfig.value(ProjectInviteUserOption.roles);

    await ProjectCommands.inviteUser(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      email: userEmail,
      assignRoleNames: roles,
    );
  }
}

enum ProjectRevokeUserOption<V> implements OptionDefinition<V> {
  projectId(
    ProjectIdOption(asFirstArg: true),
  ),
  user(
    StringOption(
      argName: 'user',
      argAbbrev: 'u',
      argPos: 1,
      helpText: 'The email address of the user.',
      mandatory: true,
      customValidator: _emailValidator,
    ),
  ),
  roles(
    MultiStringOption(
      argName: 'role',
      argAbbrev: 'r',
      helpText: 'One or more project roles to revoke.',
      allowedValues: _projectRoleNames,
      allowedHelp: _projectRoleHelp,
      group: MutuallyExclusive('Roles', mode: MutuallyExclusiveMode.mandatory),
    ),
  ),
  allRoles(
    FlagOption(
      argName: 'all',
      helpText: 'Revoke all roles of this project from the user.',
      negatable: false,
      group: MutuallyExclusive('Roles', mode: MutuallyExclusiveMode.mandatory),
    ),
  );

  const ProjectRevokeUserOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class ProjectRevokeUserCommand
    extends CloudCliCommand<ProjectRevokeUserOption> {
  @override
  String get description => 'Revoke a user from a Serverpod Cloud project.';

  @override
  String get name => 'revoke';

  @override
  String get category => 'User Roles';

  ProjectRevokeUserCommand({required super.logger})
      : super(options: ProjectRevokeUserOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectRevokeUserOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ProjectRevokeUserOption.projectId);
    final userEmail = commandConfig.value(ProjectRevokeUserOption.user);
    final roles = commandConfig.optionalValue(ProjectRevokeUserOption.roles);
    final allRoles =
        commandConfig.optionalValue(ProjectRevokeUserOption.allRoles);

    await ProjectCommands.revokeUser(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      email: userEmail,
      unassignRoleNames: roles ?? const [],
      unassignAllRoles: allRoles ?? false,
    );
  }
}

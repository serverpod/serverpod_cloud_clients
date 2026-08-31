import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user/user_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user/user_ui.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_ops.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

class CloudProjectUserCommand extends CloudCliCommand {
  @override
  final name = 'user';

  @override
  final description = 'Manage Serverpod Cloud project users.';

  @override
  String get category => CommandCategories.manage;

  CloudProjectUserCommand({required super.logger}) {
    addSubcommand(ProjectUserListCommand(logger: logger));
    addSubcommand(ProjectUserInviteCommand(logger: logger));
    addSubcommand(ProjectUserRevokeCommand(logger: logger));
  }
}

enum ProjectUserListOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  format(FormatOption());

  const ProjectUserListOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class ProjectUserListCommand extends CloudCliCommand<ProjectUserListOption> {
  @override
  final name = 'list';

  @override
  final description = 'List users in a Serverpod Cloud project.';

  @override
  String get usageExamples => '''\n
Examples

  List all users in a project.
  
    \$ scloud project user list --project my-project

''';

  ProjectUserListCommand({required super.logger})
    : super(options: ProjectUserListOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectUserListOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ProjectUserListOption.projectId);
    final format = commandConfig.value(ProjectUserListOption.format);

    final output = CommandOutput(format: format, logger: logger);
    await renderCommand(
      output,
      operation: () => UserCommands.listUsersOperation(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: ProjectUserListTextUi(projectId: projectId),
    );
  }
}

const _projectRoleNames = ['admin'];
const _projectRoleHelp = {'admin': 'Admins have full access to the project.'};

enum ProjectUserInviteOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  user(UserEmailOption(argPos: 0, mandatory: true)),
  roles(
    MultiStringOption(
      argName: 'role',
      argAbbrev: 'r',
      helpText: 'One or more project roles to assign.',
      allowedValues: _projectRoleNames,
      allowedHelp: _projectRoleHelp,
      defaultsTo: ['admin'],
      hide: true,
    ),
  );

  const ProjectUserInviteOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class ProjectUserInviteCommand
    extends CloudCliCommand<ProjectUserInviteOption> {
  @override
  String get description => 'Invite a user to a Serverpod Cloud project.';

  @override
  String get name => 'invite';

  @override
  String get usageExamples => '''\n
Examples

  Invite a user to the project

    \$ scloud project user invite user@example.com

''';

  ProjectUserInviteCommand({required super.logger})
    : super(options: ProjectUserInviteOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectUserInviteOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ProjectUserInviteOption.projectId);
    final userEmail = commandConfig.value(ProjectUserInviteOption.user);
    final roles = commandConfig.value(ProjectUserInviteOption.roles);

    await ProjectCommands.inviteUser(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      email: userEmail,
      assignRoleNames: roles,
    );
  }
}

enum ProjectUserRevokeOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  user(UserEmailOption(argPos: 0, mandatory: true));

  const ProjectUserRevokeOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class ProjectUserRevokeCommand
    extends CloudCliCommand<ProjectUserRevokeOption> {
  @override
  String get description => 'Revoke a user from a Serverpod Cloud project.';

  @override
  String get name => 'revoke';

  @override
  String get usageExamples => '''\n
Examples

  Revoke a user from a project.
  
    \$ scloud project user revoke user@example.com

''';

  ProjectUserRevokeCommand({required super.logger})
    : super(options: ProjectUserRevokeOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ProjectUserRevokeOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ProjectUserRevokeOption.projectId);
    final userEmail = commandConfig.value(ProjectUserRevokeOption.user);

    await ProjectCommands.revokeUser(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      email: userEmail,
      unassignRoleNames: const [],
      unassignAllRoles: true,
    );
  }
}

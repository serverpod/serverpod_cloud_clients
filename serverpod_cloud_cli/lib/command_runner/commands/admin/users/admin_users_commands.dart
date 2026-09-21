import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show UserAccountStatus;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/users/user_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/users/user_admin_ui.dart';

class AdminUserCommand extends CloudCliCommand {
  @override
  final name = 'user';

  @override
  final description = 'Manage Serverpod Cloud project user memberships.';

  AdminUserCommand({required super.logger}) {
    addSubcommand(AdminUserAttachCommand(logger: logger));
    addSubcommand(AdminUserDetachCommand(logger: logger));
  }
}

enum AdminListUsersOption<V> implements OptionDefinition<V> {
  projectId(
    StringOption(
      argName: 'project-id',
      helpText: 'Filter users by project ID.',
    ),
  ),
  accountStatus(
    EnumOption(
      enumParser: EnumParser(UserAccountStatus.values),
      argName: 'status',
      helpText: 'Filter users by account status.',
    ),
  ),
  includeArchived(
    FlagOption(
      argName: 'include-archived',
      helpText: 'Include archived users.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  utc(UtcOption());

  const AdminListUsersOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListUsersCommand extends CloudCliCommand<AdminListUsersOption> {
  @override
  final name = 'list-users';

  @override
  final description = 'List Serverpod Cloud users.';

  AdminListUsersCommand({required super.logger})
    : super(options: AdminListUsersOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminListUsersOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.optionalValue(
      AdminListUsersOption.projectId,
    );
    final accountStatus = commandConfig.optionalValue(
      AdminListUsersOption.accountStatus,
    );
    final includeArchived = commandConfig.value(
      AdminListUsersOption.includeArchived,
    );
    final inUtc = commandConfig.value(AdminListUsersOption.utc);

    await renderCommand(
      output,
      operation: () => UserAdminCommands.listUsersOperation(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        ofAccountStatus: accountStatus,
        includeArchived: includeArchived,
      ),
      textOutputUi: AdminUserListTextUi(utc: inUtc),
    );
  }
}

enum AdminInviteUserOption<V> implements OptionDefinition<V> {
  user(UserEmailOption(argPos: 0, mandatory: true));

  const AdminInviteUserOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminInviteUserCommand extends CloudCliCommand<AdminInviteUserOption> {
  @override
  final name = 'invite-user';

  @override
  final description = 'Invite a user to Serverpod Cloud.';

  AdminInviteUserCommand({required super.logger})
    : super(options: AdminInviteUserOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminInviteUserOption> commandConfig,
    final CommandOutput output,
  ) async {
    final email = commandConfig.value(AdminInviteUserOption.user);

    await renderCommand(
      output,
      operation: () => UserAdminCommands.inviteUser(
        runner.serviceProvider.cloudApiClient,
        email: email,
      ).then((final _) => const <String, Object?>{}),
      textOutputUi: const AdminInviteUserTextUi(),
    );
  }
}

enum AdminUserAttachOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  user(UserEmailOption(argPos: 1, mandatory: true)),
  role(ProjectRoleOptions.attachRoleAsThirdArg);

  const AdminUserAttachOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminUserAttachCommand extends CloudCliCommand<AdminUserAttachOption> {
  @override
  final name = 'attach';

  @override
  final description = 'Attach an existing user to a Serverpod Cloud project.';

  AdminUserAttachCommand({required super.logger})
    : super(options: AdminUserAttachOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminUserAttachOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AdminUserAttachOption.projectId);
    final email = commandConfig.value(AdminUserAttachOption.user);
    final role = commandConfig.value(AdminUserAttachOption.role);

    await renderCommand(
      output,
      operation: () => UserAdminCommands.attachUserToProject(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        email: email,
        assignRoles: [role],
      ),
      textOutputUi: const AdminUserAttachTextUi(),
    );
  }
}

enum AdminUserDetachOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  user(UserEmailOption(argPos: 1, mandatory: true)),
  role(ProjectRoleOptions.detachRoleAsThirdArg);

  const AdminUserDetachOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminUserDetachCommand extends CloudCliCommand<AdminUserDetachOption> {
  @override
  final name = 'detach';

  @override
  final description = 'Detach a user from a Serverpod Cloud project.';

  AdminUserDetachCommand({required super.logger})
    : super(options: AdminUserDetachOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminUserDetachOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AdminUserDetachOption.projectId);
    final email = commandConfig.value(AdminUserDetachOption.user);
    final role = commandConfig.optionalValue(AdminUserDetachOption.role);
    final unassignAllRoles = role == null;

    await confirmToContinue(
      output,
      message: unassignAllRoles
          ? 'Are you sure you want to detach "$email" from all roles on project "$projectId"?'
          : 'Are you sure you want to detach "$email" from role "${role.name}" on project "$projectId"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => UserAdminCommands.detachUserFromProject(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        email: email,
        unassignRoles: role == null ? const [] : [role],
        unassignAllRoles: unassignAllRoles,
      ),
      textOutputUi: AdminUserDetachTextUi(unassignAllRoles: unassignAllRoles),
    );
  }
}

import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show UserAccountStatus;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/admin/user_admin.dart';

enum AdminListUsersOption<V> implements OptionDefinition<V> {
  projectId(StringOption(
    argName: 'project-id',
    helpText: 'Filter users by project ID.',
  )),
  accountStatus(EnumOption(
    enumParser: EnumParser(UserAccountStatus.values),
    argName: 'status',
    helpText: 'Filter users by account status.',
  )),
  includeArchived(FlagOption(
    argName: 'include-archived',
    helpText: 'Include archived users.',
    defaultsTo: false,
    negatable: false,
  )),
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
  Future<void> runWithConfig(
    final Configuration<AdminListUsersOption> commandConfig,
  ) async {
    final projectId =
        commandConfig.optionalValue(AdminListUsersOption.projectId);
    final accountStatus =
        commandConfig.optionalValue(AdminListUsersOption.accountStatus);
    final includeArchived =
        commandConfig.value(AdminListUsersOption.includeArchived);
    final inUtc = commandConfig.value(AdminListUsersOption.utc);

    await UserAdminCommands.listUsers(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      inUtc: inUtc,
      projectId: projectId,
      ofAccountStatus: accountStatus,
      includeArchived: includeArchived,
    );
  }
}

enum AdminInviteUserOption<V> implements OptionDefinition<V> {
  user(
    UserEmailOption(argPos: 0, mandatory: true),
  );

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
  Future<void> runWithConfig(
    final Configuration<AdminInviteUserOption> commandConfig,
  ) async {
    final email = commandConfig.value(AdminInviteUserOption.user);

    await UserAdminCommands.inviteUser(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      email: email,
    );
  }
}

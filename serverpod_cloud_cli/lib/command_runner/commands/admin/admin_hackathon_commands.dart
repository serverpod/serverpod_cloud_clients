import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/commands/admin/user_admin.dart';

import '../../helpers/command_options.dart';

class AdminHackathonCommand extends CloudCliCommand {
  @override
  final name = 'hackathon';

  @override
  final description = 'Hackathon users commands.';

  AdminHackathonCommand({required super.logger}) {
    addSubcommand(AdminListHackathonUsersCommand(logger: logger));
    addSubcommand(AdminSendHackathonThankyousCommand(logger: logger));
  }
}

enum AdminListHackathonUsersOption<V> implements OptionDefinition<V> {
  utc(UtcOption()),
  excludeWithoutProjects(
    FlagOption(
      argName: 'projects',
      helpText: 'Exclude users without active projects.',
      defaultsTo: true,
      negatable: true,
    ),
  );

  const AdminListHackathonUsersOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListHackathonUsersCommand
    extends CloudCliCommand<AdminListHackathonUsersOption> {
  @override
  final name = 'list-users';

  @override
  final description = 'List Hackathon users.';

  AdminListHackathonUsersCommand({required super.logger})
    : super(options: AdminListHackathonUsersOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminListHackathonUsersOption> commandConfig,
  ) async {
    final inUtc = commandConfig.value(AdminListHackathonUsersOption.utc);
    final excludeWithoutProjects = commandConfig.value(
      AdminListHackathonUsersOption.excludeWithoutProjects,
    );

    await UserAdminCommands.listHackathonUsers(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      includeWithoutProjects: !excludeWithoutProjects,
      inUtc: inUtc,
    );
  }
}

enum AdminSendHackathonThankyousOption<V> implements OptionDefinition<V> {
  user(UserEmailOption(argPos: 0)),
  excludeWithoutProjects(
    FlagOption(
      argName: 'projects',
      helpText: 'Exclude users without active projects.',
      defaultsTo: true,
      negatable: true,
    ),
  );

  const AdminSendHackathonThankyousOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminSendHackathonThankyousCommand
    extends CloudCliCommand<AdminSendHackathonThankyousOption> {
  @override
  final name = 'send-thankyous';

  @override
  final description = 'Send Hackathon thank-you emails.';

  AdminSendHackathonThankyousCommand({required super.logger})
    : super(options: AdminSendHackathonThankyousOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminSendHackathonThankyousOption> commandConfig,
  ) async {
    final email = commandConfig.optionalValue(
      AdminSendHackathonThankyousOption.user,
    );
    final excludeWithoutProjects = commandConfig.value(
      AdminSendHackathonThankyousOption.excludeWithoutProjects,
    );

    if (email != null) {
      await UserAdminCommands.sendSingleHackathonThankyou(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        email: email,
      );
    } else {
      await UserAdminCommands.sendHackathonThankyous(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        includeWithoutProjects: !excludeWithoutProjects,
      );
    }
  }
}

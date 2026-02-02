import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';

import 'admin_product_commands.dart';
import 'admin_projects_commands.dart';
import 'admin_redeploy_command.dart';
import 'admin_users_commands.dart';

/// The admin command is used internally for Serverpod Cloud administration.
///
/// It is not intended to be used by end users and is hidden from the help command.
class CloudAdminCommand extends CloudCliCommand {
  @override
  final name = 'admin';

  @override
  final description = 'Serverpod Cloud administration.';

  @override
  final bool hidden;

  CloudAdminCommand({required super.logger, this.hidden = true}) {
    addSubcommand(AdminListUsersCommand(logger: logger));
    addSubcommand(AdminInviteUserCommand(logger: logger));
    addSubcommand(AdminInviteHackathonUserCommand(logger: logger));
    addSubcommand(AdminDeleteUserCommand(logger: logger));
    addSubcommand(AdminProjectCommand(logger: logger));
    addSubcommand(AdminRedeployCommand(logger: logger));
    addSubcommand(AdminProductCommand(logger: logger));
  }
}

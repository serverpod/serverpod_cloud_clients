import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class UserCommands {
  static Future<void> listUsers(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final users = await cloudApiClient.users.listUsersInProject(
      cloudProjectId: projectId,
    );

    final table = TablePrinter(
      headers: ['User', 'Project', 'Project roles'],
      rows: users.map((final user) => [
            user.email,
            projectId,
            user.memberships
                    ?.map((final m) => m.role?.name)
                    .nonNulls
                    .join(', ') ??
                '',
          ]),
    );
    table.writeLines(logger.line);
  }
}

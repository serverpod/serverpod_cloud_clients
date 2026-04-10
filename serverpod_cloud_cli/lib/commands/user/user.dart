import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

abstract class UserCommands {
  static Future<void> listUsers(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final users = await cloudApiClient.users.listUsersInProject(
      cloudProjectId: projectId,
    );

    logger.outputTable(
      headers: ['User', 'Project', 'Project roles'],
      rows: [
        for (final user in users)
          [
            user.email,
            projectId,
            user.memberships
                    ?.map((final m) => m.role?.name)
                    .nonNulls
                    .join(', ') ??
                '',
          ],
      ],
    );
  }
}

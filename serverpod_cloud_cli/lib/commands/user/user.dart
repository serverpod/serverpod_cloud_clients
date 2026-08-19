import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

class ProjectUserListItem {
  final String email;
  final String projectId;
  final List<String> roles;

  const ProjectUserListItem({
    required this.email,
    required this.projectId,
    required this.roles,
  });
}

abstract class UserCommands {
  static Future<void> listUsers(
    final Client cloudApiClient, {
    required final CommandOutput output,
    required final String projectId,
  }) async {
    final users = await cloudApiClient.users.listUsersInProject(
      cloudProjectId: projectId,
    );

    final items = users
        .map(
          (final user) => ProjectUserListItem(
            email: user.email,
            projectId: projectId,
            roles:
                user.memberships
                    ?.map((final m) => m.role?.name)
                    .nonNulls
                    .toList() ??
                const [],
          ),
        )
        .toList();

    output.outputList(
      items,
      OutputSchemaObject<ProjectUserListItem>([
        OutputSchemaField(
          name: 'email',
          label: 'User',
          value: (final item) => item.email,
        ),
        OutputSchemaField(
          name: 'projectId',
          label: 'Project',
          value: (final item) => item.projectId,
        ),
        OutputSchemaField(
          name: 'roles',
          label: 'Project roles',
          value: (final item) => item.roles,
        ),
      ]),
    );
  }
}

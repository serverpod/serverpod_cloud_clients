import 'package:ground_control_client/ground_control_client.dart' show User;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ProjectUserListTextUi extends OutputWidget {
  final String projectId;

  ProjectUserListTextUi({required this.projectId});

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<User>(
        columns: [
          TableColumnFormatter.forElement(
            'User',
            getter: (final user) => user.email,
          ),
          TableColumnFormatter.forElement(
            'Project',
            getter: (final user) => projectId,
          ),
          TableColumnFormatter.forElement(
            'Project roles',
            getter: (final user) =>
                user.memberships
                    ?.map((final membership) => membership.role?.name)
                    .nonNulls
                    .toList() ??
                const <String>[],
          ),
        ],
        utc: false,
      ),
    );
  }
}

class ProjectUserInviteTextUi extends OutputWidget {
  const ProjectUserInviteTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final roles = result['roles'];
    final roleNames = roles is List ? roles.join(', ') : '';
    return SuccessTextWidget(
      'User invited to the project with roles: $roleNames.',
      newParagraph: true,
    );
  }
}

class ProjectUserRevokeTextUi extends OutputWidget {
  const ProjectUserRevokeTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final unassigned = result['unassigned'];
    final names = unassigned is List<String>
        ? unassigned
        : unassigned is List
        ? [for (final name in unassigned) '$name']
        : const <String>[];
    final unassignAllRoles = result['unassignAllRoles'] == true;

    if (names.isEmpty) {
      return InfoTextWidget(
        unassignAllRoles
            ? 'The user has no access roles to revoke on the project.'
            : 'The user does not have any of the specified project roles.',
      );
    }

    return SuccessTextWidget(
      unassignAllRoles
          ? 'Revoked all access roles of the user from the project: ${names.join(', ')}'
          : 'Revoked access roles of the user from the project: ${names.join(', ')}',
      newParagraph: true,
    );
  }
}

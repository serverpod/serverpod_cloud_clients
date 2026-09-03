import 'package:ground_control_client/ground_control_client.dart'
    show Project, ProjectInfo;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminProjectListTextUi extends OutputWidget {
  final bool utc;

  AdminProjectListTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    final timezoneName = utc ? 'UTC' : 'local';
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<ProjectInfo>(
        columns: [
          TableColumnFormatter.forElement(
            'Project Id',
            getter: (project) => project.project.cloudProjectId,
          ),
          TableColumnFormatter.forElement(
            'Created At ($timezoneName)',
            getter: (project) => project.project.createdAt,
          ),
          TableColumnFormatter.forElement(
            'Archived At ($timezoneName)',
            getter: (project) => project.project.archivedAt,
          ),
          TableColumnFormatter.forElement(
            'Last Deploy Attempt',
            getter: (project) => project.latestDeployAttemptTime?.timestamp,
          ),
          TableColumnFormatter.forElement(
            'Owner',
            getter: (project) => project.project.owner?.user?.email,
          ),
          TableColumnFormatter.forElement(
            'Users',
            getter: (project) => _formatProjectUsers(project.project),
          ),
        ],
        utc: utc,
      ),
    );
  }
}

String _formatProjectUsers(Project project) {
  return project.roles
          ?.map((role) {
            final memberships = role.memberships;
            if (memberships == null) return '';

            final users = memberships
                .map((membership) => membership.user?.email)
                .nonNulls;
            if (users.isEmpty) return '';

            return '${role.name}: ${users.join(', ')}';
          })
          .join('; ') ??
      '';
}

class AdminProjectDeleteTextUi extends OutputWidget {
  const AdminProjectDeleteTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Deleted the project "${result['projectId']}".',
      newParagraph: true,
    );
  }
}

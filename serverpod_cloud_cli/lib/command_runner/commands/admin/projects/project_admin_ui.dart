import 'package:ground_control_client/ground_control_client.dart'
    show Project, ProjectInfo;
import 'package:serverpod_cloud_cli/util/output/output.dart';

class AdminProjectListUi extends OutputWidget {
  final bool utc;

  AdminProjectListUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: _AdminProjectListTextUi(utc: utc));
  }
}

class _AdminProjectListTextUi extends OutputWidget {
  final bool utc;

  _AdminProjectListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final timezoneName = utc ? 'UTC' : 'local';
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<ProjectInfo>(
        columns: [
          TableColumnFormatter.forElement(
            'Project Id',
            getter: (final project) => project.project.cloudProjectId,
          ),
          TableColumnFormatter.forElement(
            'Created At ($timezoneName)',
            getter: (final project) => project.project.createdAt,
          ),
          TableColumnFormatter.forElement(
            'Archived At ($timezoneName)',
            getter: (final project) => project.project.archivedAt,
          ),
          TableColumnFormatter.forElement(
            'Last Deploy Attempt',
            getter: (final project) =>
                project.latestDeployAttemptTime?.timestamp,
          ),
          TableColumnFormatter.forElement(
            'Owner',
            getter: (final project) => project.project.owner?.user?.email,
          ),
          TableColumnFormatter.forElement(
            'Users',
            getter: (final project) => _formatProjectUsers(project.project),
          ),
        ],
        utc: utc,
      ),
    );
  }
}

String _formatProjectUsers(final Project project) {
  return project.roles
          ?.map((final role) {
            final memberships = role.memberships;
            if (memberships == null) return '';

            final users = memberships
                .map((final membership) => membership.user?.email)
                .nonNulls;
            if (users.isEmpty) return '';

            return '${role.name}: ${users.join(', ')}';
          })
          .join('; ') ??
      '';
}

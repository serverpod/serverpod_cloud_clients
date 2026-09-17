import 'package:ground_control_client/ground_control_client.dart' show Project;
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_list_row.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminProjectListTextUi extends OutputWidget {
  final bool utc;
  final bool includeArchived;
  final bool includePaymentsStatus;

  AdminProjectListTextUi({
    required this.utc,
    required this.includeArchived,
    required this.includePaymentsStatus,
  });

  @override
  OutputWidget build(OutputContext context) {
    return FormattedStreamTableWidget(
      formatter: TextTableOutputFormatter<AdminProjectListRow>(
        columns: [
          TableColumnFormatter.forElement(
            'Project Id',
            getter: (row) => row.projectInfo.project.cloudProjectId,
          ),
          TableColumnFormatter.forTimestamp(
            'Created At',
            getter: (row) => row.projectInfo.project.createdAt,
          ),
          if (includeArchived)
            TableColumnFormatter.forTimestamp(
              'Archived At',
              getter: (row) => row.projectInfo.project.archivedAt,
            ),
          TableColumnFormatter.forTimestamp(
            'Last Deploy',
            getter: (row) => row.projectInfo.latestDeployAttemptTime?.timestamp,
          ),
          TableColumnFormatter.forElement(
            'Orb Subscription Id',
            getter: (row) => row.subscriptionId,
          ),
          if (includePaymentsStatus) ...[
            TableColumnFormatter.forElement(
              'Oldest Overdue',
              getter: (row) => row.oldestOverdueUnpaidAmount,
            ),
            TableColumnFormatter.forElement(
              'Oldest Overdue Date',
              getter: (row) => dueDateOnly(row.oldestOverdueUnpaidDueDate),
            ),
            TableColumnFormatter.forElement(
              'Newest Overdue',
              getter: (row) => row.newestOverdueUnpaidAmount,
            ),
            TableColumnFormatter.forElement(
              'Newest Overdue Date',
              getter: (row) => dueDateOnly(row.newestOverdueUnpaidDueDate),
            ),
            TableColumnFormatter.forElement(
              'Total Overdue',
              getter: (row) => row.totalAmountOverdue,
            ),
          ],
          TableColumnFormatter.forElement(
            'Owner',
            getter: (row) => row.projectInfo.project.owner?.user?.email,
          ),
          TableColumnFormatter.forElement(
            'Users',
            getter: (row) => _formatProjectUsers(row.projectInfo.project),
          ),
        ],
        utc: utc,
      ),
      columnMinWidths: [
        32,
        19,
        if (includeArchived) 19,
        19,
        19,
        if (includePaymentsStatus) ...[8, 10, 8, 10, 8],
        33,
        33,
      ],
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

class AdminProjectChangeOwnerTextUi extends OutputWidget {
  const AdminProjectChangeOwnerTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Changed the owner of project "${result['projectId']}" '
      'to "${result['ownerEmail']}".',
      newParagraph: true,
    );
  }
}

class AdminProjectUpdatePlanTextUi extends OutputWidget {
  const AdminProjectUpdatePlanTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Updated the plan of project "${result['projectId']}" '
      'to "${result['planType']}".',
      newParagraph: true,
    );
  }
}

import 'package:ground_control_client/ground_control_client.dart'
    show ProjectInfo;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ProjectListTextUi extends OutputWidget {
  final bool utc;

  late final List<TableColumnFormatter<ProjectInfo>> _projectTableColumns;

  ProjectListTextUi({required this.utc, required final bool showArchived}) {
    _projectTableColumns = [
      TableColumnFormatter.forElement(
        'Project Id',
        getter: (final project) => project.project.cloudProjectId,
      ),
      TableColumnFormatter.forElement(
        'Created At',
        getter: (final project) => project.project.createdAt,
      ),
      TableColumnFormatter.forElement(
        'Last Deploy Attempt',
        getter: (final project) => project.latestDeployAttemptTime?.timestamp,
      ),
      if (showArchived)
        TableColumnFormatter.forElement(
          'Deleted At',
          getter: (final project) => project.project.archivedAt,
        ),
    ];
  }

  @override
  OutputWidget build(final OutputContext context) {
    final object = context.get<List<ProjectInfo>>();
    if (object.isEmpty) {
      return InfoTextWidget('No projects available.');
    } else {
      return FormattedTableWidget(
        formatter: TextTableOutputFormatter(
          columns: _projectTableColumns,
          utc: utc,
        ),
      );
    }
  }
}

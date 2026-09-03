import 'package:ground_control_client/ground_control_client.dart'
    show ProjectInfo;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ProjectListTextUi extends OutputWidget {
  final bool utc;

  late final List<TableColumnFormatter<ProjectInfo>> _projectTableColumns;

  ProjectListTextUi({required this.utc, required bool showArchived}) {
    _projectTableColumns = [
      TableColumnFormatter.forElement(
        'Project Id',
        getter: (project) => project.project.cloudProjectId,
      ),
      TableColumnFormatter.forElement(
        'Created At',
        getter: (project) => project.project.createdAt,
      ),
      TableColumnFormatter.forElement(
        'Last Deploy Attempt',
        getter: (project) => project.latestDeployAttemptTime?.timestamp,
      ),
      if (showArchived)
        TableColumnFormatter.forElement(
          'Deleted At',
          getter: (project) => project.project.archivedAt,
        ),
    ];
  }

  @override
  OutputWidget build(OutputContext context) {
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

class ProjectDeleteTextUi extends OutputWidget {
  const ProjectDeleteTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Deleted the project "${result['projectId']}".',
      newParagraph: true,
    );
  }
}

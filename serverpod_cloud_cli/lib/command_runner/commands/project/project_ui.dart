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

class ProjectCreateTextUi extends OutputWidget {
  final String planDisplayName;
  final bool includeSuccess;

  const ProjectCreateTextUi({
    required this.planDisplayName,
    this.includeSuccess = true,
  });

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      InfoTextWidget('On plan: $planDisplayName'),
      ProgressStreamWidget<Map<String, Object?>>(
        initialMessage: 'Registering Serverpod Cloud project',
        successMessage: 'Project registration successful.',
        newParagraph: true,
      ),
      if (includeSuccess)
        const SuccessTextWidget(
          'Serverpod Cloud project created.',
          newParagraph: true,
        ),
    ]);
  }
}

class ProjectCreateDatabaseTextUi extends OutputWidget {
  const ProjectCreateDatabaseTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      ProgressStreamWidget<Map<String, Object?>>(
        initialMessage: 'Requesting database creation',
        successMessage: 'Database creation request sent.',
      ),
      const SuccessTextWidget(
        'Serverpod Cloud project created.',
        newParagraph: true,
      ),
    ]);
  }
}

class ProjectLinkTextUi extends OutputWidget {
  const ProjectLinkTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      ProgressStreamWidget<Map<String, Object?>>(
        initialMessage: 'Writing cloud configuration files',
        successMessage: 'Configuration files written.',
      ),
      const SuccessTextWidget(
        'Linked Serverpod Cloud project.',
        newParagraph: true,
      ),
    ]);
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

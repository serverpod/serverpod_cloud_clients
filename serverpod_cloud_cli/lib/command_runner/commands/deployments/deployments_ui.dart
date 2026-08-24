import 'package:serverpod_cloud_cli/util/output/output.dart';

class DeploymentListUi extends OutputWidget {
  final bool utc;

  DeploymentListUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: _DeploymentListTextUi(utc: utc));
  }
}

class _DeploymentListTextUi extends OutputWidget {
  final bool utc;

  _DeploymentListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final deployments = context.get<List<Map<String, Object?>>>();
    if (deployments.isEmpty) {
      return const CommandHintTextWidget(
        'No deployment status found. Run this command to deploy:',
        command: 'scloud deploy',
      );
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forKey('#', key: 'index'),
          TableColumnFormatter.forKey('Project', key: 'projectId'),
          TableColumnFormatter.forKey('Deploy Id', key: 'deployId'),
          TableColumnFormatter.forKey('Status', key: 'status'),
          TableColumnFormatter.forKey('Started', key: 'startedAt'),
          TableColumnFormatter.forKey('Finished', key: 'finishedAt'),
          TableColumnFormatter.forKey('Info', key: 'info'),
        ],
        utc: utc,
      ),
    );
  }
}

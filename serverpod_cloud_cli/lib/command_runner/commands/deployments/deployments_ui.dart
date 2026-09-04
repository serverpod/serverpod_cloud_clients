import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/constants.dart' show numTimeStampChars;
import 'package:serverpod_cloud_cli/util/common.dart';

class DeploymentListTextUi extends OutputWidget {
  final bool utc;
  final String baseCommand;

  DeploymentListTextUi({required this.utc, required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    final deployments = context.get<List<Map<String, Object?>>>();
    if (deployments.isEmpty) {
      return CommandHintTextWidget(
        'No deployment status found. Run this command to deploy:',
        command: '$baseCommand deploy',
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

class DeploymentShowTextUi extends OutputWidget {
  final bool utc;
  final bool overallStatus;

  const DeploymentShowTextUi({required this.utc, required this.overallStatus});

  @override
  OutputWidget build(final OutputContext context) {
    final snapshot = context.get<Map<String, Object?>>();
    final stages = snapshot['stages'] as List<DeployAttemptStage>;
    final startedAt = snapshot['startedAt'] as DateTime?;

    if (overallStatus) {
      return LineTextWidget(stages.last.stageStatus.name);
    }

    return OutputWidgetList([
      LineTextWidget(
        'Status of ${snapshot['projectId']} deployment ${snapshot['attemptId']}'
        ', started at ${startedAt?.toTzString(utc, numTimeStampChars)}:',
      ),
      const LineTextWidget(),
      for (final stage in stages)
        LineTextWidget(StatusCommands.statusLine(stage)),
    ]);
  }
}

class BuildSecretSetTextUi extends OutputWidget {
  const BuildSecretSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Successfully set build secret: ${result['name']}.',
    );
  }
}

class BuildSecretUnsetTextUi extends OutputWidget {
  const BuildSecretUnsetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Successfully removed build secret: ${result['name']}.',
    );
  }
}

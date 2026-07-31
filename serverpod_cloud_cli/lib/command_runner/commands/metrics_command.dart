import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show DateTimeOrDurationOption, ProjectIdOption;
import 'package:serverpod_cloud_cli/commands/metrics/metrics.dart';

import 'categories.dart';

const _defaultRange = MetricsRange.oneHour;

enum MetricsOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  target(
    EnumOption<MetricsTarget>(
      argName: 'target',
      argAbbrev: 't',
      helpText: 'Which metrics to show. When omitted, all are included.',
      enumParser: EnumParser(MetricsTarget.values),
    ),
  ),
  range(
    EnumOption<MetricsRange>(
      argName: 'range',
      argAbbrev: 'r',
      helpText:
          'The length of the time window to show, ending at --until. '
          'The sampling interval is chosen to suit the range.',
      defaultsTo: _defaultRange,
      enumParser: EnumParser(MetricsRange.values),
    ),
  ),
  until(
    DateTimeOrDurationOption(
      argName: 'until',
      argAbbrev: 'u',
      helpText:
          'End the time window at this point instead of now. Accepts an ISO '
          'date (e.g. "2026-01-15T10:30:00Z") or a duration back from now '
          '(e.g. "5m", "3h", "1d").',
    ),
  ),
  output(
    EnumOption<DataOutputFormat>(
      argName: 'output',
      argAbbrev: 'o',
      helpText: 'The format to render the output data in.',
      defaultsTo: DataOutputFormat.json,
      enumParser: EnumParser(DataOutputFormat.values),
    ),
  );

  const MetricsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudMetricsCommand extends CloudCliCommand<MetricsOption> {
  @override
  final name = 'metrics';

  @override
  final description = 'Show resource usage metrics for a project.';

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples => '''\n
Examples

  Show the last hour of all project metrics (the default range).

    \$ scloud metrics


  Show only the database signals.

    \$ scloud metrics --target db


  Show a longer range.

    \$ scloud metrics --range oneDay


  Show the hour that ended three hours ago.

    \$ scloud metrics --until 3h

''';

  CloudMetricsCommand({required super.logger})
    : super(options: MetricsOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<MetricsOption> commandConfig,
  ) async {
    await MetricsCommands.fetchMetrics(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(MetricsOption.projectId),
      target: commandConfig.optionalValue(MetricsOption.target),
      range: commandConfig.value(MetricsOption.range),
      until: commandConfig.optionalValue(MetricsOption.until),
    );
  }
}

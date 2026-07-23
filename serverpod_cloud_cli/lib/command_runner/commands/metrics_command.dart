import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show DateTimeOrDurationOption, ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/commands/metrics/metrics.dart';

import 'categories.dart';

const _defaultRange = MetricsRange.oneHour;

const _formatGroup = MutuallyExclusive('Output format');

enum MetricsOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  range(
    EnumOption<MetricsRange>(
      argName: 'range',
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
      helpText:
          'End the time window at this point instead of now. Accepts an ISO '
          'date (e.g. "2026-01-15T10:30:00Z") or a duration back from now '
          '(e.g. "5m", "3h", "1d").',
    ),
  ),
  table(
    FlagOption(
      argName: 'table',
      argAbbrev: 't',
      helpText: 'Render the metrics as a table. This is the default.',
      negatable: false,
      group: _formatGroup,
    ),
  ),
  raw(
    FlagOption(
      argName: 'raw',
      argAbbrev: 'r',
      helpText: 'Render the metrics as JSON, for machine consumption.',
      negatable: false,
      group: _formatGroup,
    ),
  ),
  utc(UtcOption());

  const MetricsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudMetricsCommand extends CloudCliCommand<MetricsOption> {
  @override
  final name = 'metrics';

  @override
  final description = 'Show CPU and memory usage per pod.';

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples => '''\n
Examples

  Show the last hour of pod metrics (the default range).

    \$ scloud metrics


  Show a longer range.

    \$ scloud metrics --range oneDay

    \$ scloud metrics --range oneWeek --utc


  Show the day that ended at a specific point in time.

    \$ scloud metrics --range oneDay --until 2026-01-15T10:30:00Z


  Show the hour that ended three hours ago.

    \$ scloud metrics --until 3h


  Emit JSON instead of a table.

    \$ scloud metrics --raw

''';

  CloudMetricsCommand({required super.logger})
    : super(options: MetricsOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<MetricsOption> commandConfig,
  ) async {
    final raw = commandConfig.optionalValue(MetricsOption.raw) ?? false;

    await MetricsCommands.fetchPodMetrics(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(MetricsOption.projectId),
      range: commandConfig.value(MetricsOption.range),
      until: commandConfig.optionalValue(MetricsOption.until),
      format: raw ? MetricsOutputFormat.json : MetricsOutputFormat.table,
      utc: commandConfig.value(MetricsOption.utc),
    );
  }
}

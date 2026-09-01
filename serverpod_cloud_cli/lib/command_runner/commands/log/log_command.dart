import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/logs_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show DateTimeOrDurationOption, ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

const _defaultLogLimit = 50;

enum LogOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  limit(
    IntOption(
      argName: 'limit',
      helpText: 'The maximum number of log records to fetch.',
      defaultsTo: _defaultLogLimit,
      min: 0,
    ),
  ),
  utc(UtcOption()),
  until(
    DateTimeOrDurationOption(
      argName: 'until',
      helpText:
          'Fetch records from before this timestamp. Accepts ISO date '
          '(e.g. "2024-01-15T10:30:00Z") or relative from now (e.g. "5m", "3h", "1d").',
    ),
  ),
  since(
    DateTimeOrDurationOption(
      argName: 'since',
      argPos: 0,
      helpText:
          'Fetch records from after this timestamp. Accepts ISO date '
          '(e.g. "2024-01-15T10:30:00Z") or relative from now (e.g. "5m", "3h", "1d").'
          ' Can also be specified as the first argument.',
    ),
  ),
  all(
    FlagOption(
      argName: 'all',
      helpText: 'Fetch all records (up to specified limit or server limit).',
      defaultsTo: false,
      negatable: false,
      hide: true,
    ),
  ),
  tail(
    FlagOption(
      argName: 'tail',
      helpText: 'Tail the log and get real time updates.',
      defaultsTo: false,
      negatable: false,
    ),
  );

  const LogOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudLogCommand extends CloudCliCommand<LogOption> {
  @override
  final name = 'log';

  @override
  final description = 'Fetch Serverpod Cloud logs.';

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples =>
      '''\n
Examples

  View the most recent logs (default limit is $_defaultLogLimit records).
  
    \$ $baseCommand log


  View the most recent logs with UTC timestamps and a custom limit.
  
    \$ $baseCommand log --utc --limit 100


  Stream logs in real-time.
  
    \$ $baseCommand log --tail


  View logs from the last hour using duration.
  
    \$ $baseCommand log 1h

    \$ $baseCommand log --since 1h


  View logs since a specific time using ISO date format:
  
    \$ $baseCommand log --since 2025-01-15T14:00:00Z

    \$ $baseCommand log --since "2025-01-15 14:00"

    \$ $baseCommand log --since 2025-01-15


  View logs in a time range using durations:
  
    \$ $baseCommand log --since 1h --until 5m


  View logs in a time range using ISO dates:
  
    \$ $baseCommand log --since 2025-01-15 --until 2025-01-16


  Mix ISO dates and durations:
  
    \$ $baseCommand log --since 2025-01-15T14:00:00Z --until 30m

''';

  CloudLogCommand({required super.logger}) : super(options: LogOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<LogOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(LogOption.projectId);
    final limit = commandConfig.value(LogOption.limit);
    final inUtc = commandConfig.value(LogOption.utc);
    var until = commandConfig.optionalValue(LogOption.until);
    var since = commandConfig.optionalValue(LogOption.since);
    final tailOpt = commandConfig.optionalValue(LogOption.tail);
    final internalAllOpt = commandConfig.value(LogOption.all);

    final anyTimeSpanIsSet = until != null || since != null;
    if (internalAllOpt) {
      if (anyTimeSpanIsSet) {
        logger.warning(
          'The --all option cannot be combined with --until or --since.',
        );
        until = null;
        since = null;
      }
    } else if (tailOpt == true) {
      if (anyTimeSpanIsSet) {
        logger.warning(
          'The --tail option cannot be combined with --until or --since.',
        );
      }
    } else if (until != null && since != null && until.isBefore(since)) {
      throw CloudCliUsageException(
        'The --until value must be after --since value.',
      );
    }

    final client = runner.serviceProvider.cloudApiClient;

    if (tailOpt == true) {
      try {
        logger.line(LogsUi.tailHeader(inUtc: inUtc));
        await LogsUi.writeLogStream(
          LogsOperations.tailContainerLog(
            client,
            projectId: projectId,
            limit: limit,
          ),
          writeln: logger.line,
          inUtc: inUtc,
          limit: limit,
        );
      } on Exception catch (e, s) {
        throw FailureException.nested(e, s, 'Error while tailing log records');
      }
      return;
    }

    try {
      logger.line(
        LogsUi.fetchHeader(after: since, before: until, inUtc: inUtc),
      );
      await LogsUi.writeLogStream(
        LogsOperations.fetchContainerLog(
          client,
          projectId: projectId,
          before: until,
          after: since,
          limit: limit,
        ),
        writeln: logger.line,
        inUtc: inUtc,
        limit: limit,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Error while fetching log records');
    }
  }
}

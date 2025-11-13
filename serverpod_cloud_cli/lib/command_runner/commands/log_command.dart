import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show DateTimeOrDurationOption, ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';

import 'categories.dart';

enum LogOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  limit(IntOption(
    argName: 'limit',
    helpText: 'The maximum number of log records to fetch.',
    defaultsTo: 50,
    min: 0,
  )),
  utc(UtcOption()),
  until(DateTimeOrDurationOption(
    argName: 'until',
    helpText: 'Fetch records from before this timestamp. Accepts ISO date '
        '(e.g. "2024-01-15T10:30:00Z") or relative from now (e.g. "5m", "3h", "1d"). '
        'Can also be specified as the first argument.',
  )),
  since(DateTimeOrDurationOption(
    argName: 'since',
    argPos: 0,
    helpText: 'Fetch records from after this timestamp. Accepts ISO date '
        '(e.g. "2024-01-15T10:30:00Z") or relative from now (e.g. "5m", "3h", "1d").',
  )),
  all(FlagOption(
    argName: 'all',
    helpText: 'Fetch all records (up to specified limit or server limit).',
    defaultsTo: false,
    negatable: false,
    hide: true,
  )),
  tail(FlagOption(
    argName: 'tail',
    helpText: 'Tail the log and get real time updates.',
    negatable: false,
    defaultsTo: false,
  ));

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
  String get usageExamples => '''\n
Examples

  View the most recent logs (default: last 10 minutes).
  
    \$ scloud log


  View logs from the last hour using duration.
  
    \$ scloud log 1h

    \$ scloud log --since 1h


  View logs since a specific time using ISO date format:
  
    \$ scloud log --since 2025-01-15T14:00:00Z

    \$ scloud log --since "2025-01-15 14:00"

    \$ scloud log --since 2025-01-15


  View logs in a time range using durations:
  
    \$ scloud log --since 1h --until 5m


  View logs in a time range using ISO dates:
  
    \$ scloud log --since 2025-01-15 --until 2025-01-16


  Mix ISO dates and durations:
  
    \$ scloud log --since 2025-01-15T14:00:00Z --until 30m


  Stream logs in real-time.
  
    \$ scloud log --tail


  View logs with UTC timestamps and a custom limit.
  
    \$ scloud log --utc --limit 100

''';

  CloudLogCommand({required super.logger}) : super(options: LogOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<LogOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(LogOption.projectId);
    final limit = commandConfig.value(LogOption.limit);
    final inUtc = commandConfig.value(LogOption.utc);
    final until = commandConfig.optionalValue(LogOption.until);
    final since = commandConfig.optionalValue(LogOption.since);
    final tailOpt = commandConfig.optionalValue(LogOption.tail);
    final internalAllOpt = commandConfig.value(LogOption.all);

    DateTime? defaultSince;
    final anyTimeSpanIsSet = until != null || since != null;
    if (internalAllOpt) {
      if (anyTimeSpanIsSet) {
        throw CloudCliUsageException(
          'The --all option cannot be combined with --until or --since.',
        );
      }
    } else if (tailOpt == true) {
      if (anyTimeSpanIsSet) {
        throw CloudCliUsageException(
          'The --tail option cannot be combined with --until or --since.',
        );
      }
    } else if (until != null || since != null) {
      if (until != null && since != null && until.isBefore(since)) {
        throw CloudCliUsageException(
          'The --until value must be after --since value.',
        );
      }
    } else if (until == null && since == null) {
      defaultSince = DateTime.now().subtract(Duration(minutes: 10));
    }

    if (tailOpt == true) {
      try {
        await LogsFeature.tailContainerLog(
          runner.serviceProvider.cloudApiClient,
          writeln: logger.line,
          projectId: projectId,
          limit: limit,
          inUtc: inUtc,
        );
      } on Exception catch (e, s) {
        throw FailureException.nested(e, s, 'Error while tailing log records');
      }

      return;
    }

    try {
      await LogsFeature.fetchContainerLog(
        runner.serviceProvider.cloudApiClient,
        writeln: logger.line,
        projectId: projectId,
        before: until,
        after: since ?? defaultSince,
        limit: limit,
        inUtc: inUtc,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Error while fetching log records');
    }
  }
}

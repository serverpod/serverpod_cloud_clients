import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
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
  recent(DurationOption(
    argName: 'recent',
    argAbbrev: 'r',
    argPos: 0,
    helpText:
        'Fetch records from the recent period length; s (seconds) by default. '
        'Can also be specified as the first argument.',
    min: Duration.zero,
  )),
  until(DateTimeOption(
    argName: 'until',
    helpText: 'Fetch records from before this timestamp.',
  )),
  since(DateTimeOption(
    argName: 'since',
    helpText: 'Fetch records from after this timestamp.',
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


  View logs from the last hour.
  
    \$ scloud log 1h


  View logs since a specific time, you can use the following formats:
  
    \$ scloud log --since 2025-01-15T14:00:00Z

    \$ scloud log --since "2025-01-15 14:00"

    \$ scloud log --since 2025-01-15

  View logs in a time range.
  
    \$ scloud log --since 2025-01-15 --until 2025-01-16


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
    final recentOpt = commandConfig.optionalValue(LogOption.recent);
    final untilOpt = commandConfig.optionalValue(LogOption.until);
    final sinceOpt = commandConfig.optionalValue(LogOption.since);
    final tailOpt = commandConfig.optionalValue(LogOption.tail);
    final internalAllOpt = commandConfig.value(LogOption.all);

    final DateTime? before, after;
    final anyTimeSpanIsSet =
        recentOpt != null || untilOpt != null || sinceOpt != null;
    if (internalAllOpt) {
      if (anyTimeSpanIsSet) {
        throw CloudCliUsageException(
          'The --all option cannot be combined with '
          '--until, --since, or --recent.',
        );
      }

      before = null;
      after = null;
    } else if (tailOpt == true) {
      if (anyTimeSpanIsSet) {
        throw CloudCliUsageException(
          'The --tail option cannot be combined with '
          '--until, --since, or --recent.',
        );
      }

      before = null;
      after = null;
    } else if (untilOpt != null || sinceOpt != null) {
      if (recentOpt != null) {
        throw CloudCliUsageException(
          'The --recent option cannot be combined with '
          '--until or --since.',
        );
      }

      before = untilOpt;
      after = sinceOpt;
      if (before != null && after != null && before.isBefore(after)) {
        throw CloudCliUsageException(
          'The --until value must be after --since value.',
        );
      }
    } else {
      // If no range specified, default to fetch recent logs
      before = null;
      after = DateTime.now().subtract(recentOpt ?? Duration(minutes: 10));
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
        before: before,
        after: after,
        limit: limit,
        inUtc: inUtc,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Error while fetching log records');
    }
  }
}

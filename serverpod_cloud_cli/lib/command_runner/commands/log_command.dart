import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/config/config.dart';

import 'categories.dart';

enum LogOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  limit(IntOption(
    argName: 'limit',
    helpText: 'The maximum number of log records to fetch.',
    defaultsTo: 50,
    min: 0,
  )),
  utc(FlagOption(
    argName: 'utc',
    argAbbrev: 'u',
    helpText: 'Display timestamps in UTC timezone instead of local.',
    defaultsTo: false,
    envName: 'SERVERPOD_CLOUD_DISPLAY_UTC',
  )),
  recent(DurationOption(
    argName: 'recent',
    argAbbrev: 'r',
    argPos: 0,
    helpText:
        'Fetch records from the recent period length; s (seconds) by default. '
        'Can also be specified as the first argument.',
    min: Duration.zero,
  )),
  before(DateTimeOption(
    argName: 'before',
    helpText: 'Fetch records from before this timestamp.',
  )),
  after(DateTimeOption(
    argName: 'after',
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
  String get category => CommandCategories.observe;

  CloudLogCommand({required super.logger}) : super(options: LogOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<LogOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(LogOption.projectId);
    final limit = commandConfig.value(LogOption.limit);
    final inUtc = commandConfig.value(LogOption.utc);
    final recentOpt = commandConfig.optionalValue(LogOption.recent);
    final beforeOpt = commandConfig.optionalValue(LogOption.before);
    final afterOpt = commandConfig.optionalValue(LogOption.after);
    final tailOpt = commandConfig.optionalValue(LogOption.tail);
    final internalAllOpt = commandConfig.value(LogOption.all);

    final DateTime? before, after;
    final anyTimeSpanIsSet =
        recentOpt != null || beforeOpt != null || afterOpt != null;
    if (internalAllOpt) {
      if (anyTimeSpanIsSet) {
        throw CloudCliUsageException(
          'The --all option cannot be combined with '
          '--before, --after, or --recent.',
        );
      }

      before = null;
      after = null;
    } else if (tailOpt == true) {
      if (anyTimeSpanIsSet) {
        throw CloudCliUsageException(
          'The --tail option cannot be combined with '
          '--before, --after, or --recent.',
        );
      }

      before = null;
      after = null;
    } else if (beforeOpt != null || afterOpt != null) {
      if (recentOpt != null) {
        throw CloudCliUsageException(
          'The --recent option cannot be combined with '
          '--before or --after.',
        );
      }

      before = beforeOpt;
      after = afterOpt;
      if (before != null && after != null && before.isBefore(after)) {
        throw CloudCliUsageException(
          'The --before value must be after --after value.',
        );
      }
    } else {
      // If no range specified, default to fetch recent logs
      before = null;
      after = DateTime.now().subtract(recentOpt ?? Duration(minutes: 10));
    }

    if (tailOpt == true) {
      await handleCommonClientExceptions(logger, () async {
        await LogsFeature.tailContainerLog(
          runner.serviceProvider.cloudApiClient,
          writeln: logger.line,
          projectId: projectId,
          limit: limit,
          inUtc: inUtc,
        );
      }, (final e) {
        logger.error('Error while tailing log records', exception: e);
        throw ErrorExitException();
      });

      return;
    }

    await handleCommonClientExceptions(logger, () async {
      await LogsFeature.fetchContainerLog(
        runner.serviceProvider.cloudApiClient,
        writeln: logger.line,
        projectId: projectId,
        before: before,
        after: after,
        limit: limit,
        inUtc: inUtc,
      );
    }, (final e) {
      logger.error('Error while fetching log records', exception: e);
      throw ErrorExitException();
    });
  }
}

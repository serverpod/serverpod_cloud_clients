import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/option_parsing.dart';
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';

enum LogOption implements OptionDefinition {
  projectId(ProjectIdOption()),
  limit(ConfigOption(
    argName: 'limit',
    helpText: 'The maximum number of log records to fetch.',
    defaultsTo: '50',
  )),
  utc(ConfigOption(
    argName: 'utc',
    argAbbrev: 'u',
    helpText: 'Display timestamps in UTC timezone instead of local.',
    isFlag: true,
    defaultsTo: "false",
    envName: 'SERVERPOD_CLOUD_DISPLAY_UTC',
  )),
  recent(ConfigOption(
    argName: 'recent',
    argAbbrev: 'r',
    helpText:
        'Fetch records from the recent period length; s (seconds) by default. '
        'Can also be specified as the first argument.',
    valueHelp: '<integer>[s|m|h|d]',
    argPos: 0,
  )),
  before(ConfigOption(
    argName: 'before',
    helpText: 'Fetch records from before this timestamp.',
    valueHelp: 'YYYY-MM-DDtHH:MM:SSz',
  )),
  after(ConfigOption(
    argName: 'after',
    helpText: 'Fetch records from after this timestamp.',
    valueHelp: 'YYYY-MM-DDtHH:MM:SSz',
  )),
  all(ConfigOption(
    argName: 'all',
    helpText: 'Fetch all records (up to specified limit or server limit).',
    isFlag: true,
    defaultsTo: 'false',
    hide: true,
  )),
  tail(ConfigOption(
    argName: 'tail',
    helpText: 'Tail the log and get real time updates.',
    isFlag: true,
    negatable: false,
    defaultsTo: 'false',
  ));

  const LogOption(this.option);

  @override
  final ConfigOption option;
}

class CloudLogCommand extends CloudCliCommand<LogOption> {
  @override
  final name = 'log';

  @override
  final description = 'Fetch Serverpod Cloud logs.';

  CloudLogCommand({required super.logger}) : super(options: LogOption.values);

  static DateTime _parseRecentOpt(final String recentOpt) {
    const pattern = r'^(\d+)([smhd])?$';
    final regex = RegExp(pattern);
    final match = regex.firstMatch(recentOpt);

    if (match == null || match.groupCount != 2) {
      throw CloudCliUsageException(
        'Failed to parse --recent value "$recentOpt", the required pattern is <integer>[s|m|h|d]',
      );
    }
    final valueStr = match.group(1);
    final unit = match.group(2) ?? 's';
    final value = int.parse(valueStr ?? '');
    final now = DateTime.now();
    switch (unit) {
      case 's':
        return now.subtract(Duration(seconds: value));
      case 'm':
        return now.subtract(Duration(minutes: value));
      case 'h':
        return now.subtract(Duration(hours: value));
      case 'd':
        return now.subtract(Duration(days: value));
      default:
        throw CloudCliUsageException(
            'Failed to parse --recent option, invalid unit "$unit".');
    }
  }

  @override
  Future<void> runWithConfig(
    final Configuration<LogOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(LogOption.projectId);
    final limit = int.tryParse(commandConfig.value(LogOption.limit));
    final inUtc = commandConfig.flag(LogOption.utc);
    final recentOpt = commandConfig.valueOrNull(LogOption.recent);
    final beforeOpt = commandConfig.valueOrNull(LogOption.before);
    final afterOpt = commandConfig.valueOrNull(LogOption.after);
    final tailOpt = commandConfig.flagOrNull(LogOption.tail);
    final internalAllOpt = commandConfig.flag(LogOption.all);

    if (limit == null) {
      throw CloudCliUsageException(
        'The --limit value must be an integer.',
      );
    }

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

      before = beforeOpt != null ? OptionParsing.parseDate(beforeOpt) : null;
      after = afterOpt != null ? OptionParsing.parseDate(afterOpt) : null;
      if (before != null && after != null && before.isBefore(after)) {
        throw CloudCliUsageException(
          'The --before value must be after --after value.',
        );
      }
    } else {
      // If no range specified, default to fetch recent logs
      before = null;
      after = _parseRecentOpt(recentOpt ?? '1m');
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
        logger.error('Error while tailing log records: $e');
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
      logger.error('Error while fetching log records: $e');
      throw ErrorExitException();
    });
  }
}

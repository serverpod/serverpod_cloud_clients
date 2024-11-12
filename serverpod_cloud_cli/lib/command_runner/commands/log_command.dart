import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/option_parsing.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

abstract final class _LogOptions {
  static const projectId = ConfigOption(
    argName: 'project-id',
    argAbbrev: 'i',
    argPos: 0,
    helpText:
        'The ID of the project. Can also be specified as the first argument.',
    mandatory: true,
    envName: 'SERVERPOD_CLOUD_PROJECT_ID',
  );
  static const limit = ConfigOption(
    argName: 'limit',
    argAbbrev: 'l',
    helpText: 'The maximum number of log records to fetch.',
    defaultsTo: '50',
  );
  static const utc = ConfigOption(
    argName: 'utc',
    argAbbrev: 'u',
    helpText: 'Display timestamps in UTC timezone instead of local.',
    isFlag: true,
    defaultsTo: "false",
    envName: 'SERVERPOD_CLOUD_DISPLAY_UTC',
  );

  static const recent = ConfigOption(
    argName: 'recent',
    argAbbrev: 'r',
    argPos: 1,
    helpText:
        'Fetch records from the recent period length; s (seconds) by default.',
    valueHelp: '<integer>[s|m|h|d]',
  );
  static const before = ConfigOption(
      argName: 'before',
      argAbbrev: 'b',
      helpText: 'Fetch records from before this timestamp.',
      valueHelp: 'YYYY-MM-DDttHH:MM:SSz');
  static const after = ConfigOption(
      argName: 'after',
      argAbbrev: 'a',
      helpText: 'Fetch records from after this timestamp.',
      valueHelp: 'YYYY-MM-DDttHH:MM:SSz');
  static const all = ConfigOption(
    argName: 'all',
    helpText: 'Fetch all records (up to specified limit or server limit).',
    isFlag: true,
    defaultsTo: 'false',
    hide: true,
  );
}

class CloudLogCommand extends CloudCliCommand {
  @override
  final name = 'log';

  @override
  final description = 'Fetch Serverpod Cloud tenant logs.';

  CloudLogCommand({required super.logger}) {
    // Subcommands
    addSubcommand(CloudLogRangeCommand(logger: logger));
    addSubcommand(CloudLogTailCommand(logger: logger));
  }
}

enum LogGetOption implements OptionDefinition {
  projectId(_LogOptions.projectId),
  limit(_LogOptions.limit),
  utc(_LogOptions.utc),
  recent(_LogOptions.recent),
  before(_LogOptions.before),
  after(_LogOptions.after),
  all(_LogOptions.all);

  const LogGetOption(this.option);

  @override
  final ConfigOption option;
}

class CloudLogRangeCommand extends CloudCliCommand<LogGetOption> {
  @override
  String get description => 'Get logs within a time range.';

  @override
  String get name => 'get';

  CloudLogRangeCommand({required super.logger})
      : super(options: LogGetOption.values);

  /// Parses the --recent option and returns the 'after' timestamp to use.
  static DateTime _parseRecentOpt(final String recentOpt) {
    const pattern = r'^(\d+)([smhd])?$';
    final regex = RegExp(pattern);
    final match = regex.firstMatch(recentOpt);

    if (match == null || match.groupCount != 2) {
      throw ArgumentError(
          'Failed to parse --recent value ($recentOpt), the required pattern is <integer>[s|m|h|d]');
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
        throw ArgumentError(
            'Failed to parse --recent option, invalid unit "$unit".');
    }
  }

  @override
  Future<void> runWithConfig(
      final Configuration<LogGetOption> commandConfig) async {
    final projectId = commandConfig.value(LogGetOption.projectId);
    final limit = int.tryParse(commandConfig.value(LogGetOption.limit));
    final inUtc = commandConfig.flag(LogGetOption.utc);
    final recentOpt = commandConfig.valueOrNull(LogGetOption.recent);
    final beforeOpt = commandConfig.valueOrNull(LogGetOption.before);
    final afterOpt = commandConfig.valueOrNull(LogGetOption.after);

    if (limit == null) {
      throw ArgumentError('Value must be an integer.', '--limit');
    }

    final DateTime? before, after;
    if (commandConfig.flag(LogGetOption.all)) {
      if (recentOpt != null || beforeOpt != null || afterOpt != null) {
        throw ArgumentError('The --all option cannot be combined with '
            '--before, --after, or --recent.');
      }
      before = null;
      after = null;
    } else if (beforeOpt != null || afterOpt != null) {
      if (recentOpt != null) {
        throw ArgumentError('The --recent option cannot be combined with '
            '--before or --after.');
      }
      before = beforeOpt != null ? OptionParsing.parseDate(beforeOpt) : null;
      after = afterOpt != null ? OptionParsing.parseDate(afterOpt) : null;
    } else {
      // if no range specified, default to fetch recent logs
      before = null;
      after = _parseRecentOpt(recentOpt ?? '1m');
    }

    final timezoneName =
        inUtc ? 'UTC' : 'local (${DateTime.now().timeZoneName})';
    logger.info('Fetching logs from ${after?.toTzString(inUtc) ?? 'oldest'} '
        'to ${before?.toTzString(inUtc) ?? 'newest'}. Display time zone: $timezoneName.');

    final Stream<LogRecord> recordStream;
    try {
      recordStream = runner.serviceProvider.cloudApiClient.logs.fetchRecords(
        canonicalName: projectId,
        beforeTime: before,
        afterTime: after,
        limit: limit,
      );
      await _outputLogStream(
        logger.info,
        recordStream,
        limit: limit,
        inUtc: inUtc,
      );
    } catch (e) {
      logger.error('Failed to fetch log records: $e');
      throw ExitException();
    }
  }
}

enum LogTailOption implements OptionDefinition {
  projectId(_LogOptions.projectId),
  limit(_LogOptions.limit),
  utc(_LogOptions.utc);

  const LogTailOption(this.option);

  @override
  final ConfigOption option;
}

class CloudLogTailCommand extends CloudCliCommand<LogTailOption> {
  @override
  String get description => 'Tail logs.';

  @override
  String get name => 'tail';

  CloudLogTailCommand({required super.logger})
      : super(options: LogTailOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<LogTailOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(LogTailOption.projectId);
    final limit = int.tryParse(commandConfig.value(LogTailOption.limit));
    final inUtc = commandConfig.flag(LogTailOption.utc);

    if (limit == null) {
      throw ArgumentError('Value must be an integer.', '--limit');
    }

    final timezoneName =
        inUtc ? 'UTC' : 'local (${DateTime.now().timeZoneName})';
    logger.info('Tailing logs. Display time zone: $timezoneName.');

    final Stream<LogRecord> recordStream;
    try {
      recordStream = runner.serviceProvider.cloudApiClient.logs.tailRecords(
        canonicalName: projectId,
        limit: limit,
      );
      await _outputLogStream(
        logger.info,
        recordStream,
        limit: limit,
        inUtc: inUtc,
      );
    } catch (e) {
      logger.error('Failed to tail log records: $e');
      throw ExitException();
    }
  }
}

Future<void> _outputLogStream(
  final void Function(String) output,
  final Stream<LogRecord> recordStream, {
  required final int limit,
  final bool inUtc = false,
}) async {
  var count = 0;
  final tablePrinter = _createLogTablePrinter();
  final tableStream = tablePrinter.toStream(recordStream.map(
    (final rec) {
      count++;
      return _toLogTableRow(rec, inUtc: inUtc);
    },
  ));
  await for (final line in tableStream) {
    output(line.trimRight());
  }
  output('-- End of log stream -- $count records (limit $limit) --');
}

TablePrinter _createLogTablePrinter() {
  final tablePrinter = TablePrinter(
    headers: ['Timestamp', 'Level', 'Content'],
    columnMinWidths: [27, 7, 0],
  );
  return tablePrinter;
}

List<String> _toLogTableRow(
  final LogRecord rec, {
  final bool inUtc = false,
}) {
  return [
    rec.timestamp.toTzString(inUtc),
    rec.severity ?? '',
    rec.content,
  ];
}

extension _TimezonedString on DateTime {
  /// Converts this date-time to a string in either local or UTC time zone.
  String toTzString(final bool inUtc) =>
      inUtc ? toUtc().toString() : toLocal().toString();
}

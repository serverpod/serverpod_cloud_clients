import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

final _logRecordTableColumns = [
  TableColumnFormatter<LogRecord>.forElement(
    'Timestamp',
    getter: (record) => record.timestamp,
  ),
  TableColumnFormatter<LogRecord>.forElement(
    'Level',
    getter: (record) => record.severity,
  ),
  TableColumnFormatter<LogRecord>.forElement(
    'Content',
    getter: (record) => record.content,
  ),
];

class LogListTextUi extends OutputWidget {
  final bool utc;

  const LogListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final records = context.get<List<LogRecord>>();
    if (records.isEmpty) {
      return const InfoTextWidget('No log records found.');
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<LogRecord>(
        columns: _logRecordTableColumns,
        utc: utc,
      ),
    );
  }
}

class LogTailTextUi extends OutputWidget {
  final bool utc;
  final int? limit;

  const LogTailTextUi({required this.utc, this.limit});

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      LineTextWidget('Tailing logs. Display time zone: ${_timezoneName(utc)}.'),
      FormattedStreamTableWidget(
        formatter: TextTableOutputFormatter<LogRecord>(
          columns: _logRecordTableColumns,
          utc: utc,
        ),
        columnMinWidths: const [20, 7, 0],
        footerLines: (count) => [
          '-- End of log stream --'
              ' $count records ${limit != null ? '(limit $limit)' : ''} --',
          if (limit != null && count == limit)
            '   (Use the --limit option to increase the limit.)',
        ],
      ),
    ]);
  }
}

String _timezoneName(final bool utc) {
  return utc ? 'UTC' : 'local (${DateTime.now().timeZoneName})';
}

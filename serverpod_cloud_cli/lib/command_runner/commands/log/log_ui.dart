import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart'
    show LogPayload;

List<TableColumnFormatter<LogRecord>> _logRecordTableColumns({
  required final bool raw,
}) {
  return [
    TableColumnFormatter<LogRecord>.forTimestamp(
      'Timestamp',
      getter: (record) => record.timestamp,
    ),
    TableColumnFormatter<LogRecord>.forElement('Level', getter: logLevelOf),
    TableColumnFormatter<LogRecord>.forElement(
      'Content',
      getter: (record) =>
          raw ? record.content : summarizeLogContent(record.content),
    ),
  ];
}

String logLevelOf(final LogRecord record) {
  final severity = record.severity;
  if (severity != null && severity.isNotEmpty) return severity;

  return LogPayload.parse(record.content).logLevel ?? '';
}

String summarizeLogContent(final String content) {
  final payload = LogPayload.parse(content);
  if (!payload.isStructured) return content;

  final parts = <String>[
    if (payload.sessionLogId case final int sessionLogId)
      'session=$sessionLogId',
    if (payload.headline case final String headline) _singleLine(headline),
    for (final field in payload.fields.entries)
      '${field.key}=${_singleLine(LogPayload.formatValue(field.value))}',
  ];

  return parts.isEmpty ? content : parts.join('  ');
}

String _singleLine(final String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Returns the record as a map for structured output.
/// A JSON object or list in [LogRecord.content] is emitted as a value,
/// not as a string, unless [raw] is set.
Map<String, Object?> structuredLogRecord(
  final LogRecord record, {
  required final bool raw,
}) {
  final json = record.toJson();
  if (raw) return json;

  final decoded = LogPayload.decode(record.content);
  if (decoded is Map || decoded is List) {
    json['content'] = decoded;
  }
  return json;
}

class _StructuredLogRecordFormatter extends OutputFormatter<LogRecord, String> {
  final OutputFormatter<Object, String> formatter;
  final bool raw;

  const _StructuredLogRecordFormatter({
    required this.formatter,
    required this.raw,
  }) : super(utc: true);

  @override
  String format(final LogRecord record) {
    return formatter.format(structuredLogRecord(record, raw: raw));
  }
}

class LogListStructuredUi extends OutputWidget {
  final OutputFormatter<Object, String> formatter;
  final bool raw;

  const LogListStructuredUi({required this.formatter, this.raw = false});

  @override
  OutputWidget build(final OutputContext context) {
    final records = context.get<List<LogRecord>>();
    return RawStringWidget(
      formatter.format([
        for (final record in records) structuredLogRecord(record, raw: raw),
      ]),
    );
  }
}

class LogTailStructuredUi extends OutputWidget {
  final OutputFormatter<Object, String> formatter;
  final bool raw;

  const LogTailStructuredUi({required this.formatter, this.raw = false});

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedStreamStringWidget<LogRecord>(
      formatter: _StructuredLogRecordFormatter(formatter: formatter, raw: raw),
    );
  }
}

final _buildLogRecordTableColumns = [
  TableColumnFormatter<LogRecord>(
    'Timestamp',
    formatter: (record, {required bool? utc}) =>
        record.timestamp.toTzString(utc ?? false),
    isTimestamp: true,
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

class BuildLogListTextUi extends OutputWidget {
  final bool utc;
  final UuidValue attemptId;

  const BuildLogListTextUi({required this.utc, required this.attemptId});

  @override
  OutputWidget build(final OutputContext context) {
    final records = context.get<List<LogRecord>>();
    if (records.isEmpty) {
      return const InfoTextWidget('No log records found.');
    }
    return OutputWidgetList([
      LineTextWidget(
        'Fetching build logs for deploy id $attemptId. '
        'Display time zone: ${_timezoneName(utc)}.',
      ),
      FormattedTableWidget(
        formatter: TextTableOutputFormatter<LogRecord>(
          columns: _buildLogRecordTableColumns,
          utc: utc,
        ),
        columnMinWidths: const [27, 7, 0],
      ),
      LineTextWidget('-- End of log stream -- ${records.length} records --'),
    ]);
  }
}

class LogListTextUi extends OutputWidget {
  final bool utc;
  final bool raw;

  const LogListTextUi({required this.utc, this.raw = false});

  @override
  OutputWidget build(final OutputContext context) {
    final records = context.get<List<LogRecord>>();
    if (records.isEmpty) {
      return const InfoTextWidget('No log records found.');
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<LogRecord>(
        columns: _logRecordTableColumns(raw: raw),
        utc: utc,
      ),
    );
  }
}

class LogTailTextUi extends OutputWidget {
  final bool utc;
  final bool raw;
  final int? limit;

  const LogTailTextUi({required this.utc, this.raw = false, this.limit});

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      LineTextWidget('Tailing logs. Display time zone: ${_timezoneName(utc)}.'),
      FormattedStreamTableWidget(
        formatter: TextTableOutputFormatter<LogRecord>(
          columns: _logRecordTableColumns(raw: raw),
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

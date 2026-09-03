import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class LogsUi {
  static String fetchHeader({
    required final DateTime? after,
    required final DateTime? before,
    required final bool inUtc,
  }) {
    return 'Fetching logs from ${after?.toTzString(inUtc) ?? 'oldest'} '
        'to ${before?.toTzString(inUtc) ?? 'newest'}. '
        'Display time zone: ${_timezoneName(inUtc)}.';
  }

  static String tailHeader({required final bool inUtc}) {
    return 'Tailing logs. Display time zone: ${_timezoneName(inUtc)}.';
  }

  static String buildLogHeader({
    required final UuidValue attemptId,
    required final bool inUtc,
  }) {
    return 'Fetching build logs for deploy id $attemptId. '
        'Display time zone: ${_timezoneName(inUtc)}.';
  }

  static Future<void> writeLogStream(
    final Stream<LogRecord> recordStream, {
    required final void Function(String) writeln,
    required final bool inUtc,
    final int? limit,
  }) async {
    var count = 0;
    final tablePrinter = TablePrinter(
      headers: ['Timestamp', 'Level', 'Content'],
      columnMinWidths: [27, 7, 0],
    );
    final tableStream = tablePrinter.toStream(
      recordStream.map((final rec) {
        count++;
        return [
          rec.timestamp.toTzString(inUtc),
          rec.severity ?? '',
          rec.content,
        ];
      }),
    );
    try {
      await for (final line in tableStream) {
        writeln(line.trimRight());
      }
    } finally {
      writeln(
        '-- End of log stream --'
        ' $count records ${limit != null ? '(limit $limit)' : ''} --',
      );
      if (count == limit) {
        writeln('   (Use the --limit option to increase the limit.)');
      }
    }
  }

  static String _timezoneName(final bool inUtc) {
    return inUtc ? 'UTC' : 'local (${DateTime.now().timeZoneName})';
  }
}

import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

abstract class LogsFeature {
  static Future<void> fetchContainerLog(
    final Client cloudApiClient, {
    required final void Function(String) writeln,
    required final String projectId,
    required final DateTime? before,
    required final DateTime? after,
    required final int limit,
    required final bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    writeln(
      'Fetching logs from ${after?.toTzString(inUtc) ?? 'oldest'} '
      'to ${before?.toTzString(inUtc) ?? 'newest'}. Display time zone: $timezoneName.',
    );

    final Stream<LogRecord> recordStream;
    if (before == null && after == null) {
      recordStream = cloudApiClient.logs.fetchRecentRecords(
        cloudCapsuleId: projectId,
        limit: limit,
      );
    } else {
      recordStream = cloudApiClient.logs.fetchRecords(
        cloudCapsuleId: projectId,
        beforeTime: before,
        afterTime: after,
        limit: limit,
      );
    }

    await _outputLogStream(writeln, recordStream, limit: limit, inUtc: inUtc);
  }

  static Future<void> tailContainerLog(
    final Client cloudApiClient, {
    required final void Function(String) writeln,
    required final String projectId,
    required final int limit,
    required final bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    writeln('Tailing logs. Display time zone: $timezoneName.');

    final recordStream = cloudApiClient.logs.tailRecords(
      cloudCapsuleId: projectId,
      limit: limit,
    );
    await LogsFeature._outputLogStream(
      writeln,
      recordStream,
      limit: limit,
      inUtc: inUtc,
    );
  }

  static Future<void> fetchBuildLog(
    final Client cloudApiClient, {
    required final void Function(String) writeln,
    required final String projectId,
    required final String attemptId,
    required final bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    writeln(
      'Fetching build logs for deploy id $attemptId. Display time zone: $timezoneName.',
    );

    final recordStream = cloudApiClient.logs.fetchBuildLog(
      cloudCapsuleId: projectId,
      attemptId: attemptId,
    );
    await _outputLogStream(writeln, recordStream, inUtc: inUtc);
  }

  static Future<void> _outputLogStream(
    final void Function(String) writeln,
    final Stream<LogRecord> recordStream, {
    final int? limit,
    required final bool inUtc,
  }) async {
    var count = 0;
    final tablePrinter = _createLogTablePrinter();
    final tableStream = tablePrinter.toStream(
      recordStream.map((final rec) {
        count++;
        return _toLogTableRow(rec, inUtc: inUtc);
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

  static TablePrinter _createLogTablePrinter() {
    final tablePrinter = TablePrinter(
      headers: ['Timestamp', 'Level', 'Content'],
      columnMinWidths: [27, 7, 0],
    );
    return tablePrinter;
  }

  static List<String> _toLogTableRow(
    final LogRecord rec, {
    required final bool inUtc,
  }) {
    return [rec.timestamp.toTzString(inUtc), rec.severity ?? '', rec.content];
  }
}

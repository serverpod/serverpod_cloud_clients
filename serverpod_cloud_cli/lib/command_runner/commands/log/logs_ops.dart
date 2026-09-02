import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

abstract class LogsOperations {
  static Future<void> fetchContainerLog(
    Client cloudApiClient, {
    required void Function(String) writeln,
    required String projectId,
    required DateTime? before,
    required DateTime? after,
    required int limit,
    required bool inUtc,
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
    Client cloudApiClient, {
    required void Function(String) writeln,
    required String projectId,
    required int limit,
    required bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    writeln('Tailing logs. Display time zone: $timezoneName.');

    final recordStream = cloudApiClient.logs.tailRecords(
      cloudCapsuleId: projectId,
      limit: limit,
    );
    await LogsOperations._outputLogStream(
      writeln,
      recordStream,
      limit: limit,
      inUtc: inUtc,
    );
  }

  static Future<void> fetchBuildLog(
    Client cloudApiClient, {
    required void Function(String) writeln,
    required String projectId,
    required UuidValue attemptId,
    required bool inUtc,
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
    void Function(String) writeln,
    Stream<LogRecord> recordStream, {
    int? limit,
    required bool inUtc,
  }) async {
    var count = 0;
    final tablePrinter = _createLogTablePrinter();
    final tableStream = tablePrinter.toStream(
      recordStream.map((rec) {
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

  static List<String> _toLogTableRow(LogRecord rec, {required bool inUtc}) {
    return [rec.timestamp.toTzString(inUtc), rec.severity ?? '', rec.content];
  }
}

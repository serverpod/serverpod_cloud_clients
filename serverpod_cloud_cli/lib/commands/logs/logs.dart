import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/output_format.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

abstract class LogsFeature {
  static Future<void> fetchContainerLog(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final DateTime? before,
    required final DateTime? after,
    required final int limit,
    required final bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    logger.line(
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

    await _outputLogStream(
      logger,
      recordStream,
      limit: limit,
      inUtc: inUtc,
    );
  }

  static Future<void> tailContainerLog(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final int limit,
    required final bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    logger.line('Tailing logs. Display time zone: $timezoneName.');

    final recordStream = cloudApiClient.logs.tailRecords(
      cloudCapsuleId: projectId,
      limit: limit,
    );
    await _outputLogStream(
      logger,
      recordStream,
      limit: limit,
      inUtc: inUtc,
    );
  }

  static Future<void> fetchBuildLog(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String attemptId,
    required final bool inUtc,
  }) async {
    final timezoneName = inUtc
        ? 'UTC'
        : 'local (${DateTime.now().timeZoneName})';
    logger.line(
      'Fetching build logs for deploy id $attemptId. Display time zone: $timezoneName.',
    );

    final recordStream = cloudApiClient.logs.fetchBuildLog(
      cloudCapsuleId: projectId,
      attemptId: attemptId,
    );
    await _outputLogStream(logger, recordStream, inUtc: inUtc);
  }

  static Future<void> _outputLogStream(
    final CommandLogger logger,
    final Stream<LogRecord> recordStream, {
    final int? limit,
    required final bool inUtc,
  }) async {
    var count = 0;

    if (logger.outputFormat == OutputFormat.json) {
      try {
        await for (final rec in recordStream) {
          count++;
          logger.outputJsonLine({
            'Timestamp': rec.timestamp.toTzString(inUtc),
            'Level': rec.severity ?? '',
            'Content': rec.content,
          });
          if (limit != null && count >= limit) break;
        }
      } finally {
        logger.outputJsonLine({
          '_meta': 'end',
          'count': count,
          if (limit != null) 'limit': limit,
        });
      }
      return;
    }

    final tablePrinter = _createLogTablePrinter();
    final tableStream = tablePrinter.toStream(
      recordStream.map((final rec) {
        count++;
        return _toLogTableRow(rec, inUtc: inUtc);
      }),
    );
    try {
      await for (final line in tableStream) {
        logger.line(line.trimRight());
      }
    } finally {
      logger.line(
        '-- End of log stream --'
        ' $count records ${limit != null ? '(limit $limit)' : ''} --',
      );
      if (count == limit) {
        logger.line('   (Use the --limit option to increase the limit.)');
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

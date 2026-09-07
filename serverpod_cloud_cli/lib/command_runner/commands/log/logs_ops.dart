import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class LogsOperations {
  static Future<List<LogRecord>> fetchContainerLog(
    final Client cloudApiClient, {
    required final String projectId,
    required final DateTime? before,
    required final DateTime? after,
    required final int limit,
  }) async {
    try {
      final Stream<LogRecord> stream;
      if (before == null && after == null) {
        stream = cloudApiClient.logs.fetchRecentRecords(
          cloudCapsuleId: projectId,
          limit: limit,
        );
      } else {
        stream = cloudApiClient.logs.fetchRecords(
          cloudCapsuleId: projectId,
          beforeTime: before,
          afterTime: after,
          limit: limit,
        );
      }
      return await stream.toList();
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Error while fetching log records');
    }
  }

  static Stream<LogRecord> tailContainerLog(
    final Client cloudApiClient, {
    required final String projectId,
    required final int limit,
  }) {
    return cloudApiClient.logs
        .tailRecords(cloudCapsuleId: projectId, limit: limit)
        .handleError((final error, final stackTrace) {
          if (error is Exception) {
            throw FailureException.nested(
              error,
              stackTrace,
              'Error while tailing log records',
            );
          }
          Error.throwWithStackTrace(error, stackTrace);
        });
  }

  static Future<List<LogRecord>> fetchBuildLog(
    final Client cloudApiClient, {
    required final String projectId,
    required final UuidValue attemptId,
  }) async {
    try {
      return await cloudApiClient.logs
          .fetchBuildLog(cloudCapsuleId: projectId, attemptId: attemptId)
          .toList();
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Error while fetching log records');
    }
  }
}

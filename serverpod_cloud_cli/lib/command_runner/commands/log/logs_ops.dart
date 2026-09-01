import 'package:ground_control_client/ground_control_client.dart';

abstract class LogsOperations {
  static Stream<LogRecord> fetchContainerLog(
    final Client cloudApiClient, {
    required final String projectId,
    required final DateTime? before,
    required final DateTime? after,
    required final int limit,
  }) {
    if (before == null && after == null) {
      return cloudApiClient.logs.fetchRecentRecords(
        cloudCapsuleId: projectId,
        limit: limit,
      );
    }
    return cloudApiClient.logs.fetchRecords(
      cloudCapsuleId: projectId,
      beforeTime: before,
      afterTime: after,
      limit: limit,
    );
  }

  static Stream<LogRecord> tailContainerLog(
    final Client cloudApiClient, {
    required final String projectId,
    required final int limit,
  }) {
    return cloudApiClient.logs.tailRecords(
      cloudCapsuleId: projectId,
      limit: limit,
    );
  }

  static Stream<LogRecord> fetchBuildLog(
    final Client cloudApiClient, {
    required final String projectId,
    required final UuidValue attemptId,
  }) {
    return cloudApiClient.logs.fetchBuildLog(
      cloudCapsuleId: projectId,
      attemptId: attemptId,
    );
  }
}

import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

abstract class StatusFeature {
  static Future<List<DeployAttempt>> getDeployAttemptList(
    final Client cloudApiClient, {
    required final String environmentId,
    required final int? limit,
  }) {
    return cloudApiClient.status.getDeployAttempts(
      cloudEnvironmentId: environmentId,
      limit: limit,
    );
  }

  static Future<List<DeployAttemptStage>> getDeployAttemptStatus(
    final Client cloudApiClient, {
    required final String environmentId,
    required final String attemptId,
  }) {
    return cloudApiClient.status.getDeployAttemptStatus(
      cloudEnvironmentId: environmentId,
      attemptId: attemptId,
    );
  }

  /// Helper to get the deploy attempt id for a specific attempt number.
  static Future<String> getDeployAttemptId(
    final Client cloudApiClient, {
    required final String environmentId,
    required final int attemptNumber,
  }) async {
    return await cloudApiClient.status.getDeployAttemptId(
      cloudEnvironmentId: environmentId,
      attemptNumber: attemptNumber,
    );
  }
}

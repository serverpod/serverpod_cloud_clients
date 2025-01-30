import 'package:ground_control_client/ground_control_client.dart';

abstract class StatusFeature {
  static Future<List<DeployAttempt>> getDeployAttemptList(
    final Client cloudApiClient, {
    required final String cloudCapsuleId,
    required final int? limit,
  }) {
    return cloudApiClient.status.getDeployAttempts(
      cloudCapsuleId: cloudCapsuleId,
      limit: limit,
    );
  }

  static Future<List<DeployAttemptStage>> getDeployAttemptStatus(
    final Client cloudApiClient, {
    required final String cloudCapsuleId,
    required final String attemptId,
  }) {
    return cloudApiClient.status.getDeployAttemptStatus(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
    );
  }

  /// Helper to get the deploy attempt id for a specific attempt number.
  static Future<String> getDeployAttemptId(
    final Client cloudApiClient, {
    required final String cloudCapsuleId,
    required final int attemptNumber,
  }) async {
    return await cloudApiClient.status.getDeployAttemptId(
      cloudCapsuleId: cloudCapsuleId,
      attemptNumber: attemptNumber,
    );
  }
}

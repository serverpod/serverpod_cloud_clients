import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DatabaseScalingOperations {
  /// Starts a pass that pushes the recorded compute scaling back to every
  /// database the provider reports differently.
  ///
  /// The server returns as soon as the pass is started, so this reports what
  /// was requested, not what the pass found.
  static Future<Map<String, Object?>> reconcileComputeScaling(
    final Client cloudApiClient, {
    required final bool apply,
    required final List<String> projectIds,
  }) async {
    try {
      await cloudApiClient.adminDatabaseScaling.reconcileComputeScaling(
        dryRun: !apply,
        cloudCapsuleIds: projectIds.isEmpty ? null : projectIds,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to start the database scaling reconciliation',
      );
    }

    return {'apply': apply, 'projectIds': projectIds};
  }
}

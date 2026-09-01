import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class PlanAdminCommands {
  static Future<List<String>> listOrbPlansOperation(
    final Client cloudApiClient,
  ) {
    return cloudApiClient.adminUpdatePlan.listOrbPlans();
  }

  static Future<Map<String, Object?>> updateOrbPlan(
    final Client cloudApiClient, {
    required final String externalPlanId,
  }) async {
    final result = await cloudApiClient.adminUpdatePlan.updateOrbPlan(
      externalPlanId: externalPlanId,
    );

    if (result['appliedVersion'] case final String appliedVersion) {
      return {
        'externalPlanId': externalPlanId,
        'appliedVersion': appliedVersion,
      };
    }

    throw FailureException(
      error: 'Error response from server, message: ${result['message']}',
    );
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

abstract class PlanAdminCommands {
  static Future<void> listOrbPlans(
    final Client cloudApiClient, {
    required final CommandOutput output,
  }) async {
    final plans = await cloudApiClient.adminUpdatePlan.listOrbPlans();
    output.outputList(
      plans,
      OutputSchemaObject<String>([
        OutputSchemaField(
          name: 'externalPlanId',
          label: 'External Plan ID',
          value: (final plan) => plan,
        ),
      ]),
    );
  }

  static Future<void> updateOrbPlan(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String externalPlanId,
  }) async {
    final result = await cloudApiClient.adminUpdatePlan.updateOrbPlan(
      externalPlanId: externalPlanId,
    );

    if (result['appliedVersion'] case final String appliedVersion) {
      if (appliedVersion.isNotEmpty) {
        logger.success(
          'Orb plan "$externalPlanId" successfully updated to version $appliedVersion.',
          newParagraph: true,
        );
      } else {
        logger.info(
          'Orb plan "$externalPlanId" already up to date.',
          newParagraph: true,
        );
      }
    } else {
      logger.error(
        'Error response from server, message: ${result['message']}',
        newParagraph: true,
      );
    }
  }
}

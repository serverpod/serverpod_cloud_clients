import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

abstract class ProductAdminCommands {
  static Future<void> listProcuredProducts(
    final Client cloudApiClient, {
    required final CommandOutput output,
    required final String userEmail,
  }) async {
    final productRecords = await cloudApiClient.adminProcurement
        .listProcuredProducts(userEmail: userEmail);

    output.outputList(
      productRecords,
      OutputSchemaObject<(String, String)>([
        OutputSchemaField(
          name: 'name',
          label: 'Product',
          value: (final product) => product.$1,
        ),
        OutputSchemaField(
          name: 'type',
          label: 'Type',
          value: (final product) => product.$2,
        ),
      ]),
    );
  }

  static Future<void> procurePlan(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String userEmail,
    required final String planName,
    final int? planVersion,
    final int? trialPeriodOverride,
    final bool? overrideChecks,
  }) async {
    await cloudApiClient.adminProcurement.procurePlan(
      userEmail: userEmail,
      planProductName: planName,
      planProductVersion: planVersion,
      trialPeriodOverride: trialPeriodOverride,
      overrideChecks: overrideChecks,
    );

    logger.success(
      'The plan $planName has been procured for the user.',
      newParagraph: true,
    );
  }

  static Future<void> cancelPlan(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String userEmail,
    final UuidValue? subscriptionId,
    final String? cloudProjectId,
    final bool? terminateImmediately,
  }) async {
    await cloudApiClient.adminProcurement.cancelPlan(
      userEmail: userEmail,
      subscriptionId: subscriptionId,
      cloudProjectId: cloudProjectId,
      terminateImmediately: terminateImmediately,
    );

    logger.success("The user's plan has been cancelled.", newParagraph: true);
  }
}

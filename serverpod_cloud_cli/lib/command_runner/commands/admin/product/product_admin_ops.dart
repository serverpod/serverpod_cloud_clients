import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

abstract class ProductAdminCommands {
  static Future<List<Map<String, Object?>>> listProcuredProductsOperation(
    Client cloudApiClient, {
    required String userEmail,
  }) async {
    final productRecords = await cloudApiClient.adminProcurement
        .listProcuredProducts(userEmail: userEmail);

    return [
      for (final product in productRecords)
        {'name': product.$1, 'type': product.$2},
    ];
  }

  static Future<void> procurePlan(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String userEmail,
    required String planName,
    int? planVersion,
    int? trialPeriodOverride,
    bool? overrideChecks,
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
    Client cloudApiClient, {
    required CommandLogger logger,
    required String userEmail,
    UuidValue? subscriptionId,
    String? cloudProjectId,
    bool? terminateImmediately,
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

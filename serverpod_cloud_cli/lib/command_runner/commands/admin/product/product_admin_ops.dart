import 'package:ground_control_client/ground_control_client.dart';

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

  static Future<Map<String, Object?>> procurePlan(
    final Client cloudApiClient, {
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

    return {'planName': planName};
  }

  static Future<void> cancelPlan(
    final Client cloudApiClient, {
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
  }
}

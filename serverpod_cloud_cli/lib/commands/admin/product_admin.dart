import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class ProductAdminCommands {
  static Future<void> listProcuredProducts(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String userEmail,
  }) async {
    final productRecords = await cloudApiClient.adminProcurement
        .listProcuredProducts(userEmail: userEmail);

    final table = TablePrinter(
      headers: ['Product', 'Type'],
      rows: productRecords.map((final product) => [product.$1, product.$2]),
    );
    table.writeLines(logger.line);
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
    final bool? terminateImmediately,
  }) async {
    await cloudApiClient.adminProcurement.cancelPlan(
      userEmail: userEmail,
      terminateImmediately: terminateImmediately,
    );

    logger.success("The user's plan has been cancelled.", newParagraph: true);
  }
}

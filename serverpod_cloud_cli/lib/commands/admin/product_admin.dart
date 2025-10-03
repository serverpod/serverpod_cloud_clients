import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class ProductAdminCommands {
  static Future<void> listProcuredProducts(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String userEmail,
  }) async {
    final productRecords =
        await cloudApiClient.adminProcurement.listProcuredProducts(
      userEmail: userEmail,
    );

    final table = TablePrinter(
      headers: [
        'Product',
        'Type',
      ],
      rows: productRecords.map((final product) => [
            product.$1,
            product.$2,
          ]),
    );
    table.writeLines(logger.line);
  }

  static Future<void> procureProduct(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String userEmail,
    required final String productName,
    final int? productVersion,
    final bool? overrideChecks,
  }) async {
    await cloudApiClient.adminProcurement.procureProduct(
      userEmail: userEmail,
      productName: productName,
      productVersion: productVersion,
      overrideChecks: overrideChecks,
    );

    logger.success(
      'The product has been procured for the user.',
      newParagraph: true,
    );
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class MeCommands {
  static Future<void> showCurrentUser(
    final Client cloudApiClient, {
    required final CommandLogger logger,
  }) async {
    final user = await cloudApiClient.users.readUser();

    String planDisplayName = 'No plan';
    try {
      final subscriptionInfo = await cloudApiClient.plans.getSubscriptionInfo();
      planDisplayName = subscriptionInfo.planDisplayName;
    } on NoSubscriptionException {
      planDisplayName = 'No plan';
    } on Exception catch (e) {
      logger.debug('Failed to fetch subscription info: $e');
    }

    final table = TablePrinter(
      headers: ['Email', 'Plan'],
      rows: [
        [user.email, planDisplayName],
      ],
    );
    table.writeLines(logger.line);
  }
}

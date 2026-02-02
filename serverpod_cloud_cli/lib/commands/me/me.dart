import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class MeCommands {
  static Future<void> showCurrentUser(
    final Client cloudApiClient, {
    required final CommandLogger logger,
  }) async {
    final user = await cloudApiClient.users.readUser();

    SubscriptionInfo? subscriptionInfo;
    try {
      subscriptionInfo = await cloudApiClient.plans.getSubscriptionInfo();
    } on NoSubscriptionException catch (_) {
    } on Exception catch (e) {
      logger.debug('Failed to fetch subscription info: $e');
    }

    final planDisplayName = subscriptionInfo?.planDisplayName ?? 'No plan';
    final status = _determineStatus(subscriptionInfo) ?? '';

    final table = TablePrinter(
      headers: ['Email', 'Plan', 'Status'],
      rows: [
        [user.email, planDisplayName, status],
      ],
    );
    table.writeLines(logger.line);
  }

  static String? _determineStatus(final SubscriptionInfo? subscriptionInfo) {
    if (subscriptionInfo == null) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final endDate = subscriptionInfo.endDate;
    final trialEndDate = subscriptionInfo.trialEndDate;

    if (endDate != null && endDate.isBefore(today)) {
      return 'Subscription ended ${endDate.toString().substring(0, 10)}';
    } else if (trialEndDate != null && !trialEndDate.isBefore(today)) {
      return 'Trial until ${trialEndDate.toString().substring(0, 10)}';
    } else {
      return 'Subscription active';
    }
  }
}

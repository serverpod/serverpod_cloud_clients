import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

abstract class BillingCommands {
  /// Checks if the owner is in good standing and warns if not.
  static Future<void> warnIfOverdue({
    required final CommandLogger logger,
    required final EndpointBilling billing,
  }) async {
    final bool isInGoodStanding;
    try {
      isInGoodStanding = await billing.ownerIsInGoodStanding();
    } catch (e) {
      logger.debug('Failed to call [ownerIsInGoodStanding]: $e');
      return;
    }

    if (isInGoodStanding) return;

    Uri? billingPortalUrl;
    try {
      final Owner owner = await billing.readOwner();
      billingPortalUrl = owner.billingPortalUrl;
    } catch (e) {
      logger.debug('Failed to call [readOwner]: $e');
    }

    _printOverdueWarning(logger: logger, billingPortalUrl: billingPortalUrl);
  }

  static void _printOverdueWarning({
    required final CommandLogger logger,
    final Uri? billingPortalUrl,
  }) {
    var message =
        'Payment Overdue\n'
        'Update your payment method to avoid service interruption.';

    if (billingPortalUrl != null) {
      message = '$message\n\nManage billing: $billingPortalUrl';
    }

    logger.box(message, level: LogLevel.warning);
  }
}

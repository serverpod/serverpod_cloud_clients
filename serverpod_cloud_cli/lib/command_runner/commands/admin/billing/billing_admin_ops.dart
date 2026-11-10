import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class BillingAdminOperations {
  /// Asks Ground Control to issue [invoiceId] again.
  ///
  /// Returns the invoice id and `outcome` `issued` or `issueFailed`.
  /// Throws [FailureException] when the invoice is not found or Orb rejects
  /// the issue for a reason other than an incomplete customer address. The
  /// error is Orb's reason.
  static Future<Map<String, Object?>> reissueInvoice(
    final Client cloudApiClient, {
    required final String invoiceId,
  }) async {
    try {
      final result = await cloudApiClient.adminBilling.reissueInvoice(
        invoiceId: invoiceId,
      );
      return {
        'invoiceId': result['invoiceId'] ?? invoiceId,
        'outcome': result['outcome'],
      };
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to reissue invoice');
    }
  }
}

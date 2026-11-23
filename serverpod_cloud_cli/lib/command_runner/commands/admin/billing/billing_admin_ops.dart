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

  /// Asks Ground Control to record a missed payment failure of [invoiceId].
  ///
  /// Returns the invoice id and `outcome` `recorded`.
  /// Throws [FailureException] when the invoice is not found, its customer
  /// is not an owner, or the invoice cannot be recorded.
  static Future<Map<String, Object?>> recordPaymentFailed(
    final Client cloudApiClient, {
    required final String invoiceId,
  }) async {
    try {
      final result = await cloudApiClient.adminBilling.recordPaymentFailed(
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
      throw FailureException.nested(e, s, 'Failed to record payment failure');
    }
  }

  /// Asks Ground Control to record a missed trial end of [subscriptionId].
  ///
  /// Returns the subscription id and `outcome` `recorded`.
  /// Throws [FailureException] when the subscription is not found, its
  /// customer is not an owner, or the trial end cannot be recorded.
  static Future<Map<String, Object?>> recordTrialEnded(
    final Client cloudApiClient, {
    required final String subscriptionId,
  }) async {
    try {
      final result = await cloudApiClient.adminBilling.recordTrialEnded(
        subscriptionId: subscriptionId,
      );
      return {
        'subscriptionId': result['subscriptionId'] ?? subscriptionId,
        'outcome': result['outcome'],
      };
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to record trial end');
    }
  }

  /// Asks Ground Control to record the missed trial end of every
  /// subscription whose trial ended at or after [since]. With [dryRun],
  /// nothing is recorded.
  ///
  /// Returns one row per subscription with its `subscriptionId`, its
  /// `outcome` (`recorded`, `dryRun` or `skipped`) and the `reason` it was
  /// skipped for.
  /// Throws [FailureException] when the request fails.
  static Future<List<Map<String, Object?>>> recordTrialsEnded(
    final Client cloudApiClient, {
    required final DateTime since,
    required final bool dryRun,
  }) async {
    try {
      final records = await cloudApiClient.adminBilling.recordTrialsEnded(
        since: since,
        dryRun: dryRun,
      );
      return [
        for (final record in records)
          {
            'subscriptionId': record['subscriptionId'],
            'outcome': record['outcome'],
            'reason': record['reason'],
          },
      ];
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to record trial ends');
    }
  }
}

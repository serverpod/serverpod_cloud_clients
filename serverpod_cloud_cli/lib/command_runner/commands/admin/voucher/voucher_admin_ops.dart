import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class VoucherAdminOperations {
  /// Creates a voucher and returns it.
  ///
  /// Throws [FailureException] with the reason from Ground Control if a
  /// value is invalid or a voucher has the same code.
  static Future<AdminVoucher> createVoucher(
    final Client cloudApiClient, {
    required final String code,
    required final String name,
    required final int creditAmountCents,
    required final List<String> paysForItemIds,
    final DateTime? redeemableUntil,
    final int? creditLifetimeDays,
    final DateTime? creditExpiresBy,
    final int? maxRedemptions,
    final int? maxRedemptionsPerOwner,
  }) async {
    try {
      return await cloudApiClient.adminVouchers.createVoucher(
        code: code,
        name: name,
        creditAmountCents: creditAmountCents,
        paysForItemIds: paysForItemIds,
        redeemableUntil: redeemableUntil,
        creditLifetimeDays: creditLifetimeDays,
        creditExpiresBy: creditExpiresBy,
        maxRedemptions: maxRedemptions,
        maxRedemptionsPerOwner: maxRedemptionsPerOwner,
      );
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on DuplicateEntryException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create the voucher');
    }
  }

  /// Lists the vouchers, newest first, without the archived ones unless
  /// [includeArchived] is set.
  static Future<List<AdminVoucher>> listVouchers(
    final Client cloudApiClient, {
    required final bool includeArchived,
  }) async {
    try {
      return await cloudApiClient.adminVouchers.listVouchers(
        includeArchived: includeArchived,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list the vouchers');
    }
  }

  /// Archives the voucher with [code] and returns it.
  ///
  /// Throws [FailureException] if no voucher has the code.
  static Future<AdminVoucher> archiveVoucher(
    final Client cloudApiClient, {
    required final String code,
  }) async {
    try {
      return await cloudApiClient.adminVouchers.archiveVoucher(code: code);
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to archive the voucher');
    }
  }
}

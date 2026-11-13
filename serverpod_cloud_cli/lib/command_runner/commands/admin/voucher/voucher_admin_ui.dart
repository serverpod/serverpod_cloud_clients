import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/constants.dart' show numTimeStampChars;
import 'package:serverpod_cloud_cli/util/common.dart' show TimezonedString;

/// The vouchers as a table, or a message when there are none.
class AdminVoucherListTextUi extends OutputWidget {
  final bool utc;

  const AdminVoucherListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final vouchers = context.get<List<AdminVoucher>>();
    if (vouchers.isEmpty) {
      return const InfoTextWidget('No vouchers available.');
    }
    return FormattedTableWidget<AdminVoucher>(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forElement(
            'Code',
            getter: (final voucher) => voucher.code,
          ),
          TableColumnFormatter.forElement(
            'Name',
            getter: (final voucher) => voucher.name,
          ),
          TableColumnFormatter.forElement(
            'Credit',
            getter: (final voucher) => _formatCredit(voucher),
          ),
          TableColumnFormatter.forElement(
            'Pays for',
            getter: (final voucher) => _formatPaysFor(voucher),
          ),
          TableColumnFormatter.forElement(
            'Status',
            getter: (final voucher) => voucher.status.name,
          ),
          TableColumnFormatter.forElement(
            'Redemptions',
            getter: (final voucher) => _formatRedemptions(voucher),
          ),
          TableColumnFormatter.forTimestamp(
            'Redeemable until',
            getter: (final voucher) => voucher.redeemableUntil,
          ),
        ],
        utc: utc,
      ),
    );
  }
}

/// A success message for a created voucher, followed by its terms.
class AdminVoucherCreateTextUi extends OutputWidget {
  final bool utc;

  const AdminVoucherCreateTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final voucher = context.get<AdminVoucher>();
    return OutputWidgetList([
      SuccessTextWidget(
        'Voucher "${voucher.code}" created.',
        newParagraph: true,
      ),
      ListTextWidget(_formatTerms(voucher, utc: utc)),
    ]);
  }
}

/// A success message for an archived voucher, followed by its terms.
class AdminVoucherArchiveTextUi extends OutputWidget {
  final bool utc;

  const AdminVoucherArchiveTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final voucher = context.get<AdminVoucher>();
    return OutputWidgetList([
      SuccessTextWidget(
        'Voucher "${voucher.code}" archived.',
        newParagraph: true,
      ),
      ListTextWidget(_formatTerms(voucher, utc: utc)),
    ]);
  }
}

List<String> _formatTerms(
  final AdminVoucher voucher, {
  required final bool utc,
}) {
  final redeemableUntil = voucher.redeemableUntil;
  final creditLifetimeDays = voucher.creditLifetimeDays;
  final creditExpiresBy = voucher.creditExpiresBy;
  return [
    'Name: ${voucher.name}',
    'Credit: ${_formatCredit(voucher)}',
    'Pays for: ${_formatPaysFor(voucher)}',
    'Status: ${voucher.status.name}',
    'Redemptions: ${_formatRedemptions(voucher)}',
    'Redemptions per owner: ${voucher.maxRedemptionsPerOwner}',
    if (redeemableUntil != null)
      'Redeemable until: ${redeemableUntil.toLabeledTzString(utc, numTimeStampChars)}',
    if (creditLifetimeDays != null)
      'Credit lifetime in days: $creditLifetimeDays',
    if (creditExpiresBy != null)
      'Credit expires by: ${creditExpiresBy.toLabeledTzString(utc, numTimeStampChars)}',
  ];
}

String _formatCredit(final AdminVoucher voucher) {
  final cents = (voucher.creditAmountCents % 100).toString().padLeft(2, '0');
  return '\$${voucher.creditAmountCents ~/ 100}.$cents';
}

String _formatPaysFor(final AdminVoucher voucher) {
  return voucher.paysForItemIds.isEmpty
      ? 'all items'
      : voucher.paysForItemIds.join(', ');
}

String _formatRedemptions(final AdminVoucher voucher) {
  final maxRedemptions = voucher.maxRedemptions;
  return maxRedemptions == null
      ? '${voucher.redemptionCount}'
      : '${voucher.redemptionCount} of $maxRedemptions';
}

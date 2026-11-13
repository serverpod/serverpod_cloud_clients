import 'package:ground_control_client/ground_control_client.dart';

class AdminVoucherBuilder {
  String _code;
  String _name;
  int _creditAmountCents;
  List<String> _paysForItemIds;
  DateTime? _redeemableUntil;
  int? _creditLifetimeDays;
  int? _maxRedemptions;
  VoucherStatus _status;
  int _redemptionCount;
  DateTime? _archivedAt;

  AdminVoucherBuilder()
    : _code = 'SHIPIT60',
      _name = 'Ship it',
      _creditAmountCents = 6000,
      _paysForItemIds = [],
      _status = VoucherStatus.active,
      _redemptionCount = 0;

  AdminVoucherBuilder withCode(final String code) {
    _code = code;
    return this;
  }

  AdminVoucherBuilder withName(final String name) {
    _name = name;
    return this;
  }

  AdminVoucherBuilder withCreditAmountCents(final int creditAmountCents) {
    _creditAmountCents = creditAmountCents;
    return this;
  }

  AdminVoucherBuilder withPaysForItemIds(final List<String> paysForItemIds) {
    _paysForItemIds = paysForItemIds;
    return this;
  }

  AdminVoucherBuilder withRedeemableUntil(final DateTime? redeemableUntil) {
    _redeemableUntil = redeemableUntil;
    return this;
  }

  AdminVoucherBuilder withCreditLifetimeDays(final int? creditLifetimeDays) {
    _creditLifetimeDays = creditLifetimeDays;
    return this;
  }

  AdminVoucherBuilder withMaxRedemptions(final int? maxRedemptions) {
    _maxRedemptions = maxRedemptions;
    return this;
  }

  AdminVoucherBuilder withRedemptionCount(final int redemptionCount) {
    _redemptionCount = redemptionCount;
    return this;
  }

  /// An admin stopped the voucher.
  AdminVoucherBuilder withArchived() {
    _status = VoucherStatus.archived;
    _archivedAt = DateTime.utc(2026, 11, 20);
    return this;
  }

  AdminVoucher build() {
    return AdminVoucher(
      code: _code,
      name: _name,
      creditAmountCents: _creditAmountCents,
      paysForItemIds: _paysForItemIds,
      redeemableUntil: _redeemableUntil,
      creditLifetimeDays: _creditLifetimeDays,
      maxRedemptions: _maxRedemptions,
      maxRedemptionsPerOwner: 1,
      status: _status,
      redemptionCount: _redemptionCount,
      createdAt: DateTime.utc(2026, 11, 13),
      archivedAt: _archivedAt,
    );
  }
}

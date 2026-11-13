import 'package:ground_control_client/ground_control_client.dart';

class RedeemedVoucherBuilder {
  String _code;
  String _name;
  int _creditAmountCents;
  List<String> _paysForItemIds;
  DateTime? _creditExpiresAt;

  RedeemedVoucherBuilder()
    : _code = 'SHIPIT60',
      _name = 'Ship it with Serverpod participant offer',
      _creditAmountCents = 6000,
      _paysForItemIds = ['growthFee'],
      _creditExpiresAt = DateTime.utc(2027, 6, 30);

  RedeemedVoucherBuilder withCode(String code) {
    _code = code;
    return this;
  }

  RedeemedVoucherBuilder withName(String name) {
    _name = name;
    return this;
  }

  RedeemedVoucherBuilder withCreditAmountCents(int creditAmountCents) {
    _creditAmountCents = creditAmountCents;
    return this;
  }

  RedeemedVoucherBuilder withPaysForItemIds(List<String> paysForItemIds) {
    _paysForItemIds = paysForItemIds;
    return this;
  }

  RedeemedVoucherBuilder withAllCharges() {
    _paysForItemIds = [];
    return this;
  }

  RedeemedVoucherBuilder withCreditExpiresAt(DateTime? creditExpiresAt) {
    _creditExpiresAt = creditExpiresAt;
    return this;
  }

  RedeemedVoucherBuilder withNoExpiry() {
    _creditExpiresAt = null;
    return this;
  }

  RedeemedVoucher build() {
    return RedeemedVoucher(
      code: _code,
      name: _name,
      creditAmountCents: _creditAmountCents,
      paysForItemIds: _paysForItemIds,
      creditExpiresAt: _creditExpiresAt,
    );
  }
}

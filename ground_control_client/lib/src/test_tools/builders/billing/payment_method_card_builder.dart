import 'package:ground_control_client/ground_control_client.dart';

class PaymentMethodCardBuilder {
  String _brand;
  String _last4;
  int _expMonth;
  int _expYear;
  String? _funding;
  String? _country;

  PaymentMethodCardBuilder()
    : _brand = 'visa',
      _last4 = '4242',
      _expMonth = 12,
      _expYear = 2025,
      _funding = 'credit',
      _country = 'US';

  PaymentMethodCardBuilder withBrand(String brand) {
    _brand = brand;
    return this;
  }

  PaymentMethodCardBuilder withLast4(String last4) {
    _last4 = last4;
    return this;
  }

  PaymentMethodCardBuilder withExpMonth(int expMonth) {
    _expMonth = expMonth;
    return this;
  }

  PaymentMethodCardBuilder withExpYear(int expYear) {
    _expYear = expYear;
    return this;
  }

  PaymentMethodCardBuilder withFunding(String? funding) {
    _funding = funding;
    return this;
  }

  PaymentMethodCardBuilder withCountry(String? country) {
    _country = country;
    return this;
  }

  PaymentMethodCard build() {
    return PaymentMethodCard(
      brand: _brand,
      last4: _last4,
      expMonth: _expMonth,
      expYear: _expYear,
      funding: _funding,
      country: _country,
    );
  }
}

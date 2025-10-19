import 'package:ground_control_client/ground_control_client.dart';

class PaymentSetupIntentBuilder {
  String _id;
  String _clientSecret;
  String _status;

  PaymentSetupIntentBuilder()
      : _id = 'seti_test_123',
        _clientSecret = 'mock_secret',
        _status = 'requires_payment_method';

  PaymentSetupIntentBuilder withId(String id) {
    _id = id;
    return this;
  }

  PaymentSetupIntentBuilder withClientSecret(String clientSecret) {
    _clientSecret = clientSecret;
    return this;
  }

  PaymentSetupIntentBuilder withStatus(String status) {
    _status = status;
    return this;
  }

  PaymentSetupIntent build() {
    return PaymentSetupIntent(
      id: _id,
      clientSecret: _clientSecret,
      status: _status,
    );
  }
}

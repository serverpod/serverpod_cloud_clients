import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class PaymentMethodBuilder {
  String _id;
  String _type;
  PaymentMethodCard? _card;

  PaymentMethodBuilder()
    : _id = 'pm_test_1234567890',
      _type = 'card',
      _card = PaymentMethodCardBuilder().build();

  PaymentMethodBuilder withId(String id) {
    _id = id;
    return this;
  }

  PaymentMethodBuilder withType(String type) {
    _type = type;
    return this;
  }

  PaymentMethodBuilder withCard(PaymentMethodCard? card) {
    _card = card;
    return this;
  }

  PaymentMethodBuilder withCardBuilder(PaymentMethodCardBuilder cardBuilder) {
    _card = cardBuilder.build();
    return this;
  }

  PaymentMethod build() {
    return PaymentMethod(id: _id, type: _type, card: _card);
  }
}

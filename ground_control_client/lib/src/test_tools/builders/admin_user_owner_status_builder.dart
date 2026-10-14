import 'package:ground_control_client/ground_control_client.dart';

class AdminUserOwnerStatusBuilder {
  UuidValue _ownerId;
  String? _userEmail;
  bool _billingInfoRegistered;
  bool _paymentMethodRegistered;
  BillingCustomerType? _customerType;
  bool _inGoodStanding;

  AdminUserOwnerStatusBuilder()
    : _ownerId = UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
      _userEmail = 'ada@example.com',
      _billingInfoRegistered = true,
      _paymentMethodRegistered = true,
      _customerType = BillingCustomerType.private,
      _inGoodStanding = true;

  AdminUserOwnerStatusBuilder withOwnerId(UuidValue ownerId) {
    _ownerId = ownerId;
    return this;
  }

  AdminUserOwnerStatusBuilder withUserEmail(String? userEmail) {
    _userEmail = userEmail;
    return this;
  }

  AdminUserOwnerStatusBuilder withBillingInfoRegistered(bool value) {
    _billingInfoRegistered = value;
    return this;
  }

  AdminUserOwnerStatusBuilder withPaymentMethodRegistered(bool value) {
    _paymentMethodRegistered = value;
    return this;
  }

  AdminUserOwnerStatusBuilder withCustomerType(
    BillingCustomerType? customerType,
  ) {
    _customerType = customerType;
    return this;
  }

  AdminUserOwnerStatusBuilder withInGoodStanding(bool value) {
    _inGoodStanding = value;
    return this;
  }

  AdminUserOwnerStatus build() {
    return AdminUserOwnerStatus(
      ownerId: _ownerId,
      userEmail: _userEmail,
      billingInfoRegistered: _billingInfoRegistered,
      paymentMethodRegistered: _paymentMethodRegistered,
      customerType: _customerType,
      inGoodStanding: _inGoodStanding,
    );
  }
}

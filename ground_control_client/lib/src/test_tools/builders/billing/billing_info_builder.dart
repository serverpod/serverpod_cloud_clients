import 'package:ground_control_client/ground_control_client.dart';

class BillingInfoBuilder {
  UuidValue? _id;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  UuidValue _ownerId;
  Owner? _owner;
  String? _companyName;
  String _addressLine1;
  String? _addressLine2;
  String _postalCode;
  String _city;
  String? _state;
  String _country;
  String? _vatNumber;
  String? _vatType;
  BillingCustomerType _customerType;

  BillingInfoBuilder({Owner? owner})
    : _id = Uuid().v4obj(),
      _createdAt = DateTime.now(),
      _updatedAt = DateTime.now(),
      _ownerId = owner?.id ?? Uuid().v4obj(),
      _owner = owner,
      _companyName = 'Serverpod',
      _addressLine1 = '123 Main St',
      _addressLine2 = null,
      _postalCode = '12345',
      _city = 'New York',
      _state = 'New York',
      _country = 'US',
      _vatNumber = null,
      _vatType = null,
      _customerType = BillingCustomerType.private;

  BillingInfoBuilder withId(UuidValue? id) {
    _id = id;
    return this;
  }

  BillingInfoBuilder withCreatedAt(DateTime? createdAt) {
    _createdAt = createdAt;
    return this;
  }

  BillingInfoBuilder withUpdatedAt(DateTime? updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  BillingInfoBuilder withOwnerId(UuidValue ownerId) {
    _ownerId = ownerId;
    return this;
  }

  BillingInfoBuilder withOwner(Owner? owner) {
    if (owner != null) {
      _ownerId = owner.id;
    }
    _owner = owner;
    return this;
  }

  BillingInfoBuilder withCompanyName(String? companyName) {
    _companyName = companyName;
    return this;
  }

  BillingInfoBuilder withAddressLine1(String addressLine1) {
    _addressLine1 = addressLine1;
    return this;
  }

  BillingInfoBuilder withAddressLine2(String? addressLine2) {
    _addressLine2 = addressLine2;
    return this;
  }

  BillingInfoBuilder withPostalCode(String postalCode) {
    _postalCode = postalCode;
    return this;
  }

  BillingInfoBuilder withCity(String city) {
    _city = city;
    return this;
  }

  BillingInfoBuilder withState(String? state) {
    _state = state;
    return this;
  }

  BillingInfoBuilder withCountry(String country) {
    _country = country;
    return this;
  }

  BillingInfoBuilder withVatNumber(String? vatNumber) {
    _vatNumber = vatNumber;
    return this;
  }

  BillingInfoBuilder withVatType(String? vatType) {
    _vatType = vatType;
    return this;
  }

  BillingInfoBuilder withCustomerType(BillingCustomerType customerType) {
    _customerType = customerType;
    return this;
  }

  BillingInfoBuilder withBusinessUser() {
    _customerType = BillingCustomerType.business;
    _vatNumber = 'SE123456789123';
    _vatType = 'eu_vat';
    _country = 'SE';
    return this;
  }

  BillingInfoBuilder withPrivateUser() {
    _customerType = BillingCustomerType.private;
    _vatNumber = null;
    _vatType = null;
    return this;
  }

  BillingInfo build() {
    return BillingInfo(
      id: _id,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      ownerId: _ownerId,
      owner: _owner,
      companyName: _companyName,
      addressLine1: _addressLine1,
      addressLine2: _addressLine2,
      postalCode: _postalCode,
      city: _city,
      state: _state,
      country: _country,
      vatNumber: _vatNumber,
      vatType: _vatType,
      customerType: _customerType,
    );
  }
}

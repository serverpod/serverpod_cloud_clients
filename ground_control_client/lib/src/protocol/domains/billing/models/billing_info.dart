/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../domains/billing/models/billing_customer_type.dart' as _i2;
import '../../../domains/billing/models/owner.dart' as _i3;

abstract class BillingInfo implements _i1.SerializableModel {
  BillingInfo._({
    _i1.UuidValue? id,
    this.createdAt,
    this.updatedAt,
    required this.ownerId,
    this.owner,
    this.companyName,
    required this.addressLine1,
    this.addressLine2,
    required this.postalCode,
    required this.city,
    this.state,
    required this.country,
    this.vatNumber,
    this.vatType,
    _i2.BillingCustomerType? customerType,
  })  : id = id ?? _i1.Uuid().v4obj(),
        customerType = customerType ?? _i2.BillingCustomerType.private;

  factory BillingInfo({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required _i1.UuidValue ownerId,
    _i3.Owner? owner,
    String? companyName,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String? state,
    required String country,
    String? vatNumber,
    String? vatType,
    _i2.BillingCustomerType? customerType,
  }) = _BillingInfoImpl;

  factory BillingInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillingInfo(
      id: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      ownerId:
          _i1.UuidValueJsonExtension.fromJson(jsonSerialization['ownerId']),
      owner: jsonSerialization['owner'] == null
          ? null
          : _i3.Owner.fromJson(
              (jsonSerialization['owner'] as Map<String, dynamic>)),
      companyName: jsonSerialization['companyName'] as String?,
      addressLine1: jsonSerialization['addressLine1'] as String,
      addressLine2: jsonSerialization['addressLine2'] as String?,
      postalCode: jsonSerialization['postalCode'] as String,
      city: jsonSerialization['city'] as String,
      state: jsonSerialization['state'] as String?,
      country: jsonSerialization['country'] as String,
      vatNumber: jsonSerialization['vatNumber'] as String?,
      vatType: jsonSerialization['vatType'] as String?,
      customerType: _i2.BillingCustomerType.fromJson(
          (jsonSerialization['customerType'] as String)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue id;

  DateTime? createdAt;

  DateTime? updatedAt;

  _i1.UuidValue ownerId;

  _i3.Owner? owner;

  String? companyName;

  String addressLine1;

  String? addressLine2;

  String postalCode;

  String city;

  String? state;

  String country;

  String? vatNumber;

  String? vatType;

  _i2.BillingCustomerType customerType;

  /// Returns a shallow copy of this [BillingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BillingInfo copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? ownerId,
    _i3.Owner? owner,
    String? companyName,
    String? addressLine1,
    String? addressLine2,
    String? postalCode,
    String? city,
    String? state,
    String? country,
    String? vatNumber,
    String? vatType,
    _i2.BillingCustomerType? customerType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      if (companyName != null) 'companyName': companyName,
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      'postalCode': postalCode,
      'city': city,
      if (state != null) 'state': state,
      'country': country,
      if (vatNumber != null) 'vatNumber': vatNumber,
      if (vatType != null) 'vatType': vatType,
      'customerType': customerType.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillingInfoImpl extends BillingInfo {
  _BillingInfoImpl({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required _i1.UuidValue ownerId,
    _i3.Owner? owner,
    String? companyName,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String? state,
    required String country,
    String? vatNumber,
    String? vatType,
    _i2.BillingCustomerType? customerType,
  }) : super._(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          ownerId: ownerId,
          owner: owner,
          companyName: companyName,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          postalCode: postalCode,
          city: city,
          state: state,
          country: country,
          vatNumber: vatNumber,
          vatType: vatType,
          customerType: customerType,
        );

  /// Returns a shallow copy of this [BillingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BillingInfo copyWith({
    _i1.UuidValue? id,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    _i1.UuidValue? ownerId,
    Object? owner = _Undefined,
    Object? companyName = _Undefined,
    String? addressLine1,
    Object? addressLine2 = _Undefined,
    String? postalCode,
    String? city,
    Object? state = _Undefined,
    String? country,
    Object? vatNumber = _Undefined,
    Object? vatType = _Undefined,
    _i2.BillingCustomerType? customerType,
  }) {
    return BillingInfo(
      id: id ?? this.id,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _i3.Owner? ? owner : this.owner?.copyWith(),
      companyName: companyName is String? ? companyName : this.companyName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 is String? ? addressLine2 : this.addressLine2,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      state: state is String? ? state : this.state,
      country: country ?? this.country,
      vatNumber: vatNumber is String? ? vatNumber : this.vatNumber,
      vatType: vatType is String? ? vatType : this.vatType,
      customerType: customerType ?? this.customerType,
    );
  }
}

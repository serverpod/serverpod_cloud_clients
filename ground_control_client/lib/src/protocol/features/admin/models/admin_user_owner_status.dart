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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/billing/models/billing_customer_type.dart'
    as _ipm3sphs;

abstract class AdminUserOwnerStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminUserOwnerStatus._({
    required this.ownerId,
    this.userEmail,
    required this.billingInfoRegistered,
    required this.paymentMethodRegistered,
    this.customerType,
    required this.inGoodStanding,
  });

  factory AdminUserOwnerStatus({
    required _isc.UuidValue ownerId,
    String? userEmail,
    required bool billingInfoRegistered,
    required bool paymentMethodRegistered,
    _ipm3sphs.BillingCustomerType? customerType,
    required bool inGoodStanding,
  }) = _AdminUserOwnerStatusImpl;

  factory AdminUserOwnerStatus.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminUserOwnerStatus(
      ownerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      userEmail: jsonSerialization['userEmail'] as String?,
      billingInfoRegistered: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['billingInfoRegistered'],
      ),
      paymentMethodRegistered: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['paymentMethodRegistered'],
      ),
      customerType: jsonSerialization['customerType'] == null
          ? null
          : _ipm3sphs.BillingCustomerType.fromJson(
              (jsonSerialization['customerType'] as String),
            ),
      inGoodStanding: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['inGoodStanding'],
      ),
    );
  }

  _isc.UuidValue ownerId;

  String? userEmail;

  bool billingInfoRegistered;

  bool paymentMethodRegistered;

  _ipm3sphs.BillingCustomerType? customerType;

  bool inGoodStanding;

  /// Returns a shallow copy of this [AdminUserOwnerStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminUserOwnerStatus copyWith({
    _isc.UuidValue? ownerId,
    String? userEmail,
    bool? billingInfoRegistered,
    bool? paymentMethodRegistered,
    _ipm3sphs.BillingCustomerType? customerType,
    bool? inGoodStanding,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminUserOwnerStatus',
      'ownerId': ownerId.toJson(),
      if (userEmail != null) 'userEmail': userEmail,
      'billingInfoRegistered': billingInfoRegistered,
      'paymentMethodRegistered': paymentMethodRegistered,
      if (customerType != null) 'customerType': customerType?.toJson(),
      'inGoodStanding': inGoodStanding,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminUserOwnerStatus',
      'ownerId': ownerId.toJson(),
      if (userEmail != null) 'userEmail': userEmail,
      'billingInfoRegistered': billingInfoRegistered,
      'paymentMethodRegistered': paymentMethodRegistered,
      if (customerType != null) 'customerType': customerType?.toJson(),
      'inGoodStanding': inGoodStanding,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminUserOwnerStatusImpl extends AdminUserOwnerStatus {
  _AdminUserOwnerStatusImpl({
    required _isc.UuidValue ownerId,
    String? userEmail,
    required bool billingInfoRegistered,
    required bool paymentMethodRegistered,
    _ipm3sphs.BillingCustomerType? customerType,
    required bool inGoodStanding,
  }) : super._(
         ownerId: ownerId,
         userEmail: userEmail,
         billingInfoRegistered: billingInfoRegistered,
         paymentMethodRegistered: paymentMethodRegistered,
         customerType: customerType,
         inGoodStanding: inGoodStanding,
       );

  /// Returns a shallow copy of this [AdminUserOwnerStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminUserOwnerStatus copyWith({
    _isc.UuidValue? ownerId,
    Object? userEmail = _Undefined,
    bool? billingInfoRegistered,
    bool? paymentMethodRegistered,
    Object? customerType = _Undefined,
    bool? inGoodStanding,
  }) {
    return AdminUserOwnerStatus(
      ownerId: ownerId ?? this.ownerId,
      userEmail: userEmail is String? ? userEmail : this.userEmail,
      billingInfoRegistered:
          billingInfoRegistered ?? this.billingInfoRegistered,
      paymentMethodRegistered:
          paymentMethodRegistered ?? this.paymentMethodRegistered,
      customerType: customerType is _ipm3sphs.BillingCustomerType?
          ? customerType
          : this.customerType,
      inGoodStanding: inGoodStanding ?? this.inGoodStanding,
    );
  }
}

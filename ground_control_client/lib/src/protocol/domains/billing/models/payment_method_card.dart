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

abstract class PaymentMethodCard implements _i1.SerializableModel {
  PaymentMethodCard._({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.funding,
    this.country,
  });

  factory PaymentMethodCard({
    required String brand,
    required String last4,
    required int expMonth,
    required int expYear,
    String? funding,
    String? country,
  }) = _PaymentMethodCardImpl;

  factory PaymentMethodCard.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentMethodCard(
      brand: jsonSerialization['brand'] as String,
      last4: jsonSerialization['last4'] as String,
      expMonth: jsonSerialization['expMonth'] as int,
      expYear: jsonSerialization['expYear'] as int,
      funding: jsonSerialization['funding'] as String?,
      country: jsonSerialization['country'] as String?,
    );
  }

  String brand;

  String last4;

  int expMonth;

  int expYear;

  String? funding;

  String? country;

  /// Returns a shallow copy of this [PaymentMethodCard]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentMethodCard copyWith({
    String? brand,
    String? last4,
    int? expMonth,
    int? expYear,
    String? funding,
    String? country,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentMethodCard',
      'brand': brand,
      'last4': last4,
      'expMonth': expMonth,
      'expYear': expYear,
      if (funding != null) 'funding': funding,
      if (country != null) 'country': country,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentMethodCardImpl extends PaymentMethodCard {
  _PaymentMethodCardImpl({
    required String brand,
    required String last4,
    required int expMonth,
    required int expYear,
    String? funding,
    String? country,
  }) : super._(
         brand: brand,
         last4: last4,
         expMonth: expMonth,
         expYear: expYear,
         funding: funding,
         country: country,
       );

  /// Returns a shallow copy of this [PaymentMethodCard]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentMethodCard copyWith({
    String? brand,
    String? last4,
    int? expMonth,
    int? expYear,
    Object? funding = _Undefined,
    Object? country = _Undefined,
  }) {
    return PaymentMethodCard(
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      funding: funding is String? ? funding : this.funding,
      country: country is String? ? country : this.country,
    );
  }
}

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

/// Represents a physical address of a person or company.
abstract class Address implements _i1.SerializableModel {
  Address._({
    required this.addressLine1,
    this.addressLine2,
    required this.postalCode,
    required this.city,
    this.state,
    required this.country,
  });

  factory Address({
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String? state,
    required String country,
  }) = _AddressImpl;

  factory Address.fromJson(Map<String, dynamic> jsonSerialization) {
    return Address(
      addressLine1: jsonSerialization['addressLine1'] as String,
      addressLine2: jsonSerialization['addressLine2'] as String?,
      postalCode: jsonSerialization['postalCode'] as String,
      city: jsonSerialization['city'] as String,
      state: jsonSerialization['state'] as String?,
      country: jsonSerialization['country'] as String,
    );
  }

  String addressLine1;

  String? addressLine2;

  String postalCode;

  String city;

  String? state;

  String country;

  /// Returns a shallow copy of this [Address]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Address copyWith({
    String? addressLine1,
    String? addressLine2,
    String? postalCode,
    String? city,
    String? state,
    String? country,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      'postalCode': postalCode,
      'city': city,
      if (state != null) 'state': state,
      'country': country,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AddressImpl extends Address {
  _AddressImpl({
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String? state,
    required String country,
  }) : super._(
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          postalCode: postalCode,
          city: city,
          state: state,
          country: country,
        );

  /// Returns a shallow copy of this [Address]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Address copyWith({
    String? addressLine1,
    Object? addressLine2 = _Undefined,
    String? postalCode,
    String? city,
    Object? state = _Undefined,
    String? country,
  }) {
    return Address(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 is String? ? addressLine2 : this.addressLine2,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      state: state is String? ? state : this.state,
      country: country ?? this.country,
    );
  }
}

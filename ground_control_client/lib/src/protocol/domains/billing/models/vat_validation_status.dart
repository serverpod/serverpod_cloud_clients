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

/// Whether the VAT number of billing info is registered with the VAT registry.
enum VatValidationStatus implements _isc.SerializableModel {
  /// No check has given a result yet, or there is no VAT number.
  unchecked,

  /// The VAT registry confirmed that the VAT number is registered.
  valid,

  /// The VAT registry reported that the VAT number is not registered.
  invalid,

  /// The VAT number is from a country that the VAT registry does not check.
  unverifiable;

  static VatValidationStatus fromJson(String name) {
    switch (name) {
      case 'unchecked':
        return VatValidationStatus.unchecked;
      case 'valid':
        return VatValidationStatus.valid;
      case 'invalid':
        return VatValidationStatus.invalid;
      case 'unverifiable':
        return VatValidationStatus.unverifiable;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "VatValidationStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Thrown when billing info lacks a field required to invoice the customer:
/// the address line, postal code, city or country, or for a business the
/// company name. A VAT number is not required.
abstract class BillingInfoIncompleteException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  BillingInfoIncompleteException._({
    required this.message,
    required this.missingFields,
  });

  factory BillingInfoIncompleteException({
    required String message,
    required List<String> missingFields,
  }) = _BillingInfoIncompleteExceptionImpl;

  factory BillingInfoIncompleteException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return BillingInfoIncompleteException(
      message: jsonSerialization['message'] as String,
      missingFields: _iod2a87h.Protocol().deserialize<List<String>>(
        jsonSerialization['missingFields'],
      ),
    );
  }

  String message;

  /// The names of the required fields that are blank: addressLine1,
  /// postalCode, city, country or companyName.
  List<String> missingFields;

  /// Returns a shallow copy of this [BillingInfoIncompleteException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BillingInfoIncompleteException copyWith({
    String? message,
    List<String>? missingFields,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillingInfoIncompleteException',
      'message': message,
      'missingFields': missingFields.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BillingInfoIncompleteException',
      'message': message,
      'missingFields': missingFields.toJson(),
    };
  }

  @override
  String toString() {
    return 'BillingInfoIncompleteException(message: $message, missingFields: $missingFields)';
  }
}

class _BillingInfoIncompleteExceptionImpl
    extends BillingInfoIncompleteException {
  _BillingInfoIncompleteExceptionImpl({
    required String message,
    required List<String> missingFields,
  }) : super._(message: message, missingFields: missingFields);

  /// Returns a shallow copy of this [BillingInfoIncompleteException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BillingInfoIncompleteException copyWith({
    String? message,
    List<String>? missingFields,
  }) {
    return BillingInfoIncompleteException(
      message: message ?? this.message,
      missingFields:
          missingFields ?? this.missingFields.map((e0) => e0).toList(),
    );
  }
}

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

/// Exception thrown when the owner has no customer billing type configured.
abstract class NoCustomerBillingTypeException
    implements _i1.SerializableException, _i1.SerializableModel {
  NoCustomerBillingTypeException._({required this.message});

  factory NoCustomerBillingTypeException({required String message}) =
      _NoCustomerBillingTypeExceptionImpl;

  factory NoCustomerBillingTypeException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return NoCustomerBillingTypeException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [NoCustomerBillingTypeException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NoCustomerBillingTypeException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NoCustomerBillingTypeException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'NoCustomerBillingTypeException(message: $message)';
  }
}

class _NoCustomerBillingTypeExceptionImpl
    extends NoCustomerBillingTypeException {
  _NoCustomerBillingTypeExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [NoCustomerBillingTypeException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NoCustomerBillingTypeException copyWith({String? message}) {
    return NoCustomerBillingTypeException(message: message ?? this.message);
  }
}

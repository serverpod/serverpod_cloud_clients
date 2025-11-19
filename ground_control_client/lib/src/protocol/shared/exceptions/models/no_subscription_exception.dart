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

/// Exception thrown when a user / owner lacks a valid subscription.
abstract class NoSubscriptionException
    implements _i1.SerializableException, _i1.SerializableModel {
  NoSubscriptionException._({required this.message});

  factory NoSubscriptionException({required String message}) =
      _NoSubscriptionExceptionImpl;

  factory NoSubscriptionException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return NoSubscriptionException(
        message: jsonSerialization['message'] as String);
  }

  String message;

  /// Returns a shallow copy of this [NoSubscriptionException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NoSubscriptionException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _NoSubscriptionExceptionImpl extends NoSubscriptionException {
  _NoSubscriptionExceptionImpl({required String message})
      : super._(message: message);

  /// Returns a shallow copy of this [NoSubscriptionException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NoSubscriptionException copyWith({String? message}) {
    return NoSubscriptionException(message: message ?? this.message);
  }
}

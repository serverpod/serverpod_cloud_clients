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

/// Thrown when the live status of a capsule cannot currently be determined,
/// due to a status service failure, network error, or timeout.
/// The operation is safe to retry.
abstract class CapsuleStatusUnavailableException
    implements _i1.SerializableException, _i1.SerializableModel {
  CapsuleStatusUnavailableException._({required this.message});

  factory CapsuleStatusUnavailableException({required String message}) =
      _CapsuleStatusUnavailableExceptionImpl;

  factory CapsuleStatusUnavailableException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CapsuleStatusUnavailableException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [CapsuleStatusUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleStatusUnavailableException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleStatusUnavailableException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'CapsuleStatusUnavailableException(message: $message)';
  }
}

class _CapsuleStatusUnavailableExceptionImpl
    extends CapsuleStatusUnavailableException {
  _CapsuleStatusUnavailableExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [CapsuleStatusUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleStatusUnavailableException copyWith({String? message}) {
    return CapsuleStatusUnavailableException(message: message ?? this.message);
  }
}

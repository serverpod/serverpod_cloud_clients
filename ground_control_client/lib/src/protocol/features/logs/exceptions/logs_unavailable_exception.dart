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

/// Thrown when Cloud Logging is unreachable or returns a server error.
/// The operation is safe to retry.
abstract class LogsUnavailableException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  LogsUnavailableException._({required this.message});

  factory LogsUnavailableException({required String message}) =
      _LogsUnavailableExceptionImpl;

  factory LogsUnavailableException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return LogsUnavailableException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [LogsUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LogsUnavailableException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'LogsUnavailableException', 'message': message};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'LogsUnavailableException', 'message': message};
  }

  @override
  String toString() {
    return 'LogsUnavailableException(message: $message)';
  }
}

class _LogsUnavailableExceptionImpl extends LogsUnavailableException {
  _LogsUnavailableExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [LogsUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LogsUnavailableException copyWith({String? message}) {
    return LogsUnavailableException(message: message ?? this.message);
  }
}

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
import '../../../domains/databases/models/database_status.dart' as _i2;

/// Exception thrown when an operation needs a capsule's database, but the
/// database is still being provisioned, has failed to provision, or has not
/// been requested yet.
abstract class DatabaseNotReadyException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  DatabaseNotReadyException._({required this.status, required this.message});

  factory DatabaseNotReadyException({
    required _i2.DatabaseStatus status,
    required String message,
  }) = _DatabaseNotReadyExceptionImpl;

  factory DatabaseNotReadyException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DatabaseNotReadyException(
      status: _i2.DatabaseStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  _i2.DatabaseStatus status;

  String message;

  /// Returns a shallow copy of this [DatabaseNotReadyException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseNotReadyException copyWith({
    _i2.DatabaseStatus? status,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseNotReadyException',
      'status': status.toJson(),
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseNotReadyException',
      'status': status.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'DatabaseNotReadyException(status: $status, message: $message)';
  }
}

class _DatabaseNotReadyExceptionImpl extends DatabaseNotReadyException {
  _DatabaseNotReadyExceptionImpl({
    required _i2.DatabaseStatus status,
    required String message,
  }) : super._(status: status, message: message);

  /// Returns a shallow copy of this [DatabaseNotReadyException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseNotReadyException copyWith({
    _i2.DatabaseStatus? status,
    String? message,
  }) {
    return DatabaseNotReadyException(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

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

/// Thrown when a manual snapshot cannot be created because the per-project
/// snapshot limit has been reached.
abstract class DatabaseSnapshotLimitException
    implements _i1.SerializableException, _i1.SerializableModel {
  DatabaseSnapshotLimitException._({required this.message});

  factory DatabaseSnapshotLimitException({required String message}) =
      _DatabaseSnapshotLimitExceptionImpl;

  factory DatabaseSnapshotLimitException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DatabaseSnapshotLimitException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [DatabaseSnapshotLimitException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseSnapshotLimitException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseSnapshotLimitException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'DatabaseSnapshotLimitException(message: $message)';
  }
}

class _DatabaseSnapshotLimitExceptionImpl
    extends DatabaseSnapshotLimitException {
  _DatabaseSnapshotLimitExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [DatabaseSnapshotLimitException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseSnapshotLimitException copyWith({String? message}) {
    return DatabaseSnapshotLimitException(message: message ?? this.message);
  }
}

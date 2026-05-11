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

abstract class DatabaseQuota implements _i1.SerializableModel {
  DatabaseQuota._({this.logicalSizeBytes, this.computeTimeSeconds});

  factory DatabaseQuota({int? logicalSizeBytes, int? computeTimeSeconds}) =
      _DatabaseQuotaImpl;

  factory DatabaseQuota.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseQuota(
      logicalSizeBytes: jsonSerialization['logicalSizeBytes'] as int?,
      computeTimeSeconds: jsonSerialization['computeTimeSeconds'] as int?,
    );
  }

  int? logicalSizeBytes;

  int? computeTimeSeconds;

  /// Returns a shallow copy of this [DatabaseQuota]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseQuota copyWith({int? logicalSizeBytes, int? computeTimeSeconds});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseQuota',
      if (logicalSizeBytes != null) 'logicalSizeBytes': logicalSizeBytes,
      if (computeTimeSeconds != null) 'computeTimeSeconds': computeTimeSeconds,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseQuotaImpl extends DatabaseQuota {
  _DatabaseQuotaImpl({int? logicalSizeBytes, int? computeTimeSeconds})
    : super._(
        logicalSizeBytes: logicalSizeBytes,
        computeTimeSeconds: computeTimeSeconds,
      );

  /// Returns a shallow copy of this [DatabaseQuota]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseQuota copyWith({
    Object? logicalSizeBytes = _Undefined,
    Object? computeTimeSeconds = _Undefined,
  }) {
    return DatabaseQuota(
      logicalSizeBytes: logicalSizeBytes is int?
          ? logicalSizeBytes
          : this.logicalSizeBytes,
      computeTimeSeconds: computeTimeSeconds is int?
          ? computeTimeSeconds
          : this.computeTimeSeconds,
    );
  }
}

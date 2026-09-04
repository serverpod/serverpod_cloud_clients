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
import '../../../domains/buckets/models/bucket_access_revocation_reason.dart'
    as _iu6ymjy9;

/// Thrown when an upload is attempted on a bucket whose customer access is
/// revoked by cap enforcement. Reads and deletes remain available so usage
/// can be reduced.
abstract class BucketAccessRevokedException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  BucketAccessRevokedException._({required this.message, this.reason});

  factory BucketAccessRevokedException({
    required String message,
    _iu6ymjy9.BucketAccessRevocationReason? reason,
  }) = _BucketAccessRevokedExceptionImpl;

  factory BucketAccessRevokedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return BucketAccessRevokedException(
      message: jsonSerialization['message'] as String,
      reason: jsonSerialization['reason'] == null
          ? null
          : _iu6ymjy9.BucketAccessRevocationReason.fromJson(
              (jsonSerialization['reason'] as String),
            ),
    );
  }

  String message;

  _iu6ymjy9.BucketAccessRevocationReason? reason;

  /// Returns a shallow copy of this [BucketAccessRevokedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BucketAccessRevokedException copyWith({
    String? message,
    _iu6ymjy9.BucketAccessRevocationReason? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketAccessRevokedException',
      'message': message,
      if (reason != null) 'reason': reason?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BucketAccessRevokedException',
      'message': message,
      if (reason != null) 'reason': reason?.toJson(),
    };
  }

  @override
  String toString() {
    return 'BucketAccessRevokedException(message: $message, reason: $reason)';
  }
}

class _Undefined {}

class _BucketAccessRevokedExceptionImpl extends BucketAccessRevokedException {
  _BucketAccessRevokedExceptionImpl({
    required String message,
    _iu6ymjy9.BucketAccessRevocationReason? reason,
  }) : super._(message: message, reason: reason);

  /// Returns a shallow copy of this [BucketAccessRevokedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BucketAccessRevokedException copyWith({
    String? message,
    Object? reason = _Undefined,
  }) {
    return BucketAccessRevokedException(
      message: message ?? this.message,
      reason: reason is _iu6ymjy9.BucketAccessRevocationReason?
          ? reason
          : this.reason,
    );
  }
}

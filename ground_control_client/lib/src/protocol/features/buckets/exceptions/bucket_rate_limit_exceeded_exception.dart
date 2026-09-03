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

/// Thrown when a capsule has spent its hourly budget for a bucket object
/// operation. [retryAfter] is the time left until the budget is refreshed.
abstract class BucketRateLimitExceededException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  BucketRateLimitExceededException._({
    required this.message,
    required this.retryAfter,
  });

  factory BucketRateLimitExceededException({
    required String message,
    required Duration retryAfter,
  }) = _BucketRateLimitExceededExceptionImpl;

  factory BucketRateLimitExceededException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return BucketRateLimitExceededException(
      message: jsonSerialization['message'] as String,
      retryAfter: _i1.DurationJsonExtension.fromJson(
        jsonSerialization['retryAfter'],
      ),
    );
  }

  String message;

  Duration retryAfter;

  /// Returns a shallow copy of this [BucketRateLimitExceededException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BucketRateLimitExceededException copyWith({
    String? message,
    Duration? retryAfter,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketRateLimitExceededException',
      'message': message,
      'retryAfter': retryAfter.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BucketRateLimitExceededException',
      'message': message,
      'retryAfter': retryAfter.toJson(),
    };
  }

  @override
  String toString() {
    return 'BucketRateLimitExceededException(message: $message, retryAfter: $retryAfter)';
  }
}

class _BucketRateLimitExceededExceptionImpl
    extends BucketRateLimitExceededException {
  _BucketRateLimitExceededExceptionImpl({
    required String message,
    required Duration retryAfter,
  }) : super._(message: message, retryAfter: retryAfter);

  /// Returns a shallow copy of this [BucketRateLimitExceededException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BucketRateLimitExceededException copyWith({
    String? message,
    Duration? retryAfter,
  }) {
    return BucketRateLimitExceededException(
      message: message ?? this.message,
      retryAfter: retryAfter ?? this.retryAfter,
    );
  }
}

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
import '../../../features/billing/exceptions/usage_cap_denied_reason.dart'
    as _irmcg8bl;

/// Thrown by the usage cap methods when the usage cap is not allowed.
abstract class UsageCapDeniedException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  UsageCapDeniedException._({
    required this.message,
    required this.reason,
    this.lowestUsageCapCents,
  });

  factory UsageCapDeniedException({
    required String message,
    required _irmcg8bl.UsageCapDeniedReason reason,
    int? lowestUsageCapCents,
  }) = _UsageCapDeniedExceptionImpl;

  factory UsageCapDeniedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UsageCapDeniedException(
      message: jsonSerialization['message'] as String,
      reason: _irmcg8bl.UsageCapDeniedReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      lowestUsageCapCents: jsonSerialization['lowestUsageCapCents'] as int?,
    );
  }

  /// A description for logs, not for display.
  String message;

  /// Why the usage cap is not allowed.
  _irmcg8bl.UsageCapDeniedReason reason;

  /// The lowest usage cap the subscription can have, in US cents. Null when
  /// its plan has no usage cap.
  int? lowestUsageCapCents;

  /// Returns a shallow copy of this [UsageCapDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UsageCapDeniedException copyWith({
    String? message,
    _irmcg8bl.UsageCapDeniedReason? reason,
    int? lowestUsageCapCents,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UsageCapDeniedException',
      'message': message,
      'reason': reason.toJson(),
      if (lowestUsageCapCents != null)
        'lowestUsageCapCents': lowestUsageCapCents,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UsageCapDeniedException',
      'message': message,
      'reason': reason.toJson(),
      if (lowestUsageCapCents != null)
        'lowestUsageCapCents': lowestUsageCapCents,
    };
  }

  @override
  String toString() {
    return 'UsageCapDeniedException(message: $message, reason: $reason, lowestUsageCapCents: $lowestUsageCapCents)';
  }
}

class _Undefined {}

class _UsageCapDeniedExceptionImpl extends UsageCapDeniedException {
  _UsageCapDeniedExceptionImpl({
    required String message,
    required _irmcg8bl.UsageCapDeniedReason reason,
    int? lowestUsageCapCents,
  }) : super._(
         message: message,
         reason: reason,
         lowestUsageCapCents: lowestUsageCapCents,
       );

  /// Returns a shallow copy of this [UsageCapDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UsageCapDeniedException copyWith({
    String? message,
    _irmcg8bl.UsageCapDeniedReason? reason,
    Object? lowestUsageCapCents = _Undefined,
  }) {
    return UsageCapDeniedException(
      message: message ?? this.message,
      reason: reason ?? this.reason,
      lowestUsageCapCents: lowestUsageCapCents is int?
          ? lowestUsageCapCents
          : this.lowestUsageCapCents,
    );
  }
}

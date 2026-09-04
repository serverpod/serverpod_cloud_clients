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
import '../../../shared/exceptions/models/plan_change_denied_reason.dart'
    as _i7j8a0cd;

/// Exception thrown when a plan change is denied because a feature that is
/// currently in use would be stranded by the new plan.
///
/// For example, moving to a plan that does not provide database backups while
/// backups still exist.
abstract class PlanChangeDeniedException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  PlanChangeDeniedException._({required this.message, required this.reason});

  factory PlanChangeDeniedException({
    required String message,
    required _i7j8a0cd.PlanChangeDeniedReason reason,
  }) = _PlanChangeDeniedExceptionImpl;

  factory PlanChangeDeniedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PlanChangeDeniedException(
      message: jsonSerialization['message'] as String,
      reason: _i7j8a0cd.PlanChangeDeniedReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  String message;

  _i7j8a0cd.PlanChangeDeniedReason reason;

  /// Returns a shallow copy of this [PlanChangeDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlanChangeDeniedException copyWith({
    String? message,
    _i7j8a0cd.PlanChangeDeniedReason? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlanChangeDeniedException',
      'message': message,
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlanChangeDeniedException',
      'message': message,
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'PlanChangeDeniedException(message: $message, reason: $reason)';
  }
}

class _PlanChangeDeniedExceptionImpl extends PlanChangeDeniedException {
  _PlanChangeDeniedExceptionImpl({
    required String message,
    required _i7j8a0cd.PlanChangeDeniedReason reason,
  }) : super._(message: message, reason: reason);

  /// Returns a shallow copy of this [PlanChangeDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlanChangeDeniedException copyWith({
    String? message,
    _i7j8a0cd.PlanChangeDeniedReason? reason,
  }) {
    return PlanChangeDeniedException(
      message: message ?? this.message,
      reason: reason ?? this.reason,
    );
  }
}

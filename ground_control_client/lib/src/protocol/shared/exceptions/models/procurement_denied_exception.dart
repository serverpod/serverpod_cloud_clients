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
import '../../../shared/exceptions/models/procurement_denied_reason.dart'
    as _i2;

/// Exception thrown when a procurement is denied to the user / organization
/// due to insufficient allowance or other subscription limits.
///
/// This is distinct from access authorization, and from quota limits.
abstract class ProcurementDeniedException
    implements _i1.SerializableException, _i1.SerializableModel {
  ProcurementDeniedException._({required this.message, required this.reason});

  factory ProcurementDeniedException({
    required String message,
    required _i2.ProcurementDeniedReason reason,
  }) = _ProcurementDeniedExceptionImpl;

  factory ProcurementDeniedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ProcurementDeniedException(
      message: jsonSerialization['message'] as String,
      reason: _i2.ProcurementDeniedReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  String message;

  _i2.ProcurementDeniedReason reason;

  /// Returns a shallow copy of this [ProcurementDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProcurementDeniedException copyWith({
    String? message,
    _i2.ProcurementDeniedReason? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProcurementDeniedException',
      'message': message,
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProcurementDeniedException(message: $message, reason: $reason)';
  }
}

class _ProcurementDeniedExceptionImpl extends ProcurementDeniedException {
  _ProcurementDeniedExceptionImpl({
    required String message,
    required _i2.ProcurementDeniedReason reason,
  }) : super._(message: message, reason: reason);

  /// Returns a shallow copy of this [ProcurementDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProcurementDeniedException copyWith({
    String? message,
    _i2.ProcurementDeniedReason? reason,
  }) {
    return ProcurementDeniedException(
      message: message ?? this.message,
      reason: reason ?? this.reason,
    );
  }
}

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
import '../../../features/billing/exceptions/voucher_redemption_denied_reason.dart'
    as _i0wuhqmn;

/// Thrown by redeemVoucher when the voucher is not redeemed.
abstract class VoucherRedemptionDeniedException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  VoucherRedemptionDeniedException._({
    required this.message,
    required this.reason,
  });

  factory VoucherRedemptionDeniedException({
    required String message,
    required _i0wuhqmn.VoucherRedemptionDeniedReason reason,
  }) = _VoucherRedemptionDeniedExceptionImpl;

  factory VoucherRedemptionDeniedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return VoucherRedemptionDeniedException(
      message: jsonSerialization['message'] as String,
      reason: _i0wuhqmn.VoucherRedemptionDeniedReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  /// A description for logs, not for display.
  String message;

  /// Why the voucher was not redeemed.
  _i0wuhqmn.VoucherRedemptionDeniedReason reason;

  /// Returns a shallow copy of this [VoucherRedemptionDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  VoucherRedemptionDeniedException copyWith({
    String? message,
    _i0wuhqmn.VoucherRedemptionDeniedReason? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VoucherRedemptionDeniedException',
      'message': message,
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VoucherRedemptionDeniedException',
      'message': message,
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'VoucherRedemptionDeniedException(message: $message, reason: $reason)';
  }
}

class _VoucherRedemptionDeniedExceptionImpl
    extends VoucherRedemptionDeniedException {
  _VoucherRedemptionDeniedExceptionImpl({
    required String message,
    required _i0wuhqmn.VoucherRedemptionDeniedReason reason,
  }) : super._(message: message, reason: reason);

  /// Returns a shallow copy of this [VoucherRedemptionDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  VoucherRedemptionDeniedException copyWith({
    String? message,
    _i0wuhqmn.VoucherRedemptionDeniedReason? reason,
  }) {
    return VoucherRedemptionDeniedException(
      message: message ?? this.message,
      reason: reason ?? this.reason,
    );
  }
}

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

/// Why a voucher was not redeemed.
enum VoucherRedemptionDeniedReason implements _isc.SerializableModel {
  /// No voucher has the code.
  notFound,

  /// The voucher is past its deadline.
  expired,

  /// The voucher has been redeemed as many times as it allows in total.
  fullyRedeemed,

  /// The voucher was withdrawn.
  archived,

  /// The account has redeemed the voucher as many times as it allows.
  alreadyRedeemed,

  /// The billing system did not confirm the credit. The voucher is not
  /// counted as redeemed.
  grantFailed;

  static VoucherRedemptionDeniedReason fromJson(String name) {
    switch (name) {
      case 'notFound':
        return VoucherRedemptionDeniedReason.notFound;
      case 'expired':
        return VoucherRedemptionDeniedReason.expired;
      case 'fullyRedeemed':
        return VoucherRedemptionDeniedReason.fullyRedeemed;
      case 'archived':
        return VoucherRedemptionDeniedReason.archived;
      case 'alreadyRedeemed':
        return VoucherRedemptionDeniedReason.alreadyRedeemed;
      case 'grantFailed':
        return VoucherRedemptionDeniedReason.grantFailed;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "VoucherRedemptionDeniedReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

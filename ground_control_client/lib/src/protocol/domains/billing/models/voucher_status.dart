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

/// Whether a voucher can be redeemed.
enum VoucherStatus implements _isc.SerializableModel {
  /// The voucher can be redeemed.
  active,

  /// The voucher is past its deadline or its latest credit expiry, or at its
  /// maximum redemptions.
  closed,

  /// An admin stopped the voucher. This cannot be undone.
  archived;

  static VoucherStatus fromJson(String name) {
    switch (name) {
      case 'active':
        return VoucherStatus.active;
      case 'closed':
        return VoucherStatus.closed;
      case 'archived':
        return VoucherStatus.archived;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "VoucherStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

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

/// What happened to a voucher, as published on the `voucher` topic.
enum VoucherCause implements _isc.SerializableModel {
  /// The voucher was created.
  created,

  /// The voucher was archived, which stops new redemptions.
  archived,

  /// The voucher was redeemed and its credit was granted.
  redeemed;

  static VoucherCause fromJson(String name) {
    switch (name) {
      case 'created':
        return VoucherCause.created;
      case 'archived':
        return VoucherCause.archived;
      case 'redeemed':
        return VoucherCause.redeemed;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "VoucherCause"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

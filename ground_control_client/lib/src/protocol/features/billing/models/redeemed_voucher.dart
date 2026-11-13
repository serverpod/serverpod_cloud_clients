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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// The credit that an owner received for redeeming a voucher.
abstract class RedeemedVoucher
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RedeemedVoucher._({
    required this.code,
    required this.name,
    required this.creditAmountCents,
    required this.paysForItemIds,
    this.creditExpiresAt,
  });

  factory RedeemedVoucher({
    required String code,
    required String name,
    required int creditAmountCents,
    required List<String> paysForItemIds,
    DateTime? creditExpiresAt,
  }) = _RedeemedVoucherImpl;

  factory RedeemedVoucher.fromJson(Map<String, dynamic> jsonSerialization) {
    return RedeemedVoucher(
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      creditAmountCents: jsonSerialization['creditAmountCents'] as int,
      paysForItemIds: _iod2a87h.Protocol().deserialize<List<String>>(
        jsonSerialization['paysForItemIds'],
      ),
      creditExpiresAt: jsonSerialization['creditExpiresAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['creditExpiresAt'],
            ),
    );
  }

  /// The code of the voucher.
  String code;

  /// The display name of the voucher.
  String name;

  /// The granted credit, in US cents.
  int creditAmountCents;

  /// The names of the billing items the credit pays. Empty when it pays all
  /// items.
  List<String> paysForItemIds;

  /// When the credit expires. Null when it never expires.
  DateTime? creditExpiresAt;

  /// Returns a shallow copy of this [RedeemedVoucher]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RedeemedVoucher copyWith({
    String? code,
    String? name,
    int? creditAmountCents,
    List<String>? paysForItemIds,
    DateTime? creditExpiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RedeemedVoucher',
      'code': code,
      'name': name,
      'creditAmountCents': creditAmountCents,
      'paysForItemIds': paysForItemIds.toJson(),
      if (creditExpiresAt != null) 'creditExpiresAt': creditExpiresAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RedeemedVoucher',
      'code': code,
      'name': name,
      'creditAmountCents': creditAmountCents,
      'paysForItemIds': paysForItemIds.toJson(),
      if (creditExpiresAt != null) 'creditExpiresAt': creditExpiresAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RedeemedVoucherImpl extends RedeemedVoucher {
  _RedeemedVoucherImpl({
    required String code,
    required String name,
    required int creditAmountCents,
    required List<String> paysForItemIds,
    DateTime? creditExpiresAt,
  }) : super._(
         code: code,
         name: name,
         creditAmountCents: creditAmountCents,
         paysForItemIds: paysForItemIds,
         creditExpiresAt: creditExpiresAt,
       );

  /// Returns a shallow copy of this [RedeemedVoucher]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RedeemedVoucher copyWith({
    String? code,
    String? name,
    int? creditAmountCents,
    List<String>? paysForItemIds,
    Object? creditExpiresAt = _Undefined,
  }) {
    return RedeemedVoucher(
      code: code ?? this.code,
      name: name ?? this.name,
      creditAmountCents: creditAmountCents ?? this.creditAmountCents,
      paysForItemIds:
          paysForItemIds ?? this.paysForItemIds.map((e0) => e0).toList(),
      creditExpiresAt: creditExpiresAt is DateTime?
          ? creditExpiresAt
          : this.creditExpiresAt,
    );
  }
}

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
import '../../../domains/billing/models/voucher_status.dart' as _ikjhi7mh;

/// A voucher as an administrator sees it, with how many times it has been
/// redeemed.
abstract class AdminVoucher
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminVoucher._({
    required this.code,
    required this.name,
    required this.creditAmountCents,
    required this.paysForItemIds,
    this.redeemableUntil,
    this.creditLifetimeDays,
    this.creditExpiresBy,
    this.maxRedemptions,
    required this.maxRedemptionsPerOwner,
    required this.status,
    required this.redemptionCount,
    required this.createdAt,
    this.archivedAt,
  });

  factory AdminVoucher({
    required String code,
    required String name,
    required int creditAmountCents,
    required List<String> paysForItemIds,
    DateTime? redeemableUntil,
    int? creditLifetimeDays,
    DateTime? creditExpiresBy,
    int? maxRedemptions,
    required int maxRedemptionsPerOwner,
    required _ikjhi7mh.VoucherStatus status,
    required int redemptionCount,
    required DateTime createdAt,
    DateTime? archivedAt,
  }) = _AdminVoucherImpl;

  factory AdminVoucher.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminVoucher(
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      creditAmountCents: jsonSerialization['creditAmountCents'] as int,
      paysForItemIds: _iod2a87h.Protocol().deserialize<List<String>>(
        jsonSerialization['paysForItemIds'],
      ),
      redeemableUntil: jsonSerialization['redeemableUntil'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['redeemableUntil'],
            ),
      creditLifetimeDays: jsonSerialization['creditLifetimeDays'] as int?,
      creditExpiresBy: jsonSerialization['creditExpiresBy'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['creditExpiresBy'],
            ),
      maxRedemptions: jsonSerialization['maxRedemptions'] as int?,
      maxRedemptionsPerOwner:
          jsonSerialization['maxRedemptionsPerOwner'] as int,
      status: _ikjhi7mh.VoucherStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      redemptionCount: jsonSerialization['redemptionCount'] as int,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedAt'],
            ),
    );
  }

  /// The code that owners enter to redeem the voucher.
  String code;

  /// The display name of the voucher.
  String name;

  /// The credit granted per redemption, in US cents.
  int creditAmountCents;

  /// The names of the billing items the credit pays. Empty when it pays all
  /// items.
  List<String> paysForItemIds;

  /// The last moment the voucher can be redeemed. Null when it has no
  /// deadline.
  DateTime? redeemableUntil;

  /// How many days the credit lasts after a redemption. Null when the
  /// lifetime is not limited.
  int? creditLifetimeDays;

  /// The latest moment the credit expires, whenever it is redeemed. Null
  /// when there is none.
  DateTime? creditExpiresBy;

  /// How many times the voucher can be redeemed in total. Null when the
  /// total is not limited.
  int? maxRedemptions;

  /// How many times one owner can redeem the voucher.
  int maxRedemptionsPerOwner;

  /// Whether the voucher can be redeemed.
  _ikjhi7mh.VoucherStatus status;

  /// How many times the voucher has been redeemed.
  int redemptionCount;

  /// When the voucher was created.
  DateTime createdAt;

  /// When the voucher was archived. Null while it is not archived.
  DateTime? archivedAt;

  /// Returns a shallow copy of this [AdminVoucher]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminVoucher copyWith({
    String? code,
    String? name,
    int? creditAmountCents,
    List<String>? paysForItemIds,
    DateTime? redeemableUntil = const _isc.$UndefinedDateTime(),
    int? creditLifetimeDays,
    DateTime? creditExpiresBy = const _isc.$UndefinedDateTime(),
    int? maxRedemptions,
    int? maxRedemptionsPerOwner,
    _ikjhi7mh.VoucherStatus? status,
    int? redemptionCount,
    DateTime? createdAt,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminVoucher',
      'code': code,
      'name': name,
      'creditAmountCents': creditAmountCents,
      'paysForItemIds': paysForItemIds.toJson(),
      if (redeemableUntil != null) 'redeemableUntil': redeemableUntil?.toJson(),
      if (creditLifetimeDays != null) 'creditLifetimeDays': creditLifetimeDays,
      if (creditExpiresBy != null) 'creditExpiresBy': creditExpiresBy?.toJson(),
      if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
      'maxRedemptionsPerOwner': maxRedemptionsPerOwner,
      'status': status.toJson(),
      'redemptionCount': redemptionCount,
      'createdAt': createdAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminVoucher',
      'code': code,
      'name': name,
      'creditAmountCents': creditAmountCents,
      'paysForItemIds': paysForItemIds.toJson(),
      if (redeemableUntil != null) 'redeemableUntil': redeemableUntil?.toJson(),
      if (creditLifetimeDays != null) 'creditLifetimeDays': creditLifetimeDays,
      if (creditExpiresBy != null) 'creditExpiresBy': creditExpiresBy?.toJson(),
      if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
      'maxRedemptionsPerOwner': maxRedemptionsPerOwner,
      'status': status.toJson(),
      'redemptionCount': redemptionCount,
      'createdAt': createdAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminVoucherImpl extends AdminVoucher {
  _AdminVoucherImpl({
    required String code,
    required String name,
    required int creditAmountCents,
    required List<String> paysForItemIds,
    DateTime? redeemableUntil,
    int? creditLifetimeDays,
    DateTime? creditExpiresBy,
    int? maxRedemptions,
    required int maxRedemptionsPerOwner,
    required _ikjhi7mh.VoucherStatus status,
    required int redemptionCount,
    required DateTime createdAt,
    DateTime? archivedAt,
  }) : super._(
         code: code,
         name: name,
         creditAmountCents: creditAmountCents,
         paysForItemIds: paysForItemIds,
         redeemableUntil: redeemableUntil,
         creditLifetimeDays: creditLifetimeDays,
         creditExpiresBy: creditExpiresBy,
         maxRedemptions: maxRedemptions,
         maxRedemptionsPerOwner: maxRedemptionsPerOwner,
         status: status,
         redemptionCount: redemptionCount,
         createdAt: createdAt,
         archivedAt: archivedAt,
       );

  /// Returns a shallow copy of this [AdminVoucher]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminVoucher copyWith({
    String? code,
    String? name,
    int? creditAmountCents,
    List<String>? paysForItemIds,
    DateTime? redeemableUntil = const _isc.$UndefinedDateTime(),
    Object? creditLifetimeDays = _Undefined,
    DateTime? creditExpiresBy = const _isc.$UndefinedDateTime(),
    Object? maxRedemptions = _Undefined,
    int? maxRedemptionsPerOwner,
    _ikjhi7mh.VoucherStatus? status,
    int? redemptionCount,
    DateTime? createdAt,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
  }) {
    return AdminVoucher(
      code: code ?? this.code,
      name: name ?? this.name,
      creditAmountCents: creditAmountCents ?? this.creditAmountCents,
      paysForItemIds:
          paysForItemIds ?? this.paysForItemIds.map((e0) => e0).toList(),
      redeemableUntil: redeemableUntil is _isc.UndefinedSentinel
          ? this.redeemableUntil
          : redeemableUntil,
      creditLifetimeDays: creditLifetimeDays is int?
          ? creditLifetimeDays
          : this.creditLifetimeDays,
      creditExpiresBy: creditExpiresBy is _isc.UndefinedSentinel
          ? this.creditExpiresBy
          : creditExpiresBy,
      maxRedemptions: maxRedemptions is int?
          ? maxRedemptions
          : this.maxRedemptions,
      maxRedemptionsPerOwner:
          maxRedemptionsPerOwner ?? this.maxRedemptionsPerOwner,
      status: status ?? this.status,
      redemptionCount: redemptionCount ?? this.redemptionCount,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt is _isc.UndefinedSentinel
          ? this.archivedAt
          : archivedAt,
    );
  }
}

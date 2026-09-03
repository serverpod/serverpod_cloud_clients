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
import '../../../domains/products/models/product_type.dart' as _i2;
import '../../../domains/orders/models/order_origin.dart' as _i3;
import '../../../domains/orders/models/order_kind.dart' as _i4;

/// An intent that a resource meet a goal.
abstract class Order
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Order._({
    _i1.UuidValue? id,
    DateTime? createdAt,
    this.archivedAt,
    this.fulfilledAt,
    this.parentId,
    required this.ownerId,
    required this.productType,
    required this.origin,
    required this.kind,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory Order({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? archivedAt,
    DateTime? fulfilledAt,
    _i1.UuidValue? parentId,
    required _i1.UuidValue ownerId,
    required _i2.ProductType productType,
    required _i3.OrderOrigin origin,
    required _i4.OrderKind kind,
  }) = _OrderImpl;

  factory Order.fromJson(Map<String, dynamic> jsonSerialization) {
    return Order(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      fulfilledAt: jsonSerialization['fulfilledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['fulfilledAt'],
            ),
      parentId: jsonSerialization['parentId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['parentId']),
      ownerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      productType: _i2.ProductType.fromJson(
        (jsonSerialization['productType'] as String),
      ),
      origin: _i3.OrderOrigin.fromJson((jsonSerialization['origin'] as String)),
      kind: _i4.OrderKind.fromJson((jsonSerialization['kind'] as String)),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  DateTime createdAt;

  DateTime? archivedAt;

  /// Cached fold of events. Null means unfulfilled.
  DateTime? fulfilledAt;

  _i1.UuidValue? parentId;

  _i1.UuidValue ownerId;

  _i2.ProductType productType;

  _i3.OrderOrigin origin;

  _i4.OrderKind kind;

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Order copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? archivedAt,
    DateTime? fulfilledAt,
    _i1.UuidValue? parentId,
    _i1.UuidValue? ownerId,
    _i2.ProductType? productType,
    _i3.OrderOrigin? origin,
    _i4.OrderKind? kind,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Order',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      if (fulfilledAt != null) 'fulfilledAt': fulfilledAt?.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'ownerId': ownerId.toJson(),
      'productType': productType.toJson(),
      'origin': origin.toJson(),
      'kind': kind.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Order',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      if (fulfilledAt != null) 'fulfilledAt': fulfilledAt?.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'ownerId': ownerId.toJson(),
      'productType': productType.toJson(),
      'origin': origin.toJson(),
      'kind': kind.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderImpl extends Order {
  _OrderImpl({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? archivedAt,
    DateTime? fulfilledAt,
    _i1.UuidValue? parentId,
    required _i1.UuidValue ownerId,
    required _i2.ProductType productType,
    required _i3.OrderOrigin origin,
    required _i4.OrderKind kind,
  }) : super._(
         id: id,
         createdAt: createdAt,
         archivedAt: archivedAt,
         fulfilledAt: fulfilledAt,
         parentId: parentId,
         ownerId: ownerId,
         productType: productType,
         origin: origin,
         kind: kind,
       );

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Order copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    Object? archivedAt = _Undefined,
    Object? fulfilledAt = _Undefined,
    Object? parentId = _Undefined,
    _i1.UuidValue? ownerId,
    _i2.ProductType? productType,
    _i3.OrderOrigin? origin,
    _i4.OrderKind? kind,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      fulfilledAt: fulfilledAt is DateTime? ? fulfilledAt : this.fulfilledAt,
      parentId: parentId is _i1.UuidValue? ? parentId : this.parentId,
      ownerId: ownerId ?? this.ownerId,
      productType: productType ?? this.productType,
      origin: origin ?? this.origin,
      kind: kind ?? this.kind,
    );
  }
}

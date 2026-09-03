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
import '../../../domains/orders/models/order_tree.dart' as _i5;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i6;

/// Order-domain tree returned by get(). No placing-domain Goal payloads.
abstract class OrderTree
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  OrderTree._({
    required this.id,
    this.parentId,
    required this.ownerId,
    required this.productType,
    required this.origin,
    required this.kind,
    required this.fulfilled,
    this.archivedAt,
    required this.children,
  });

  factory OrderTree({
    required _i1.UuidValue id,
    _i1.UuidValue? parentId,
    required _i1.UuidValue ownerId,
    required _i2.ProductType productType,
    required _i3.OrderOrigin origin,
    required _i4.OrderKind kind,
    required bool fulfilled,
    DateTime? archivedAt,
    required List<_i5.OrderTree> children,
  }) = _OrderTreeImpl;

  factory OrderTree.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderTree(
      id: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
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
      fulfilled: _i1.BoolJsonExtension.fromJson(jsonSerialization['fulfilled']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      children: _i6.Protocol().deserialize<List<_i5.OrderTree>>(
        jsonSerialization['children'],
      ),
    );
  }

  _i1.UuidValue id;

  _i1.UuidValue? parentId;

  _i1.UuidValue ownerId;

  _i2.ProductType productType;

  _i3.OrderOrigin origin;

  _i4.OrderKind kind;

  bool fulfilled;

  DateTime? archivedAt;

  List<_i5.OrderTree> children;

  /// Returns a shallow copy of this [OrderTree]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderTree copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? parentId,
    _i1.UuidValue? ownerId,
    _i2.ProductType? productType,
    _i3.OrderOrigin? origin,
    _i4.OrderKind? kind,
    bool? fulfilled,
    DateTime? archivedAt,
    List<_i5.OrderTree>? children,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderTree',
      'id': id.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'ownerId': ownerId.toJson(),
      'productType': productType.toJson(),
      'origin': origin.toJson(),
      'kind': kind.toJson(),
      'fulfilled': fulfilled,
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'children': children.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrderTree',
      'id': id.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'ownerId': ownerId.toJson(),
      'productType': productType.toJson(),
      'origin': origin.toJson(),
      'kind': kind.toJson(),
      'fulfilled': fulfilled,
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'children': children.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderTreeImpl extends OrderTree {
  _OrderTreeImpl({
    required _i1.UuidValue id,
    _i1.UuidValue? parentId,
    required _i1.UuidValue ownerId,
    required _i2.ProductType productType,
    required _i3.OrderOrigin origin,
    required _i4.OrderKind kind,
    required bool fulfilled,
    DateTime? archivedAt,
    required List<_i5.OrderTree> children,
  }) : super._(
         id: id,
         parentId: parentId,
         ownerId: ownerId,
         productType: productType,
         origin: origin,
         kind: kind,
         fulfilled: fulfilled,
         archivedAt: archivedAt,
         children: children,
       );

  /// Returns a shallow copy of this [OrderTree]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderTree copyWith({
    _i1.UuidValue? id,
    Object? parentId = _Undefined,
    _i1.UuidValue? ownerId,
    _i2.ProductType? productType,
    _i3.OrderOrigin? origin,
    _i4.OrderKind? kind,
    bool? fulfilled,
    Object? archivedAt = _Undefined,
    List<_i5.OrderTree>? children,
  }) {
    return OrderTree(
      id: id ?? this.id,
      parentId: parentId is _i1.UuidValue? ? parentId : this.parentId,
      ownerId: ownerId ?? this.ownerId,
      productType: productType ?? this.productType,
      origin: origin ?? this.origin,
      kind: kind ?? this.kind,
      fulfilled: fulfilled ?? this.fulfilled,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      children: children ?? this.children.map((e0) => e0.copyWith()).toList(),
    );
  }
}

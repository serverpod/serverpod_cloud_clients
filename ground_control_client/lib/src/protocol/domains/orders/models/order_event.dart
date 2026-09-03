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
import '../../../domains/orders/models/order.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

/// A fact that may change an Order's fulfillment status.
abstract class OrderEvent
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  OrderEvent._({
    _i1.UuidValue? id,
    DateTime? createdAt,
    required this.orderId,
    this.order,
    this.resourceNote,
    this.childEventId,
    this.supersedingOrderId,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory OrderEvent({
    _i1.UuidValue? id,
    DateTime? createdAt,
    required _i1.UuidValue orderId,
    _i2.Order? order,
    String? resourceNote,
    _i1.UuidValue? childEventId,
    _i1.UuidValue? supersedingOrderId,
  }) = _OrderEventImpl;

  factory OrderEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      orderId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['orderId'],
      ),
      order: jsonSerialization['order'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Order>(jsonSerialization['order']),
      resourceNote: jsonSerialization['resourceNote'] as String?,
      childEventId: jsonSerialization['childEventId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['childEventId'],
            ),
      supersedingOrderId: jsonSerialization['supersedingOrderId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['supersedingOrderId'],
            ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  DateTime createdAt;

  _i1.UuidValue orderId;

  _i2.Order? order;

  /// Exactly one of resourceNote, childEventId, supersedingOrderId is set.
  String? resourceNote;

  _i1.UuidValue? childEventId;

  _i1.UuidValue? supersedingOrderId;

  /// Returns a shallow copy of this [OrderEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderEvent copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    _i1.UuidValue? orderId,
    _i2.Order? order,
    String? resourceNote,
    _i1.UuidValue? childEventId,
    _i1.UuidValue? supersedingOrderId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderEvent',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'orderId': orderId.toJson(),
      if (order != null) 'order': order?.toJson(),
      if (resourceNote != null) 'resourceNote': resourceNote,
      if (childEventId != null) 'childEventId': childEventId?.toJson(),
      if (supersedingOrderId != null)
        'supersedingOrderId': supersedingOrderId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrderEvent',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'orderId': orderId.toJson(),
      if (order != null) 'order': order?.toJsonForProtocol(),
      if (resourceNote != null) 'resourceNote': resourceNote,
      if (childEventId != null) 'childEventId': childEventId?.toJson(),
      if (supersedingOrderId != null)
        'supersedingOrderId': supersedingOrderId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderEventImpl extends OrderEvent {
  _OrderEventImpl({
    _i1.UuidValue? id,
    DateTime? createdAt,
    required _i1.UuidValue orderId,
    _i2.Order? order,
    String? resourceNote,
    _i1.UuidValue? childEventId,
    _i1.UuidValue? supersedingOrderId,
  }) : super._(
         id: id,
         createdAt: createdAt,
         orderId: orderId,
         order: order,
         resourceNote: resourceNote,
         childEventId: childEventId,
         supersedingOrderId: supersedingOrderId,
       );

  /// Returns a shallow copy of this [OrderEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderEvent copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    _i1.UuidValue? orderId,
    Object? order = _Undefined,
    Object? resourceNote = _Undefined,
    Object? childEventId = _Undefined,
    Object? supersedingOrderId = _Undefined,
  }) {
    return OrderEvent(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      order: order is _i2.Order? ? order : this.order?.copyWith(),
      resourceNote: resourceNote is String? ? resourceNote : this.resourceNote,
      childEventId: childEventId is _i1.UuidValue?
          ? childEventId
          : this.childEventId,
      supersedingOrderId: supersedingOrderId is _i1.UuidValue?
          ? supersedingOrderId
          : this.supersedingOrderId,
    );
  }
}

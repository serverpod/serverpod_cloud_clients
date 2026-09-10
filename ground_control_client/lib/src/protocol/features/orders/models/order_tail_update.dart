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
import '../../../domains/orders/models/order_event.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

/// One tail message: the first has no event (current folded status only).
abstract class OrderTailUpdate
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  OrderTailUpdate._({required this.fulfilled, this.event});

  factory OrderTailUpdate({required bool fulfilled, _i2.OrderEvent? event}) =
      _OrderTailUpdateImpl;

  factory OrderTailUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderTailUpdate(
      fulfilled: _i1.BoolJsonExtension.fromJson(jsonSerialization['fulfilled']),
      event: jsonSerialization['event'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.OrderEvent>(
              jsonSerialization['event'],
            ),
    );
  }

  bool fulfilled;

  _i2.OrderEvent? event;

  /// Returns a shallow copy of this [OrderTailUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderTailUpdate copyWith({bool? fulfilled, _i2.OrderEvent? event});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderTailUpdate',
      'fulfilled': fulfilled,
      if (event != null) 'event': event?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrderTailUpdate',
      'fulfilled': fulfilled,
      if (event != null) 'event': event?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderTailUpdateImpl extends OrderTailUpdate {
  _OrderTailUpdateImpl({required bool fulfilled, _i2.OrderEvent? event})
    : super._(fulfilled: fulfilled, event: event);

  /// Returns a shallow copy of this [OrderTailUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderTailUpdate copyWith({bool? fulfilled, Object? event = _Undefined}) {
    return OrderTailUpdate(
      fulfilled: fulfilled ?? this.fulfilled,
      event: event is _i2.OrderEvent? ? event : this.event?.copyWith(),
    );
  }
}

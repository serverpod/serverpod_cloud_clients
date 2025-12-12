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
import '../../../domains/billing/models/payment_method_card.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

abstract class PaymentMethod implements _i1.SerializableModel {
  PaymentMethod._({required this.id, required this.type, this.card});

  factory PaymentMethod({
    required String id,
    required String type,
    _i2.PaymentMethodCard? card,
  }) = _PaymentMethodImpl;

  factory PaymentMethod.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentMethod(
      id: jsonSerialization['id'] as String,
      type: jsonSerialization['type'] as String,
      card: jsonSerialization['card'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.PaymentMethodCard>(
              jsonSerialization['card'],
            ),
    );
  }

  String id;

  String type;

  _i2.PaymentMethodCard? card;

  /// Returns a shallow copy of this [PaymentMethod]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentMethod copyWith({
    String? id,
    String? type,
    _i2.PaymentMethodCard? card,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentMethod',
      'id': id,
      'type': type,
      if (card != null) 'card': card?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentMethodImpl extends PaymentMethod {
  _PaymentMethodImpl({
    required String id,
    required String type,
    _i2.PaymentMethodCard? card,
  }) : super._(id: id, type: type, card: card);

  /// Returns a shallow copy of this [PaymentMethod]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentMethod copyWith({
    String? id,
    String? type,
    Object? card = _Undefined,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      card: card is _i2.PaymentMethodCard? ? card : this.card?.copyWith(),
    );
  }
}

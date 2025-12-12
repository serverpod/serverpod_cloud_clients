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

abstract class PaymentSetupIntent implements _i1.SerializableModel {
  PaymentSetupIntent._({
    required this.id,
    required this.clientSecret,
    required this.status,
  });

  factory PaymentSetupIntent({
    required String id,
    required String clientSecret,
    required String status,
  }) = _PaymentSetupIntentImpl;

  factory PaymentSetupIntent.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentSetupIntent(
      id: jsonSerialization['id'] as String,
      clientSecret: jsonSerialization['clientSecret'] as String,
      status: jsonSerialization['status'] as String,
    );
  }

  String id;

  String clientSecret;

  String status;

  /// Returns a shallow copy of this [PaymentSetupIntent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentSetupIntent copyWith({
    String? id,
    String? clientSecret,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentSetupIntent',
      'id': id,
      'clientSecret': clientSecret,
      'status': status,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaymentSetupIntentImpl extends PaymentSetupIntent {
  _PaymentSetupIntentImpl({
    required String id,
    required String clientSecret,
    required String status,
  }) : super._(id: id, clientSecret: clientSecret, status: status);

  /// Returns a shallow copy of this [PaymentSetupIntent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentSetupIntent copyWith({
    String? id,
    String? clientSecret,
    String? status,
  }) {
    return PaymentSetupIntent(
      id: id ?? this.id,
      clientSecret: clientSecret ?? this.clientSecret,
      status: status ?? this.status,
    );
  }
}

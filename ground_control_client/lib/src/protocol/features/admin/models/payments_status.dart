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

abstract class PaymentsStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PaymentsStatus._({
    required this.invoiceId,
    required this.dueDate,
    required this.dueAmount,
    required this.outstandingAmount,
  });

  factory PaymentsStatus({
    required String invoiceId,
    required DateTime dueDate,
    required String dueAmount,
    required String outstandingAmount,
  }) = _PaymentsStatusImpl;

  factory PaymentsStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentsStatus(
      invoiceId: jsonSerialization['invoiceId'] as String,
      dueDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['dueDate'],
      ),
      dueAmount: jsonSerialization['dueAmount'] as String,
      outstandingAmount: jsonSerialization['outstandingAmount'] as String,
    );
  }

  String invoiceId;

  DateTime dueDate;

  String dueAmount;

  String outstandingAmount;

  /// Returns a shallow copy of this [PaymentsStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PaymentsStatus copyWith({
    String? invoiceId,
    DateTime? dueDate,
    String? dueAmount,
    String? outstandingAmount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentsStatus',
      'invoiceId': invoiceId,
      'dueDate': dueDate.toJson(),
      'dueAmount': dueAmount,
      'outstandingAmount': outstandingAmount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PaymentsStatus',
      'invoiceId': invoiceId,
      'dueDate': dueDate.toJson(),
      'dueAmount': dueAmount,
      'outstandingAmount': outstandingAmount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PaymentsStatusImpl extends PaymentsStatus {
  _PaymentsStatusImpl({
    required String invoiceId,
    required DateTime dueDate,
    required String dueAmount,
    required String outstandingAmount,
  }) : super._(
         invoiceId: invoiceId,
         dueDate: dueDate,
         dueAmount: dueAmount,
         outstandingAmount: outstandingAmount,
       );

  /// Returns a shallow copy of this [PaymentsStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PaymentsStatus copyWith({
    String? invoiceId,
    DateTime? dueDate,
    String? dueAmount,
    String? outstandingAmount,
  }) {
    return PaymentsStatus(
      invoiceId: invoiceId ?? this.invoiceId,
      dueDate: dueDate ?? this.dueDate,
      dueAmount: dueAmount ?? this.dueAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
    );
  }
}

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
import '../../../features/admin/models/payments_invoice_status.dart' as _i2;

abstract class PaymentsStatus
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PaymentsStatus._({
    required this.invoiceId,
    required this.dueDate,
    required this.dueAmount,
    required this.outstandingAmount,
    required this.status,
  });

  factory PaymentsStatus({
    required String invoiceId,
    required DateTime dueDate,
    required String dueAmount,
    required String outstandingAmount,
    required _i2.PaymentsInvoiceStatus status,
  }) = _PaymentsStatusImpl;

  factory PaymentsStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentsStatus(
      invoiceId: jsonSerialization['invoiceId'] as String,
      dueDate: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      dueAmount: jsonSerialization['dueAmount'] as String,
      outstandingAmount: jsonSerialization['outstandingAmount'] as String,
      status: _i2.PaymentsInvoiceStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
    );
  }

  String invoiceId;

  DateTime dueDate;

  String dueAmount;

  String outstandingAmount;

  /// Whether the invoice is issued or still needs action in Orb.
  _i2.PaymentsInvoiceStatus status;

  /// Returns a shallow copy of this [PaymentsStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentsStatus copyWith({
    String? invoiceId,
    DateTime? dueDate,
    String? dueAmount,
    String? outstandingAmount,
    _i2.PaymentsInvoiceStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentsStatus',
      'invoiceId': invoiceId,
      'dueDate': dueDate.toJson(),
      'dueAmount': dueAmount,
      'outstandingAmount': outstandingAmount,
      'status': status.toJson(),
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
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaymentsStatusImpl extends PaymentsStatus {
  _PaymentsStatusImpl({
    required String invoiceId,
    required DateTime dueDate,
    required String dueAmount,
    required String outstandingAmount,
    required _i2.PaymentsInvoiceStatus status,
  }) : super._(
         invoiceId: invoiceId,
         dueDate: dueDate,
         dueAmount: dueAmount,
         outstandingAmount: outstandingAmount,
         status: status,
       );

  /// Returns a shallow copy of this [PaymentsStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentsStatus copyWith({
    String? invoiceId,
    DateTime? dueDate,
    String? dueAmount,
    String? outstandingAmount,
    _i2.PaymentsInvoiceStatus? status,
  }) {
    return PaymentsStatus(
      invoiceId: invoiceId ?? this.invoiceId,
      dueDate: dueDate ?? this.dueDate,
      dueAmount: dueAmount ?? this.dueAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      status: status ?? this.status,
    );
  }
}

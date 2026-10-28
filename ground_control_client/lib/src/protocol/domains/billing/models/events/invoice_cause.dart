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

/// What happened to an invoice in the billing system, as published on the
/// `invoice` topic.
enum InvoiceCause implements _isc.SerializableModel {
  /// The billing system could not issue the invoice; `reason` says why.
  issueFailed,

  /// An attempt to collect the invoice failed, at `paymentFailedAt`.
  paymentFailed,

  /// The invoice was paid, at `paidAt`.
  paymentSucceeded,

  /// The invoice was issued, at `issuedAt`.
  issued,

  /// An admin voided the invoice, so nothing is owed on it.
  voided,

  /// An admin marked the invoice paid, at `paidAt`, for a payment made
  /// outside the billing system.
  markedPaid,

  /// A credit note was issued against the invoice, covering part or all
  /// of what is owed on it.
  credited;

  static InvoiceCause fromJson(String name) {
    switch (name) {
      case 'issueFailed':
        return InvoiceCause.issueFailed;
      case 'paymentFailed':
        return InvoiceCause.paymentFailed;
      case 'paymentSucceeded':
        return InvoiceCause.paymentSucceeded;
      case 'issued':
        return InvoiceCause.issued;
      case 'voided':
        return InvoiceCause.voided;
      case 'markedPaid':
        return InvoiceCause.markedPaid;
      case 'credited':
        return InvoiceCause.credited;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "InvoiceCause"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

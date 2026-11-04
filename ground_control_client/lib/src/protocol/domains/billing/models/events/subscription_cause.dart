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

/// What happened to a subscription, as published on the `subscription`
/// topic by billing. Each event carries the facts of its cause.
enum SubscriptionCause implements _isc.SerializableModel {
  /// The subscription is in its trial, which ends at `trialEndingAt`.
  trialStarted,

  /// The subscription's trial ended at `trialEndingAt`.
  trialEnded,

  /// The subscription's trial ended at `trialEndingAt` with the owner's
  /// billing setup complete.
  trialConverted,

  /// An invoice of the subscription could not be issued because the
  /// owner's billing info is missing. The subscription is in its grace
  /// period, which ends at `suspendAt`.
  issueFailed,

  /// An invoice of the subscription could not be collected. The
  /// subscription is in its grace period, which ends at `suspendAt`.
  paymentFailed,

  /// An invoice of the subscription is unpaid, or could not be issued, and
  /// the subscription has no grace period left. `invoiceIssued` tells
  /// which; `isFirstInvoice` tells that the subscription had paid no
  /// invoice before and had no grace period. Without `billingInvoiceId`,
  /// the subscription's trial ended at `trialEndingAt` with the owner's
  /// billing setup incomplete, before any invoice.
  arrearsPastGracePeriod,

  /// The subscription owes nothing: no issued invoice is unpaid past due.
  /// `paidAt` is set when a payment settled it. `isFirstInvoice` tells that
  /// the payment is the subscription's first.
  settled,

  /// The subscription ended in the billing system.
  ended;

  static SubscriptionCause fromJson(String name) {
    switch (name) {
      case 'trialStarted':
        return SubscriptionCause.trialStarted;
      case 'trialEnded':
        return SubscriptionCause.trialEnded;
      case 'trialConverted':
        return SubscriptionCause.trialConverted;
      case 'issueFailed':
        return SubscriptionCause.issueFailed;
      case 'paymentFailed':
        return SubscriptionCause.paymentFailed;
      case 'arrearsPastGracePeriod':
        return SubscriptionCause.arrearsPastGracePeriod;
      case 'settled':
        return SubscriptionCause.settled;
      case 'ended':
        return SubscriptionCause.ended;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "SubscriptionCause"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

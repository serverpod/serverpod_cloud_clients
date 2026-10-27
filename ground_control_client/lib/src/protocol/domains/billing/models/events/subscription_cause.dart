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

  /// A non-first-day invoice of the subscription could not be issued because the
  /// owner's billing info is missing. Its projects are suspended at
  /// `suspendAt` unless the invoice is issued before then. A first-day
  /// invoice that cannot be issued is `arrearsPastGracePeriod` at once.
  issueFailed,

  /// A non-first-day invoice of the subscription could not be collected. Its
  /// projects are suspended at `suspendAt` unless the invoice is paid
  /// before then. A first-day invoice that cannot be collected is
  /// `arrearsPastGracePeriod` at once.
  paymentFailed,

  /// An invoice of the subscription is unpaid, or could not be issued, past
  /// its grace period, so its projects are suspended now. `invoiceIssued`
  /// tells which. The grace period is zero for a first-day invoice.
  arrearsPastGracePeriod,

  /// The subscription owes nothing: no issued invoice is unpaid past due.
  /// Published whenever an invoice is paid (`paidAt`) or issued already
  /// paid (`paidAt` null), again on a redelivery, whether or not the
  /// subscription was in arrears.
  settled,

  /// The subscription ended in the billing system and its projects are
  /// suspended for it.
  ended;

  static SubscriptionCause fromJson(String name) {
    switch (name) {
      case 'trialStarted':
        return SubscriptionCause.trialStarted;
      case 'trialEnded':
        return SubscriptionCause.trialEnded;
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

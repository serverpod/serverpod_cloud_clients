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
  /// The subscription's trial began. The trial ends at `trialEndingAt`.
  trialStarted,

  /// The subscription's trial ran out at `trialEndingAt`.
  trialEnded,

  /// An attempt to collect a later invoice failed. Its projects are due for
  /// suspension at `suspendAt` unless the invoice is paid before then.
  paymentFailed,

  /// The subscription is in arrears past its grace period and its projects
  /// are due for suspension now. The grace period is zero for a first-day
  /// invoice, which could not be collected or issued, and the overdue
  /// payment grace period for a later invoice.
  arrearsPastGracePeriod,

  /// The subscription has no issued invoice unpaid past due, after a
  /// payment (`paidAt` set) or after the issue of a first-day invoice
  /// (`paidAt` null). Published on every such payment or issue, also when
  /// the subscription was never in arrears, so listeners must be idempotent.
  settled,

  /// The subscription ended in the billing system and its projects were
  /// suspended for it.
  ended;

  static SubscriptionCause fromJson(String name) {
    switch (name) {
      case 'trialStarted':
        return SubscriptionCause.trialStarted;
      case 'trialEnded':
        return SubscriptionCause.trialEnded;
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

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

enum SubscriptionCause implements _isc.SerializableModel {
  trialStarted,
  trialEnded,
  paymentFailed,
  arrearsPastGracePeriod,
  settled,
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

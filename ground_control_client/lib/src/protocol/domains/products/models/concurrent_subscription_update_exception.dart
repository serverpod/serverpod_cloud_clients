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

/// Exception thrown when another subscription update is in progress.
abstract class ConcurrentSubscriptionUpdateException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  ConcurrentSubscriptionUpdateException._({required this.subscriptionId});

  factory ConcurrentSubscriptionUpdateException({
    required _i1.UuidValue subscriptionId,
  }) = _ConcurrentSubscriptionUpdateExceptionImpl;

  factory ConcurrentSubscriptionUpdateException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ConcurrentSubscriptionUpdateException(
      subscriptionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['subscriptionId'],
      ),
    );
  }

  _i1.UuidValue subscriptionId;

  /// Returns a shallow copy of this [ConcurrentSubscriptionUpdateException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConcurrentSubscriptionUpdateException copyWith({
    _i1.UuidValue? subscriptionId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConcurrentSubscriptionUpdateException',
      'subscriptionId': subscriptionId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConcurrentSubscriptionUpdateException',
      'subscriptionId': subscriptionId.toJson(),
    };
  }

  @override
  String toString() {
    return 'ConcurrentSubscriptionUpdateException(subscriptionId: $subscriptionId)';
  }
}

class _ConcurrentSubscriptionUpdateExceptionImpl
    extends ConcurrentSubscriptionUpdateException {
  _ConcurrentSubscriptionUpdateExceptionImpl({
    required _i1.UuidValue subscriptionId,
  }) : super._(subscriptionId: subscriptionId);

  /// Returns a shallow copy of this [ConcurrentSubscriptionUpdateException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConcurrentSubscriptionUpdateException copyWith({
    _i1.UuidValue? subscriptionId,
  }) {
    return ConcurrentSubscriptionUpdateException(
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }
}

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

/// The usage cap of a project's subscription and the amounts that bound it,
/// all in US cents. When the amount due of a billing period reaches the usage
/// cap, the projects of the subscription are suspended.
abstract class UsageCap
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UsageCap._({
    this.usageCapCents,
    required this.amountDueCents,
    required this.lowestUsageCapCents,
  });

  factory UsageCap({
    int? usageCapCents,
    required int amountDueCents,
    required int lowestUsageCapCents,
  }) = _UsageCapImpl;

  factory UsageCap.fromJson(Map<String, dynamic> jsonSerialization) {
    return UsageCap(
      usageCapCents: jsonSerialization['usageCapCents'] as int?,
      amountDueCents: jsonSerialization['amountDueCents'] as int,
      lowestUsageCapCents: jsonSerialization['lowestUsageCapCents'] as int,
    );
  }

  /// The usage cap. Null when the subscription has none.
  int? usageCapCents;

  /// The amount due so far for the current billing period: the plan fee and
  /// usage, after discounts and credits, rounded up.
  int amountDueCents;

  /// The lowest usage cap the subscription can have.
  int lowestUsageCapCents;

  /// Returns a shallow copy of this [UsageCap]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UsageCap copyWith({
    int? usageCapCents,
    int? amountDueCents,
    int? lowestUsageCapCents,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UsageCap',
      if (usageCapCents != null) 'usageCapCents': usageCapCents,
      'amountDueCents': amountDueCents,
      'lowestUsageCapCents': lowestUsageCapCents,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UsageCap',
      if (usageCapCents != null) 'usageCapCents': usageCapCents,
      'amountDueCents': amountDueCents,
      'lowestUsageCapCents': lowestUsageCapCents,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UsageCapImpl extends UsageCap {
  _UsageCapImpl({
    int? usageCapCents,
    required int amountDueCents,
    required int lowestUsageCapCents,
  }) : super._(
         usageCapCents: usageCapCents,
         amountDueCents: amountDueCents,
         lowestUsageCapCents: lowestUsageCapCents,
       );

  /// Returns a shallow copy of this [UsageCap]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UsageCap copyWith({
    Object? usageCapCents = _Undefined,
    int? amountDueCents,
    int? lowestUsageCapCents,
  }) {
    return UsageCap(
      usageCapCents: usageCapCents is int? ? usageCapCents : this.usageCapCents,
      amountDueCents: amountDueCents ?? this.amountDueCents,
      lowestUsageCapCents: lowestUsageCapCents ?? this.lowestUsageCapCents,
    );
  }
}

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

/// Information about a subscription.
/// Contains information to be sent to the client.
abstract class SubscriptionInfo implements _i1.SerializableModel {
  SubscriptionInfo._({
    required this.createdAt,
    required this.startDate,
    this.trialEndDate,
    required this.subscriptionId,
    required this.planProductId,
    required this.planName,
    required this.planDisplayName,
    this.planDescription,
    this.projectsLimit,
  });

  factory SubscriptionInfo({
    required DateTime createdAt,
    required DateTime startDate,
    DateTime? trialEndDate,
    required String subscriptionId,
    required String planProductId,
    required String planName,
    required String planDisplayName,
    String? planDescription,
    int? projectsLimit,
  }) = _SubscriptionInfoImpl;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubscriptionInfo(
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      startDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startDate'],
      ),
      trialEndDate: jsonSerialization['trialEndDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['trialEndDate'],
            ),
      subscriptionId: jsonSerialization['subscriptionId'] as String,
      planProductId: jsonSerialization['planProductId'] as String,
      planName: jsonSerialization['planName'] as String,
      planDisplayName: jsonSerialization['planDisplayName'] as String,
      planDescription: jsonSerialization['planDescription'] as String?,
      projectsLimit: jsonSerialization['projectsLimit'] as int?,
    );
  }

  /// The date the subscription was created.
  DateTime createdAt;

  /// The date the subscription starts billing.
  DateTime startDate;

  /// Trial end date, if currently ongoing.
  DateTime? trialEndDate;

  /// The id of the subscription.
  String subscriptionId;

  /// The id of the plan's product.
  String planProductId;

  /// Deprecated: Use planDisplayName instead.
  String planName;

  /// The display name of the plan.
  String planDisplayName;

  /// The plan's description, if any.
  String? planDescription;

  /// The limit on the number of projects the subscriber may own, if any.
  int? projectsLimit;

  /// Returns a shallow copy of this [SubscriptionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SubscriptionInfo copyWith({
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? trialEndDate,
    String? subscriptionId,
    String? planProductId,
    String? planName,
    String? planDisplayName,
    String? planDescription,
    int? projectsLimit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SubscriptionInfo',
      'createdAt': createdAt.toJson(),
      'startDate': startDate.toJson(),
      if (trialEndDate != null) 'trialEndDate': trialEndDate?.toJson(),
      'subscriptionId': subscriptionId,
      'planProductId': planProductId,
      'planName': planName,
      'planDisplayName': planDisplayName,
      if (planDescription != null) 'planDescription': planDescription,
      if (projectsLimit != null) 'projectsLimit': projectsLimit,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubscriptionInfoImpl extends SubscriptionInfo {
  _SubscriptionInfoImpl({
    required DateTime createdAt,
    required DateTime startDate,
    DateTime? trialEndDate,
    required String subscriptionId,
    required String planProductId,
    required String planName,
    required String planDisplayName,
    String? planDescription,
    int? projectsLimit,
  }) : super._(
         createdAt: createdAt,
         startDate: startDate,
         trialEndDate: trialEndDate,
         subscriptionId: subscriptionId,
         planProductId: planProductId,
         planName: planName,
         planDisplayName: planDisplayName,
         planDescription: planDescription,
         projectsLimit: projectsLimit,
       );

  /// Returns a shallow copy of this [SubscriptionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SubscriptionInfo copyWith({
    DateTime? createdAt,
    DateTime? startDate,
    Object? trialEndDate = _Undefined,
    String? subscriptionId,
    String? planProductId,
    String? planName,
    String? planDisplayName,
    Object? planDescription = _Undefined,
    Object? projectsLimit = _Undefined,
  }) {
    return SubscriptionInfo(
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      trialEndDate: trialEndDate is DateTime?
          ? trialEndDate
          : this.trialEndDate,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      planProductId: planProductId ?? this.planProductId,
      planName: planName ?? this.planName,
      planDisplayName: planDisplayName ?? this.planDisplayName,
      planDescription: planDescription is String?
          ? planDescription
          : this.planDescription,
      projectsLimit: projectsLimit is int? ? projectsLimit : this.projectsLimit,
    );
  }
}

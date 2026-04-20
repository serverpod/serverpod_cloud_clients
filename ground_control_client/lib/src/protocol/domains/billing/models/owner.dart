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
import '../../../domains/users/models/user.dart' as _i2;
import '../../../domains/billing/models/billing_info.dart' as _i3;
import '../../../domains/projects/models/project.dart' as _i4;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i5;

abstract class Owner implements _i1.SerializableModel {
  Owner._({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.externalBillingId,
    required this.externalPaymentId,
    required this.billingPortalUrl,
    required this.billingEmails,
    this.user,
    this.billingInfo,
    this.projects,
    this.trialEndingAt,
    this.trialSubscriptionId,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Owner({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String externalBillingId,
    required String externalPaymentId,
    required Uri billingPortalUrl,
    required List<String> billingEmails,
    _i2.User? user,
    _i3.BillingInfo? billingInfo,
    List<_i4.Project>? projects,
    DateTime? trialEndingAt,
    String? trialSubscriptionId,
  }) = _OwnerImpl;

  factory Owner.fromJson(Map<String, dynamic> jsonSerialization) {
    return Owner(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      externalBillingId: jsonSerialization['externalBillingId'] as String,
      externalPaymentId: jsonSerialization['externalPaymentId'] as String,
      billingPortalUrl: _i1.UriJsonExtension.fromJson(
        jsonSerialization['billingPortalUrl'],
      ),
      billingEmails: _i5.Protocol().deserialize<List<String>>(
        jsonSerialization['billingEmails'],
      ),
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      billingInfo: jsonSerialization['billingInfo'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.BillingInfo>(
              jsonSerialization['billingInfo'],
            ),
      projects: jsonSerialization['projects'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i4.Project>>(
              jsonSerialization['projects'],
            ),
      trialEndingAt: jsonSerialization['trialEndingAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['trialEndingAt'],
            ),
      trialSubscriptionId: jsonSerialization['trialSubscriptionId'] as String?,
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  DateTime createdAt;

  DateTime updatedAt;

  /// If non-null this Owner is archived.
  DateTime? archivedAt;

  String externalBillingId;

  String externalPaymentId;

  Uri billingPortalUrl;

  List<String> billingEmails;

  _i2.User? user;

  _i3.BillingInfo? billingInfo;

  List<_i4.Project>? projects;

  /// When non-null, the owner's subscription trial ends at this instant (UTC).
  DateTime? trialEndingAt;

  /// Subscription designated for this owner's trial
  String? trialSubscriptionId;

  /// Returns a shallow copy of this [Owner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Owner copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? externalBillingId,
    String? externalPaymentId,
    Uri? billingPortalUrl,
    List<String>? billingEmails,
    _i2.User? user,
    _i3.BillingInfo? billingInfo,
    List<_i4.Project>? projects,
    DateTime? trialEndingAt,
    String? trialSubscriptionId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Owner',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'externalBillingId': externalBillingId,
      'externalPaymentId': externalPaymentId,
      'billingPortalUrl': billingPortalUrl.toJson(),
      'billingEmails': billingEmails.toJson(),
      if (user != null) 'user': user?.toJson(),
      if (billingInfo != null) 'billingInfo': billingInfo?.toJson(),
      if (projects != null)
        'projects': projects?.toJson(valueToJson: (v) => v.toJson()),
      if (trialEndingAt != null) 'trialEndingAt': trialEndingAt?.toJson(),
      if (trialSubscriptionId != null)
        'trialSubscriptionId': trialSubscriptionId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OwnerImpl extends Owner {
  _OwnerImpl({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String externalBillingId,
    required String externalPaymentId,
    required Uri billingPortalUrl,
    required List<String> billingEmails,
    _i2.User? user,
    _i3.BillingInfo? billingInfo,
    List<_i4.Project>? projects,
    DateTime? trialEndingAt,
    String? trialSubscriptionId,
  }) : super._(
         id: id,
         createdAt: createdAt,
         updatedAt: updatedAt,
         archivedAt: archivedAt,
         externalBillingId: externalBillingId,
         externalPaymentId: externalPaymentId,
         billingPortalUrl: billingPortalUrl,
         billingEmails: billingEmails,
         user: user,
         billingInfo: billingInfo,
         projects: projects,
         trialEndingAt: trialEndingAt,
         trialSubscriptionId: trialSubscriptionId,
       );

  /// Returns a shallow copy of this [Owner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Owner copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    String? externalBillingId,
    String? externalPaymentId,
    Uri? billingPortalUrl,
    List<String>? billingEmails,
    Object? user = _Undefined,
    Object? billingInfo = _Undefined,
    Object? projects = _Undefined,
    Object? trialEndingAt = _Undefined,
    Object? trialSubscriptionId = _Undefined,
  }) {
    return Owner(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      externalBillingId: externalBillingId ?? this.externalBillingId,
      externalPaymentId: externalPaymentId ?? this.externalPaymentId,
      billingPortalUrl: billingPortalUrl ?? this.billingPortalUrl,
      billingEmails:
          billingEmails ?? this.billingEmails.map((e0) => e0).toList(),
      user: user is _i2.User? ? user : this.user?.copyWith(),
      billingInfo: billingInfo is _i3.BillingInfo?
          ? billingInfo
          : this.billingInfo?.copyWith(),
      projects: projects is List<_i4.Project>?
          ? projects
          : this.projects?.map((e0) => e0.copyWith()).toList(),
      trialEndingAt: trialEndingAt is DateTime?
          ? trialEndingAt
          : this.trialEndingAt,
      trialSubscriptionId: trialSubscriptionId is String?
          ? trialSubscriptionId
          : this.trialSubscriptionId,
    );
  }
}

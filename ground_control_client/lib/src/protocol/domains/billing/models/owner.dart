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
import '../../../features/project/models/project.dart' as _i4;

abstract class Owner implements _i1.SerializableModel {
  Owner._({
    _i1.UuidValue? id,
    required this.externalBillingId,
    required this.billingPortalUrl,
    required this.billingEmails,
    this.user,
    this.billingInfo,
    this.projects,
  }) : id = id ?? _i1.Uuid().v4obj();

  factory Owner({
    _i1.UuidValue? id,
    required String externalBillingId,
    required Uri billingPortalUrl,
    required List<String> billingEmails,
    _i2.User? user,
    _i3.BillingInfo? billingInfo,
    List<_i4.Project>? projects,
  }) = _OwnerImpl;

  factory Owner.fromJson(Map<String, dynamic> jsonSerialization) {
    return Owner(
      id: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      externalBillingId: jsonSerialization['externalBillingId'] as String,
      billingPortalUrl:
          _i1.UriJsonExtension.fromJson(jsonSerialization['billingPortalUrl']),
      billingEmails: (jsonSerialization['billingEmails'] as List)
          .map((e) => e as String)
          .toList(),
      user: jsonSerialization['user'] == null
          ? null
          : _i2.User.fromJson(
              (jsonSerialization['user'] as Map<String, dynamic>)),
      billingInfo: jsonSerialization['billingInfo'] == null
          ? null
          : _i3.BillingInfo.fromJson(
              (jsonSerialization['billingInfo'] as Map<String, dynamic>)),
      projects: (jsonSerialization['projects'] as List?)
          ?.map((e) => _i4.Project.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue id;

  String externalBillingId;

  Uri billingPortalUrl;

  List<String> billingEmails;

  _i2.User? user;

  _i3.BillingInfo? billingInfo;

  List<_i4.Project>? projects;

  /// Returns a shallow copy of this [Owner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Owner copyWith({
    _i1.UuidValue? id,
    String? externalBillingId,
    Uri? billingPortalUrl,
    List<String>? billingEmails,
    _i2.User? user,
    _i3.BillingInfo? billingInfo,
    List<_i4.Project>? projects,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'externalBillingId': externalBillingId,
      'billingPortalUrl': billingPortalUrl.toJson(),
      'billingEmails': billingEmails.toJson(),
      if (user != null) 'user': user?.toJson(),
      if (billingInfo != null) 'billingInfo': billingInfo?.toJson(),
      if (projects != null)
        'projects': projects?.toJson(valueToJson: (v) => v.toJson()),
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
    required String externalBillingId,
    required Uri billingPortalUrl,
    required List<String> billingEmails,
    _i2.User? user,
    _i3.BillingInfo? billingInfo,
    List<_i4.Project>? projects,
  }) : super._(
          id: id,
          externalBillingId: externalBillingId,
          billingPortalUrl: billingPortalUrl,
          billingEmails: billingEmails,
          user: user,
          billingInfo: billingInfo,
          projects: projects,
        );

  /// Returns a shallow copy of this [Owner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Owner copyWith({
    _i1.UuidValue? id,
    String? externalBillingId,
    Uri? billingPortalUrl,
    List<String>? billingEmails,
    Object? user = _Undefined,
    Object? billingInfo = _Undefined,
    Object? projects = _Undefined,
  }) {
    return Owner(
      id: id ?? this.id,
      externalBillingId: externalBillingId ?? this.externalBillingId,
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
    );
  }
}

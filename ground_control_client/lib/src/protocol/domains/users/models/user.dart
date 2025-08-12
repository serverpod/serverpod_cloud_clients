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
import '../../../domains/users/models/user_account_status.dart' as _i2;
import '../../../features/project/models/user_role_membership.dart' as _i3;
import '../../../domains/billing/models/owner.dart' as _i4;

/// Represents a Serverpod cloud customer user.
abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    _i2.UserAccountStatus? accountStatus,
    this.userAuthId,
    required this.email,
    this.memberships,
    this.maxOwnedProjects,
    this.ownerId,
    this.owner,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        accountStatus = accountStatus ?? _i2.UserAccountStatus.registered;

  factory User({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    _i2.UserAccountStatus? accountStatus,
    String? userAuthId,
    required String email,
    List<_i3.UserRoleMembership>? memberships,
    int? maxOwnedProjects,
    _i1.UuidValue? ownerId,
    _i4.Owner? owner,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      accountStatus: _i2.UserAccountStatus.fromJson(
          (jsonSerialization['accountStatus'] as String)),
      userAuthId: jsonSerialization['userAuthId'] as String?,
      email: jsonSerialization['email'] as String,
      memberships: (jsonSerialization['memberships'] as List?)
          ?.map((e) =>
              _i3.UserRoleMembership.fromJson((e as Map<String, dynamic>)))
          .toList(),
      maxOwnedProjects: jsonSerialization['maxOwnedProjects'] as int?,
      ownerId: jsonSerialization['ownerId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['ownerId']),
      owner: jsonSerialization['owner'] == null
          ? null
          : _i4.Owner.fromJson(
              (jsonSerialization['owner'] as Map<String, dynamic>)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? archivedAt;

  /// The status of the user's account.
  _i2.UserAccountStatus accountStatus;

  /// External user authentication id. Must be unique.
  String? userAuthId;

  /// The email address of the user.
  String email;

  /// The role memberships of this user.
  List<_i3.UserRoleMembership>? memberships;

  /// Max number of projects this user can own.
  int? maxOwnedProjects;

  /// The owner id of the user.
  _i1.UuidValue? ownerId;

  /// The owner container for all projects and billing info managed by this user.
  _i4.Owner? owner;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    _i2.UserAccountStatus? accountStatus,
    String? userAuthId,
    String? email,
    List<_i3.UserRoleMembership>? memberships,
    int? maxOwnedProjects,
    _i1.UuidValue? ownerId,
    _i4.Owner? owner,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'accountStatus': accountStatus.toJson(),
      if (userAuthId != null) 'userAuthId': userAuthId,
      'email': email,
      if (memberships != null)
        'memberships': memberships?.toJson(valueToJson: (v) => v.toJson()),
      if (maxOwnedProjects != null) 'maxOwnedProjects': maxOwnedProjects,
      if (ownerId != null) 'ownerId': ownerId?.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserImpl extends User {
  _UserImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    _i2.UserAccountStatus? accountStatus,
    String? userAuthId,
    required String email,
    List<_i3.UserRoleMembership>? memberships,
    int? maxOwnedProjects,
    _i1.UuidValue? ownerId,
    _i4.Owner? owner,
  }) : super._(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          archivedAt: archivedAt,
          accountStatus: accountStatus,
          userAuthId: userAuthId,
          email: email,
          memberships: memberships,
          maxOwnedProjects: maxOwnedProjects,
          ownerId: ownerId,
          owner: owner,
        );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    _i2.UserAccountStatus? accountStatus,
    Object? userAuthId = _Undefined,
    String? email,
    Object? memberships = _Undefined,
    Object? maxOwnedProjects = _Undefined,
    Object? ownerId = _Undefined,
    Object? owner = _Undefined,
  }) {
    return User(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      accountStatus: accountStatus ?? this.accountStatus,
      userAuthId: userAuthId is String? ? userAuthId : this.userAuthId,
      email: email ?? this.email,
      memberships: memberships is List<_i3.UserRoleMembership>?
          ? memberships
          : this.memberships?.map((e0) => e0.copyWith()).toList(),
      maxOwnedProjects:
          maxOwnedProjects is int? ? maxOwnedProjects : this.maxOwnedProjects,
      ownerId: ownerId is _i1.UuidValue? ? ownerId : this.ownerId,
      owner: owner is _i4.Owner? ? owner : this.owner?.copyWith(),
    );
  }
}

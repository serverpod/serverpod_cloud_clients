/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../features/project/models/user_role_membership.dart' as _i2;

/// Represents a Serverpod cloud customer user.
abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.userAuthId,
    this.displayName,
    this.memberships,
    int? maxOwnedProjects,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        maxOwnedProjects = maxOwnedProjects ?? 3;

  factory User({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String userAuthId,
    String? displayName,
    List<_i2.UserRoleMembership>? memberships,
    int? maxOwnedProjects,
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
      userAuthId: jsonSerialization['userAuthId'] as String,
      displayName: jsonSerialization['displayName'] as String?,
      memberships: (jsonSerialization['memberships'] as List?)
          ?.map((e) =>
              _i2.UserRoleMembership.fromJson((e as Map<String, dynamic>)))
          .toList(),
      maxOwnedProjects: jsonSerialization['maxOwnedProjects'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? archivedAt;

  /// External user authentication id. Must be unique.
  String userAuthId;

  String? displayName;

  /// The role memberships of this user.
  List<_i2.UserRoleMembership>? memberships;

  /// Max number of projects this user can own.
  /// If null, the default value is used.
  int? maxOwnedProjects;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? userAuthId,
    String? displayName,
    List<_i2.UserRoleMembership>? memberships,
    int? maxOwnedProjects,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'userAuthId': userAuthId,
      if (displayName != null) 'displayName': displayName,
      if (memberships != null)
        'memberships': memberships?.toJson(valueToJson: (v) => v.toJson()),
      if (maxOwnedProjects != null) 'maxOwnedProjects': maxOwnedProjects,
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
    required String userAuthId,
    String? displayName,
    List<_i2.UserRoleMembership>? memberships,
    int? maxOwnedProjects,
  }) : super._(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          archivedAt: archivedAt,
          userAuthId: userAuthId,
          displayName: displayName,
          memberships: memberships,
          maxOwnedProjects: maxOwnedProjects,
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
    String? userAuthId,
    Object? displayName = _Undefined,
    Object? memberships = _Undefined,
    Object? maxOwnedProjects = _Undefined,
  }) {
    return User(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      userAuthId: userAuthId ?? this.userAuthId,
      displayName: displayName is String? ? displayName : this.displayName,
      memberships: memberships is List<_i2.UserRoleMembership>?
          ? memberships
          : this.memberships?.map((e0) => e0.copyWith()).toList(),
      maxOwnedProjects:
          maxOwnedProjects is int? ? maxOwnedProjects : this.maxOwnedProjects,
    );
  }
}

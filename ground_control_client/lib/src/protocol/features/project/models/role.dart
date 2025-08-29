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
import '../../../features/project/models/project.dart' as _i2;
import '../../../features/project/models/user_role_membership.dart' as _i3;

/// Represents an access role for a specific project.
/// Roles are assigned to users via membership, giving them the role's access scopes.
abstract class Role implements _i1.SerializableModel {
  Role._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.projectId,
    this.project,
    required this.name,
    required this.projectScopes,
    this.memberships,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Role({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int projectId,
    _i2.Project? project,
    required String name,
    required List<String> projectScopes,
    List<_i3.UserRoleMembership>? memberships,
  }) = _RoleImpl;

  factory Role.fromJson(Map<String, dynamic> jsonSerialization) {
    return Role(
      id: jsonSerialization['id'] as int?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      projectId: jsonSerialization['projectId'] as int,
      project: jsonSerialization['project'] == null
          ? null
          : _i2.Project.fromJson(
              (jsonSerialization['project'] as Map<String, dynamic>)),
      name: jsonSerialization['name'] as String,
      projectScopes: (jsonSerialization['projectScopes'] as List)
          .map((e) => e as String)
          .toList(),
      memberships: (jsonSerialization['memberships'] as List?)
          ?.map((e) =>
              _i3.UserRoleMembership.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? archivedAt;

  int projectId;

  /// A role belongs to a project. Cannot be changed.
  _i2.Project? project;

  /// The name of the role, e.g. 'Admin'. Can be changed.
  String name;

  /// The access scopes this role has in the project.
  List<String> projectScopes;

  /// The user memberships of this role.
  List<_i3.UserRoleMembership>? memberships;

  /// Returns a shallow copy of this [Role]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Role copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    int? projectId,
    _i2.Project? project,
    String? name,
    List<String>? projectScopes,
    List<_i3.UserRoleMembership>? memberships,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'projectId': projectId,
      if (project != null) 'project': project?.toJson(),
      'name': name,
      'projectScopes': projectScopes.toJson(),
      if (memberships != null)
        'memberships': memberships?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoleImpl extends Role {
  _RoleImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int projectId,
    _i2.Project? project,
    required String name,
    required List<String> projectScopes,
    List<_i3.UserRoleMembership>? memberships,
  }) : super._(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          archivedAt: archivedAt,
          projectId: projectId,
          project: project,
          name: name,
          projectScopes: projectScopes,
          memberships: memberships,
        );

  /// Returns a shallow copy of this [Role]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Role copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    int? projectId,
    Object? project = _Undefined,
    String? name,
    List<String>? projectScopes,
    Object? memberships = _Undefined,
  }) {
    return Role(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      name: name ?? this.name,
      projectScopes:
          projectScopes ?? this.projectScopes.map((e0) => e0).toList(),
      memberships: memberships is List<_i3.UserRoleMembership>?
          ? memberships
          : this.memberships?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

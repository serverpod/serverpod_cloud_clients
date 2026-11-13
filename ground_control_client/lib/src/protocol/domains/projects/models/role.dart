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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/projects/models/project.dart' as _i2isqmwh;
import '../../../domains/projects/models/project_role.dart' as _isypcm2i;
import '../../../domains/projects/models/user_role_membership.dart'
    as _i28atcql;

/// Represents an access role for a specific project.
/// Roles are assigned to users via membership, giving them the role's access scopes.
abstract class Role
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Role._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.projectId,
    this.project,
    this.name,
    _isypcm2i.ProjectRole? roleName,
    required this.projectScopes,
    this.memberships,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       roleName = roleName ?? _isypcm2i.ProjectRole.admin;

  factory Role({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int projectId,
    _i2isqmwh.Project? project,
    String? name,
    _isypcm2i.ProjectRole? roleName,
    required List<String> projectScopes,
    List<_i28atcql.UserRoleMembership>? memberships,
  }) = _RoleImpl;

  factory Role.fromJson(Map<String, dynamic> jsonSerialization) {
    return Role(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedAt'],
            ),
      projectId: jsonSerialization['projectId'] as int,
      project: jsonSerialization['project'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_i2isqmwh.Project>(
              jsonSerialization['project'],
            ),
      name: jsonSerialization['name'] as String?,
      roleName: jsonSerialization['roleName'] == null
          ? null
          : _isypcm2i.ProjectRole.fromJson(
              (jsonSerialization['roleName'] as String),
            ),
      projectScopes: _iod2a87h.Protocol().deserialize<List<String>>(
        jsonSerialization['projectScopes'],
      ),
      memberships: jsonSerialization['memberships'] == null
          ? null
          : _iod2a87h.Protocol()
                .deserialize<List<_i28atcql.UserRoleMembership>>(
                  jsonSerialization['memberships'],
                ),
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
  _i2isqmwh.Project? project;

  /// DEPRECATED: Use roleName instead.
  String? name;

  /// The predefined role name, e.g. 'admin'.
  _isypcm2i.ProjectRole roleName;

  /// The access scopes this role has in the project.
  List<String> projectScopes;

  /// The user memberships of this role.
  List<_i28atcql.UserRoleMembership>? memberships;

  /// Returns a shallow copy of this [Role]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Role copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
    int? projectId,
    _i2isqmwh.Project? project = const _UndefinedRole$project(),
    String? name,
    _isypcm2i.ProjectRole? roleName,
    List<String>? projectScopes,
    List<_i28atcql.UserRoleMembership>? memberships =
        const _isc.$UndefinedList<_i28atcql.UserRoleMembership>(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Role',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'projectId': projectId,
      if (project != null) 'project': project?.toJson(),
      if (name != null) 'name': name,
      'roleName': roleName.toJson(),
      'projectScopes': projectScopes.toJson(),
      if (memberships != null)
        'memberships': memberships?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Role',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'projectId': projectId,
      if (project != null) 'project': project?.toJsonForProtocol(),
      if (name != null) 'name': name,
      'roleName': roleName.toJson(),
      'projectScopes': projectScopes.toJson(),
      if (memberships != null)
        'memberships': memberships?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedRole$project extends _isc.UndefinedSentinel
    implements _i2isqmwh.Project {
  const _UndefinedRole$project();
}

class _RoleImpl extends Role {
  _RoleImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int projectId,
    _i2isqmwh.Project? project,
    String? name,
    _isypcm2i.ProjectRole? roleName,
    required List<String> projectScopes,
    List<_i28atcql.UserRoleMembership>? memberships,
  }) : super._(
         id: id,
         createdAt: createdAt,
         updatedAt: updatedAt,
         archivedAt: archivedAt,
         projectId: projectId,
         project: project,
         name: name,
         roleName: roleName,
         projectScopes: projectScopes,
         memberships: memberships,
       );

  /// Returns a shallow copy of this [Role]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Role copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
    int? projectId,
    _i2isqmwh.Project? project = const _UndefinedRole$project(),
    Object? name = _Undefined,
    _isypcm2i.ProjectRole? roleName,
    List<String>? projectScopes,
    List<_i28atcql.UserRoleMembership>? memberships =
        const _isc.$UndefinedList<_i28atcql.UserRoleMembership>(),
  }) {
    return Role(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is _isc.UndefinedSentinel
          ? this.archivedAt
          : archivedAt,
      projectId: projectId ?? this.projectId,
      project: project is _isc.UndefinedSentinel
          ? this.project?.copyWith()
          : project,
      name: name is String? ? name : this.name,
      roleName: roleName ?? this.roleName,
      projectScopes:
          projectScopes ?? this.projectScopes.map((e0) => e0).toList(),
      memberships: memberships is _isc.UndefinedSentinel
          ? this.memberships?.map((e0) => e0.copyWith()).toList()
          : memberships,
    );
  }
}

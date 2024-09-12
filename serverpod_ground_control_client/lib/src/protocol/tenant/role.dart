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
import '../protocol.dart' as _i2;

/// Represents an access role for a specific tenant project.
/// Roles are assigned to users via membership, giving them the role's access scopes.
abstract class Role implements _i1.SerializableModel {
  Role._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.tenantProjectId,
    this.tenantProject,
    required this.name,
    required this.tenantScopes,
    this.memberships,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Role({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int tenantProjectId,
    _i2.TenantProject? tenantProject,
    required String name,
    required List<String> tenantScopes,
    List<_i2.UserRoleMembership>? memberships,
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
      tenantProjectId: jsonSerialization['tenantProjectId'] as int,
      tenantProject: jsonSerialization['tenantProject'] == null
          ? null
          : _i2.TenantProject.fromJson(
              (jsonSerialization['tenantProject'] as Map<String, dynamic>)),
      name: jsonSerialization['name'] as String,
      tenantScopes: (jsonSerialization['tenantScopes'] as List)
          .map((e) => e as String)
          .toList(),
      memberships: (jsonSerialization['memberships'] as List?)
          ?.map((e) =>
              _i2.UserRoleMembership.fromJson((e as Map<String, dynamic>)))
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

  int tenantProjectId;

  /// A role belongs to a tenant project. Cannot be changed.
  _i2.TenantProject? tenantProject;

  /// The name of the role, e.g. 'Owners'. Can be changed.
  String name;

  /// The access scopes this role has in the tenant project.
  List<String> tenantScopes;

  /// The user memberships of this role.
  List<_i2.UserRoleMembership>? memberships;

  Role copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    int? tenantProjectId,
    _i2.TenantProject? tenantProject,
    String? name,
    List<String>? tenantScopes,
    List<_i2.UserRoleMembership>? memberships,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'tenantProjectId': tenantProjectId,
      if (tenantProject != null) 'tenantProject': tenantProject?.toJson(),
      'name': name,
      'tenantScopes': tenantScopes.toJson(),
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
    required int tenantProjectId,
    _i2.TenantProject? tenantProject,
    required String name,
    required List<String> tenantScopes,
    List<_i2.UserRoleMembership>? memberships,
  }) : super._(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          archivedAt: archivedAt,
          tenantProjectId: tenantProjectId,
          tenantProject: tenantProject,
          name: name,
          tenantScopes: tenantScopes,
          memberships: memberships,
        );

  @override
  Role copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    int? tenantProjectId,
    Object? tenantProject = _Undefined,
    String? name,
    List<String>? tenantScopes,
    Object? memberships = _Undefined,
  }) {
    return Role(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      tenantProjectId: tenantProjectId ?? this.tenantProjectId,
      tenantProject: tenantProject is _i2.TenantProject?
          ? tenantProject
          : this.tenantProject?.copyWith(),
      name: name ?? this.name,
      tenantScopes: tenantScopes ?? this.tenantScopes.map((e0) => e0).toList(),
      memberships: memberships is List<_i2.UserRoleMembership>?
          ? memberships
          : this.memberships?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

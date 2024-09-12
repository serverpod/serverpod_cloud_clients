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

/// Represents a project of a tenant.
/// Typically a serverpod project.
abstract class TenantProject implements _i1.SerializableModel {
  TenantProject._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.canonicalName,
    this.roles,
    this.environments,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory TenantProject({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String canonicalName,
    List<_i2.Role>? roles,
    List<_i2.Environment>? environments,
  }) = _TenantProjectImpl;

  factory TenantProject.fromJson(Map<String, dynamic> jsonSerialization) {
    return TenantProject(
      id: jsonSerialization['id'] as int?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      canonicalName: jsonSerialization['canonicalName'] as String,
      roles: (jsonSerialization['roles'] as List?)
          ?.map((e) => _i2.Role.fromJson((e as Map<String, dynamic>)))
          .toList(),
      environments: (jsonSerialization['environments'] as List?)
          ?.map((e) => _i2.Environment.fromJson((e as Map<String, dynamic>)))
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

  /// The canonical name of the project.
  /// This must be globally unique.
  /// This is the default production name of the project.
  String canonicalName;

  /// The roles for this project.
  List<_i2.Role>? roles;

  /// The environments of this project.
  List<_i2.Environment>? environments;

  TenantProject copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? canonicalName,
    List<_i2.Role>? roles,
    List<_i2.Environment>? environments,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'canonicalName': canonicalName,
      if (roles != null) 'roles': roles?.toJson(valueToJson: (v) => v.toJson()),
      if (environments != null)
        'environments': environments?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TenantProjectImpl extends TenantProject {
  _TenantProjectImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String canonicalName,
    List<_i2.Role>? roles,
    List<_i2.Environment>? environments,
  }) : super._(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          archivedAt: archivedAt,
          canonicalName: canonicalName,
          roles: roles,
          environments: environments,
        );

  @override
  TenantProject copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    String? canonicalName,
    Object? roles = _Undefined,
    Object? environments = _Undefined,
  }) {
    return TenantProject(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      canonicalName: canonicalName ?? this.canonicalName,
      roles: roles is List<_i2.Role>?
          ? roles
          : this.roles?.map((e0) => e0.copyWith()).toList(),
      environments: environments is List<_i2.Environment>?
          ? environments
          : this.environments?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

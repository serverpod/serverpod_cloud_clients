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
import '../../../domains/billing/models/owner.dart' as _i2;
import '../../../domains/projects/models/role.dart' as _i3;
import '../../../domains/capsules/models/capsule.dart' as _i4;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i5;

/// Represents a project of a tenant.
/// Typically a serverpod project.
abstract class Project implements _i1.SerializableModel {
  Project._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.cloudProjectId,
    required this.ownerId,
    this.owner,
    this.roles,
    this.capsules,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Project({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String cloudProjectId,
    required _i1.UuidValue ownerId,
    _i2.Owner? owner,
    List<_i3.Role>? roles,
    List<_i4.Capsule>? capsules,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      cloudProjectId: jsonSerialization['cloudProjectId'] as String,
      ownerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      owner: jsonSerialization['owner'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Owner>(jsonSerialization['owner']),
      roles: jsonSerialization['roles'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i3.Role>>(
              jsonSerialization['roles'],
            ),
      capsules: jsonSerialization['capsules'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i4.Capsule>>(
              jsonSerialization['capsules'],
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

  /// The id of the project, which is also its name.
  /// This must be globally unique.
  /// This is the default production name of the project.
  String cloudProjectId;

  /// The id of the owner of the project.
  _i1.UuidValue ownerId;

  /// The owner of the project.
  _i2.Owner? owner;

  /// The roles for this project.
  List<_i3.Role>? roles;

  /// The capsules belonging to this project.
  List<_i4.Capsule>? capsules;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Project copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? cloudProjectId,
    _i1.UuidValue? ownerId,
    _i2.Owner? owner,
    List<_i3.Role>? roles,
    List<_i4.Capsule>? capsules,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'cloudProjectId': cloudProjectId,
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJson(),
      if (roles != null) 'roles': roles?.toJson(valueToJson: (v) => v.toJson()),
      if (capsules != null)
        'capsules': capsules?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectImpl extends Project {
  _ProjectImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required String cloudProjectId,
    required _i1.UuidValue ownerId,
    _i2.Owner? owner,
    List<_i3.Role>? roles,
    List<_i4.Capsule>? capsules,
  }) : super._(
         id: id,
         createdAt: createdAt,
         updatedAt: updatedAt,
         archivedAt: archivedAt,
         cloudProjectId: cloudProjectId,
         ownerId: ownerId,
         owner: owner,
         roles: roles,
         capsules: capsules,
       );

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Project copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    String? cloudProjectId,
    _i1.UuidValue? ownerId,
    Object? owner = _Undefined,
    Object? roles = _Undefined,
    Object? capsules = _Undefined,
  }) {
    return Project(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      cloudProjectId: cloudProjectId ?? this.cloudProjectId,
      ownerId: ownerId ?? this.ownerId,
      owner: owner is _i2.Owner? ? owner : this.owner?.copyWith(),
      roles: roles is List<_i3.Role>?
          ? roles
          : this.roles?.map((e0) => e0.copyWith()).toList(),
      capsules: capsules is List<_i4.Capsule>?
          ? capsules
          : this.capsules?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

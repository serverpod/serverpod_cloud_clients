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
import '../../../domains/billing/models/owner.dart' as _icig531b;
import '../../../domains/capsules/models/capsule.dart' as _ictbn9k6;
import '../../../domains/projects/models/role.dart' as _im7cbtgg;

/// Represents a project of a tenant.
/// Typically a serverpod project.
abstract class Project
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue ownerId,
    _icig531b.Owner? owner,
    List<_im7cbtgg.Role>? roles,
    List<_ictbn9k6.Capsule>? capsules,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
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
      cloudProjectId: jsonSerialization['cloudProjectId'] as String,
      ownerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      owner: jsonSerialization['owner'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_icig531b.Owner>(
              jsonSerialization['owner'],
            ),
      roles: jsonSerialization['roles'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<List<_im7cbtgg.Role>>(
              jsonSerialization['roles'],
            ),
      capsules: jsonSerialization['capsules'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<List<_ictbn9k6.Capsule>>(
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
  _isc.UuidValue ownerId;

  /// The owner of the project.
  _icig531b.Owner? owner;

  /// The roles for this project.
  List<_im7cbtgg.Role>? roles;

  /// The capsules belonging to this project.
  List<_ictbn9k6.Capsule>? capsules;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Project copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? cloudProjectId,
    _isc.UuidValue? ownerId,
    _icig531b.Owner? owner,
    List<_im7cbtgg.Role>? roles,
    List<_ictbn9k6.Capsule>? capsules,
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'cloudProjectId': cloudProjectId,
      'ownerId': ownerId.toJson(),
      if (owner != null) 'owner': owner?.toJsonForProtocol(),
      if (roles != null)
        'roles': roles?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (capsules != null)
        'capsules': capsules?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
    required _isc.UuidValue ownerId,
    _icig531b.Owner? owner,
    List<_im7cbtgg.Role>? roles,
    List<_ictbn9k6.Capsule>? capsules,
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
  @_isc.useResult
  @override
  Project copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    String? cloudProjectId,
    _isc.UuidValue? ownerId,
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
      owner: owner is _icig531b.Owner? ? owner : this.owner?.copyWith(),
      roles: roles is List<_im7cbtgg.Role>?
          ? roles
          : this.roles?.map((e0) => e0.copyWith()).toList(),
      capsules: capsules is List<_ictbn9k6.Capsule>?
          ? capsules
          : this.capsules?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

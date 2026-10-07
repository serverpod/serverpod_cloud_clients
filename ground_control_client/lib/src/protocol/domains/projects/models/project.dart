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
import '../../../domains/projects/models/project_lifecycle_status.dart'
    as _ie2v77w9;
import '../../../domains/projects/models/project_suspension_reason.dart'
    as _ixae5ksq;
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
    _ie2v77w9.ProjectLifecycleStatus? status,
    this.suspendedAt,
    this.suspensionReason,
    required this.cloudProjectId,
    required this.ownerId,
    this.owner,
    this.roles,
    this.capsules,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       status = status ?? _ie2v77w9.ProjectLifecycleStatus.active;

  factory Project({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    _ie2v77w9.ProjectLifecycleStatus? status,
    DateTime? suspendedAt,
    _ixae5ksq.ProjectSuspensionReason? suspensionReason,
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
      status: jsonSerialization['status'] == null
          ? null
          : _ie2v77w9.ProjectLifecycleStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      suspendedAt: jsonSerialization['suspendedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['suspendedAt'],
            ),
      suspensionReason: jsonSerialization['suspensionReason'] == null
          ? null
          : _ixae5ksq.ProjectSuspensionReason.fromJson(
              (jsonSerialization['suspensionReason'] as String),
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

  /// The lifecycle status of the project.
  _ie2v77w9.ProjectLifecycleStatus status;

  /// When the project was last suspended. Kept on archive.
  DateTime? suspendedAt;

  /// Why the project was last suspended. Kept on archive.
  _ixae5ksq.ProjectSuspensionReason? suspensionReason;

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
    _ie2v77w9.ProjectLifecycleStatus? status,
    DateTime? suspendedAt,
    _ixae5ksq.ProjectSuspensionReason? suspensionReason,
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
      'status': status.toJson(),
      if (suspendedAt != null) 'suspendedAt': suspendedAt?.toJson(),
      if (suspensionReason != null)
        'suspensionReason': suspensionReason?.toJson(),
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
      'status': status.toJson(),
      if (suspendedAt != null) 'suspendedAt': suspendedAt?.toJson(),
      if (suspensionReason != null)
        'suspensionReason': suspensionReason?.toJson(),
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
    _ie2v77w9.ProjectLifecycleStatus? status,
    DateTime? suspendedAt,
    _ixae5ksq.ProjectSuspensionReason? suspensionReason,
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
         status: status,
         suspendedAt: suspendedAt,
         suspensionReason: suspensionReason,
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
    _ie2v77w9.ProjectLifecycleStatus? status,
    Object? suspendedAt = _Undefined,
    Object? suspensionReason = _Undefined,
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
      status: status ?? this.status,
      suspendedAt: suspendedAt is DateTime? ? suspendedAt : this.suspendedAt,
      suspensionReason: suspensionReason is _ixae5ksq.ProjectSuspensionReason?
          ? suspensionReason
          : this.suspensionReason,
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

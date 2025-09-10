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

/// DEPRECATED, will likely be removed
abstract class Subscription implements _i1.SerializableModel {
  Subscription._({
    _i1.UuidValue? id,
    required this.projectId,
    this.project,
    this.createdAt,
  }) : id = id ?? _i1.Uuid().v4obj();

  factory Subscription({
    _i1.UuidValue? id,
    required int projectId,
    _i2.Project? project,
    DateTime? createdAt,
  }) = _SubscriptionImpl;

  factory Subscription.fromJson(Map<String, dynamic> jsonSerialization) {
    return Subscription(
      id: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: jsonSerialization['projectId'] as int,
      project: jsonSerialization['project'] == null
          ? null
          : _i2.Project.fromJson(
              (jsonSerialization['project'] as Map<String, dynamic>)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue id;

  int projectId;

  /// The project this subscription belongs to.
  _i2.Project? project;

  /// The date and time this subscription was created.
  DateTime? createdAt;

  /// Returns a shallow copy of this [Subscription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Subscription copyWith({
    _i1.UuidValue? id,
    int? projectId,
    _i2.Project? project,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'projectId': projectId,
      if (project != null) 'project': project?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubscriptionImpl extends Subscription {
  _SubscriptionImpl({
    _i1.UuidValue? id,
    required int projectId,
    _i2.Project? project,
    DateTime? createdAt,
  }) : super._(
          id: id,
          projectId: projectId,
          project: project,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [Subscription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Subscription copyWith({
    _i1.UuidValue? id,
    int? projectId,
    Object? project = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return Subscription(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

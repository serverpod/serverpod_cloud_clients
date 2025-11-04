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
import '../../../../features/projects/models/project.dart' as _i2;
import '../../../../features/projects/models/project_info/timestamp.dart'
    as _i3;

/// Augments a project object with ancillary information.
///
/// Ancillary information fields are included according to use case,
/// in which case they are non-null.
/// In other words, null ancillary fields correspond to `undefined`.
abstract class ProjectInfo implements _i1.SerializableModel {
  ProjectInfo._({
    required this.project,
    this.latestDeployAttemptTime,
  });

  factory ProjectInfo({
    required _i2.Project project,
    _i3.Timestamp? latestDeployAttemptTime,
  }) = _ProjectInfoImpl;

  factory ProjectInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectInfo(
      project: _i2.Project.fromJson(
          (jsonSerialization['project'] as Map<String, dynamic>)),
      latestDeployAttemptTime: jsonSerialization['latestDeployAttemptTime'] ==
              null
          ? null
          : _i3.Timestamp.fromJson((jsonSerialization['latestDeployAttemptTime']
              as Map<String, dynamic>)),
    );
  }

  _i2.Project project;

  /// The timestamp of the latest deploy attempt, or null if never deployed.
  /// (When deploy status is overhauled, this will likely be replaced by a
  /// `DeployAttempt` object.)
  _i3.Timestamp? latestDeployAttemptTime;

  /// Returns a shallow copy of this [ProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectInfo copyWith({
    _i2.Project? project,
    _i3.Timestamp? latestDeployAttemptTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'project': project.toJson(),
      if (latestDeployAttemptTime != null)
        'latestDeployAttemptTime': latestDeployAttemptTime?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectInfoImpl extends ProjectInfo {
  _ProjectInfoImpl({
    required _i2.Project project,
    _i3.Timestamp? latestDeployAttemptTime,
  }) : super._(
          project: project,
          latestDeployAttemptTime: latestDeployAttemptTime,
        );

  /// Returns a shallow copy of this [ProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectInfo copyWith({
    _i2.Project? project,
    Object? latestDeployAttemptTime = _Undefined,
  }) {
    return ProjectInfo(
      project: project ?? this.project.copyWith(),
      latestDeployAttemptTime: latestDeployAttemptTime is _i3.Timestamp?
          ? latestDeployAttemptTime
          : this.latestDeployAttemptTime?.copyWith(),
    );
  }
}

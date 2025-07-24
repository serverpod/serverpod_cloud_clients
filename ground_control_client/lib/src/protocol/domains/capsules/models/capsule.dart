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
import '../../../shared/models/serverpod_region.dart' as _i2;
import '../../../features/project/models/project.dart' as _i3;
import '../../../features/environment_variables/models/environment_variable.dart'
    as _i4;
import '../../../features/custom_domain_name/models/custom_domain_name.dart'
    as _i5;
import '../../../domains/capsules/models/capsule_resource_config.dart' as _i6;

/// Represents an infrastructure capsule instance (a deployment target).
abstract class Capsule implements _i1.SerializableModel {
  Capsule._({
    this.id,
    required this.name,
    required this.cloudCapsuleId,
    required this.region,
    required this.projectId,
    this.project,
    this.environmentVariables,
    this.domainNames,
    this.resourceConfig,
  });

  factory Capsule({
    int? id,
    required String name,
    required String cloudCapsuleId,
    required _i2.ServerpodRegion region,
    required int projectId,
    _i3.Project? project,
    List<_i4.EnvironmentVariable>? environmentVariables,
    List<_i5.CustomDomainName>? domainNames,
    _i6.CapsuleResource? resourceConfig,
  }) = _CapsuleImpl;

  factory Capsule.fromJson(Map<String, dynamic> jsonSerialization) {
    return Capsule(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      region:
          _i2.ServerpodRegion.fromJson((jsonSerialization['region'] as int)),
      projectId: jsonSerialization['projectId'] as int,
      project: jsonSerialization['project'] == null
          ? null
          : _i3.Project.fromJson(
              (jsonSerialization['project'] as Map<String, dynamic>)),
      environmentVariables: (jsonSerialization['environmentVariables'] as List?)
          ?.map((e) =>
              _i4.EnvironmentVariable.fromJson((e as Map<String, dynamic>)))
          .toList(),
      domainNames: (jsonSerialization['domainNames'] as List?)
          ?.map(
              (e) => _i5.CustomDomainName.fromJson((e as Map<String, dynamic>)))
          .toList(),
      resourceConfig: jsonSerialization['resourceConfig'] == null
          ? null
          : _i6.CapsuleResource.fromJson(
              (jsonSerialization['resourceConfig'] as Map<String, dynamic>)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The name of the capsule. User-defined.
  String name;

  /// Globally unique identifier of the capsule. Cannot be changed.
  String cloudCapsuleId;

  /// The region where the capsule is hosted. Cannot be changed.
  _i2.ServerpodRegion region;

  int projectId;

  /// The project this capsule belongs to. Cannot be changed.
  _i3.Project? project;

  /// Environment variables for this capsule.
  List<_i4.EnvironmentVariable>? environmentVariables;

  /// The domain names for this capsule.
  List<_i5.CustomDomainName>? domainNames;

  /// The resource config for the capsule.
  _i6.CapsuleResource? resourceConfig;

  /// Returns a shallow copy of this [Capsule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Capsule copyWith({
    int? id,
    String? name,
    String? cloudCapsuleId,
    _i2.ServerpodRegion? region,
    int? projectId,
    _i3.Project? project,
    List<_i4.EnvironmentVariable>? environmentVariables,
    List<_i5.CustomDomainName>? domainNames,
    _i6.CapsuleResource? resourceConfig,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'cloudCapsuleId': cloudCapsuleId,
      'region': region.toJson(),
      'projectId': projectId,
      if (project != null) 'project': project?.toJson(),
      if (environmentVariables != null)
        'environmentVariables':
            environmentVariables?.toJson(valueToJson: (v) => v.toJson()),
      if (domainNames != null)
        'domainNames': domainNames?.toJson(valueToJson: (v) => v.toJson()),
      if (resourceConfig != null) 'resourceConfig': resourceConfig?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapsuleImpl extends Capsule {
  _CapsuleImpl({
    int? id,
    required String name,
    required String cloudCapsuleId,
    required _i2.ServerpodRegion region,
    required int projectId,
    _i3.Project? project,
    List<_i4.EnvironmentVariable>? environmentVariables,
    List<_i5.CustomDomainName>? domainNames,
    _i6.CapsuleResource? resourceConfig,
  }) : super._(
          id: id,
          name: name,
          cloudCapsuleId: cloudCapsuleId,
          region: region,
          projectId: projectId,
          project: project,
          environmentVariables: environmentVariables,
          domainNames: domainNames,
          resourceConfig: resourceConfig,
        );

  /// Returns a shallow copy of this [Capsule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Capsule copyWith({
    Object? id = _Undefined,
    String? name,
    String? cloudCapsuleId,
    _i2.ServerpodRegion? region,
    int? projectId,
    Object? project = _Undefined,
    Object? environmentVariables = _Undefined,
    Object? domainNames = _Undefined,
    Object? resourceConfig = _Undefined,
  }) {
    return Capsule(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      region: region ?? this.region,
      projectId: projectId ?? this.projectId,
      project: project is _i3.Project? ? project : this.project?.copyWith(),
      environmentVariables:
          environmentVariables is List<_i4.EnvironmentVariable>?
              ? environmentVariables
              : this.environmentVariables?.map((e0) => e0.copyWith()).toList(),
      domainNames: domainNames is List<_i5.CustomDomainName>?
          ? domainNames
          : this.domainNames?.map((e0) => e0.copyWith()).toList(),
      resourceConfig: resourceConfig is _i6.CapsuleResource?
          ? resourceConfig
          : this.resourceConfig?.copyWith(),
    );
  }
}

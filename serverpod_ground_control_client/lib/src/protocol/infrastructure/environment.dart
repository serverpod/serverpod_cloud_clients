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

/// Represents an infrastructure environment instance (a deployment target).
abstract class Environment implements _i1.SerializableModel {
  Environment._({
    this.id,
    required this.name,
    required this.cloudEnvironmentId,
    required this.region,
    required this.projectId,
    this.project,
    this.environmentVariables,
    this.domainNames,
  });

  factory Environment({
    int? id,
    required String name,
    required String cloudEnvironmentId,
    required _i2.ServerpodRegion region,
    required int projectId,
    _i2.Project? project,
    List<_i2.EnvironmentVariable>? environmentVariables,
    List<_i2.CustomDomainName>? domainNames,
  }) = _EnvironmentImpl;

  factory Environment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Environment(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      cloudEnvironmentId: jsonSerialization['cloudEnvironmentId'] as String,
      region:
          _i2.ServerpodRegion.fromJson((jsonSerialization['region'] as int)),
      projectId: jsonSerialization['projectId'] as int,
      project: jsonSerialization['project'] == null
          ? null
          : _i2.Project.fromJson(
              (jsonSerialization['project'] as Map<String, dynamic>)),
      environmentVariables: (jsonSerialization['environmentVariables'] as List?)
          ?.map((e) =>
              _i2.EnvironmentVariable.fromJson((e as Map<String, dynamic>)))
          .toList(),
      domainNames: (jsonSerialization['domainNames'] as List?)
          ?.map(
              (e) => _i2.CustomDomainName.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The name of the environment. User-defined.
  String name;

  /// Globally unique identitifier of the environment. Cannot be changed.
  String cloudEnvironmentId;

  /// The region where the environment is hosted. Cannot be changed.
  _i2.ServerpodRegion region;

  int projectId;

  /// The project this environment belongs to. Cannot be changed.
  _i2.Project? project;

  /// Environment variables for this environment.
  List<_i2.EnvironmentVariable>? environmentVariables;

  /// The domain names for this environment.
  List<_i2.CustomDomainName>? domainNames;

  Environment copyWith({
    int? id,
    String? name,
    String? cloudEnvironmentId,
    _i2.ServerpodRegion? region,
    int? projectId,
    _i2.Project? project,
    List<_i2.EnvironmentVariable>? environmentVariables,
    List<_i2.CustomDomainName>? domainNames,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'cloudEnvironmentId': cloudEnvironmentId,
      'region': region.toJson(),
      'projectId': projectId,
      if (project != null) 'project': project?.toJson(),
      if (environmentVariables != null)
        'environmentVariables':
            environmentVariables?.toJson(valueToJson: (v) => v.toJson()),
      if (domainNames != null)
        'domainNames': domainNames?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvironmentImpl extends Environment {
  _EnvironmentImpl({
    int? id,
    required String name,
    required String cloudEnvironmentId,
    required _i2.ServerpodRegion region,
    required int projectId,
    _i2.Project? project,
    List<_i2.EnvironmentVariable>? environmentVariables,
    List<_i2.CustomDomainName>? domainNames,
  }) : super._(
          id: id,
          name: name,
          cloudEnvironmentId: cloudEnvironmentId,
          region: region,
          projectId: projectId,
          project: project,
          environmentVariables: environmentVariables,
          domainNames: domainNames,
        );

  @override
  Environment copyWith({
    Object? id = _Undefined,
    String? name,
    String? cloudEnvironmentId,
    _i2.ServerpodRegion? region,
    int? projectId,
    Object? project = _Undefined,
    Object? environmentVariables = _Undefined,
    Object? domainNames = _Undefined,
  }) {
    return Environment(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      cloudEnvironmentId: cloudEnvironmentId ?? this.cloudEnvironmentId,
      region: region ?? this.region,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      environmentVariables:
          environmentVariables is List<_i2.EnvironmentVariable>?
              ? environmentVariables
              : this.environmentVariables?.map((e0) => e0.copyWith()).toList(),
      domainNames: domainNames is List<_i2.CustomDomainName>?
          ? domainNames
          : this.domainNames?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

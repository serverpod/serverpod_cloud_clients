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
    required this.envId,
    required this.region,
    required this.tenantProjectId,
    this.tenantProject,
  });

  factory Environment({
    int? id,
    required String name,
    required String envId,
    required _i2.ServerpodRegion region,
    required int tenantProjectId,
    _i2.TenantProject? tenantProject,
  }) = _EnvironmentImpl;

  factory Environment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Environment(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      envId: jsonSerialization['envId'] as String,
      region:
          _i2.ServerpodRegion.fromJson((jsonSerialization['region'] as int)),
      tenantProjectId: jsonSerialization['tenantProjectId'] as int,
      tenantProject: jsonSerialization['tenantProject'] == null
          ? null
          : _i2.TenantProject.fromJson(
              (jsonSerialization['tenantProject'] as Map<String, dynamic>)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The name of the environment. User-defined.
  String name;

  /// The globally unique ID of the environment. Cannot be changed.
  String envId;

  /// The region where the environment is hosted. Cannot be changed.
  _i2.ServerpodRegion region;

  int tenantProjectId;

  /// The tenant this environment belongs to.
  _i2.TenantProject? tenantProject;

  Environment copyWith({
    int? id,
    String? name,
    String? envId,
    _i2.ServerpodRegion? region,
    int? tenantProjectId,
    _i2.TenantProject? tenantProject,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'envId': envId,
      'region': region.toJson(),
      'tenantProjectId': tenantProjectId,
      if (tenantProject != null) 'tenantProject': tenantProject?.toJson(),
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
    required String envId,
    required _i2.ServerpodRegion region,
    required int tenantProjectId,
    _i2.TenantProject? tenantProject,
  }) : super._(
          id: id,
          name: name,
          envId: envId,
          region: region,
          tenantProjectId: tenantProjectId,
          tenantProject: tenantProject,
        );

  @override
  Environment copyWith({
    Object? id = _Undefined,
    String? name,
    String? envId,
    _i2.ServerpodRegion? region,
    int? tenantProjectId,
    Object? tenantProject = _Undefined,
  }) {
    return Environment(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      envId: envId ?? this.envId,
      region: region ?? this.region,
      tenantProjectId: tenantProjectId ?? this.tenantProjectId,
      tenantProject: tenantProject is _i2.TenantProject?
          ? tenantProject
          : this.tenantProject?.copyWith(),
    );
  }
}

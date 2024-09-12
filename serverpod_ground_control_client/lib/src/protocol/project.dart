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
import 'protocol.dart' as _i2;

abstract class Project implements _i1.SerializableModel {
  Project._({
    this.id,
    required this.name,
    required this.projectId,
    required this.region,
  });

  factory Project({
    int? id,
    required String name,
    required String projectId,
    required _i2.ServerpodRegion region,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      projectId: jsonSerialization['projectId'] as String,
      region:
          _i2.ServerpodRegion.fromJson((jsonSerialization['region'] as int)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  String projectId;

  _i2.ServerpodRegion region;

  Project copyWith({
    int? id,
    String? name,
    String? projectId,
    _i2.ServerpodRegion? region,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'projectId': projectId,
      'region': region.toJson(),
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
    required String name,
    required String projectId,
    required _i2.ServerpodRegion region,
  }) : super._(
          id: id,
          name: name,
          projectId: projectId,
          region: region,
        );

  @override
  Project copyWith({
    Object? id = _Undefined,
    String? name,
    String? projectId,
    _i2.ServerpodRegion? region,
  }) {
    return Project(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
      region: region ?? this.region,
    );
  }
}

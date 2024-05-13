/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../protocol.dart' as _i2;

abstract class DatabaseResource extends _i1.SerializableEntity {
  DatabaseResource._({
    this.id,
    required this.projectId,
    required this.providerId,
    required this.provider,
  });

  factory DatabaseResource({
    int? id,
    required int projectId,
    required String providerId,
    required _i2.DatabaseProvider provider,
  }) = _DatabaseResourceImpl;

  factory DatabaseResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseResource(
      id: jsonSerialization['id'] as int?,
      projectId: jsonSerialization['projectId'] as int,
      providerId: jsonSerialization['providerId'] as String,
      provider: _i2.DatabaseProvider.fromJson(
          (jsonSerialization['provider'] as String)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int projectId;

  String providerId;

  _i2.DatabaseProvider provider;

  DatabaseResource copyWith({
    int? id,
    int? projectId,
    String? providerId,
    _i2.DatabaseProvider? provider,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'projectId': projectId,
      'providerId': providerId,
      'provider': provider.toJson(),
    };
  }
}

class _Undefined {}

class _DatabaseResourceImpl extends DatabaseResource {
  _DatabaseResourceImpl({
    int? id,
    required int projectId,
    required String providerId,
    required _i2.DatabaseProvider provider,
  }) : super._(
          id: id,
          projectId: projectId,
          providerId: providerId,
          provider: provider,
        );

  @override
  DatabaseResource copyWith({
    Object? id = _Undefined,
    int? projectId,
    String? providerId,
    _i2.DatabaseProvider? provider,
  }) {
    return DatabaseResource(
      id: id is int? ? id : this.id,
      projectId: projectId ?? this.projectId,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
    );
  }
}

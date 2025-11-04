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
import '../../../features/databases/models/database_provider.dart' as _i2;
import '../../../features/databases/models/database_connection.dart' as _i3;

abstract class DatabaseResource implements _i1.SerializableModel {
  DatabaseResource._({
    this.id,
    required this.cloudCapsuleId,
    required this.providerId,
    required this.provider,
    required this.connection,
  });

  factory DatabaseResource({
    int? id,
    required String cloudCapsuleId,
    required String providerId,
    required _i2.DatabaseProvider provider,
    required _i3.DatabaseConnection connection,
  }) = _DatabaseResourceImpl;

  factory DatabaseResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      providerId: jsonSerialization['providerId'] as String,
      provider: _i2.DatabaseProvider.fromJson(
          (jsonSerialization['provider'] as String)),
      connection: _i3.DatabaseConnection.fromJson(
          (jsonSerialization['connection'] as Map<String, dynamic>)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cloudCapsuleId;

  String providerId;

  _i2.DatabaseProvider provider;

  _i3.DatabaseConnection connection;

  /// Returns a shallow copy of this [DatabaseResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseResource copyWith({
    int? id,
    String? cloudCapsuleId,
    String? providerId,
    _i2.DatabaseProvider? provider,
    _i3.DatabaseConnection? connection,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'providerId': providerId,
      'provider': provider.toJson(),
      'connection': connection.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseResourceImpl extends DatabaseResource {
  _DatabaseResourceImpl({
    int? id,
    required String cloudCapsuleId,
    required String providerId,
    required _i2.DatabaseProvider provider,
    required _i3.DatabaseConnection connection,
  }) : super._(
          id: id,
          cloudCapsuleId: cloudCapsuleId,
          providerId: providerId,
          provider: provider,
          connection: connection,
        );

  /// Returns a shallow copy of this [DatabaseResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseResource copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    String? providerId,
    _i2.DatabaseProvider? provider,
    _i3.DatabaseConnection? connection,
  }) {
    return DatabaseResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
      connection: connection ?? this.connection.copyWith(),
    );
  }
}

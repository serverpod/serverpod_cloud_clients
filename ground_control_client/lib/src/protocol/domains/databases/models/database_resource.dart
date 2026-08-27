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
import '../../../domains/databases/models/database_connection.dart'
    as _ige3u73h;
import '../../../domains/databases/models/database_provider.dart' as _ikd8hsk5;
import '../../../domains/databases/models/database_quota.dart' as _iq6ve2ql;
import '../../../domains/databases/models/database_scaling.dart' as _io14rsas;

abstract class DatabaseResource
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DatabaseResource._({
    this.id,
    required this.cloudCapsuleId,
    required this.providerId,
    required this.provider,
    required this.connection,
    required this.scaling,
    required this.quota,
    this.metricsExportEndpoint,
    this.metricsExportSecretFingerprint,
  });

  factory DatabaseResource({
    int? id,
    required String cloudCapsuleId,
    required String providerId,
    required _ikd8hsk5.DatabaseProvider provider,
    required _ige3u73h.DatabaseConnection connection,
    required _io14rsas.DatabaseScaling scaling,
    required _iq6ve2ql.DatabaseQuota quota,
    String? metricsExportEndpoint,
    String? metricsExportSecretFingerprint,
  }) = _DatabaseResourceImpl;

  factory DatabaseResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      providerId: jsonSerialization['providerId'] as String,
      provider: _ikd8hsk5.DatabaseProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      connection: _iod2a87h.Protocol()
          .deserialize<_ige3u73h.DatabaseConnection>(
            jsonSerialization['connection'],
          ),
      scaling: _iod2a87h.Protocol().deserialize<_io14rsas.DatabaseScaling>(
        jsonSerialization['scaling'],
      ),
      quota: _iod2a87h.Protocol().deserialize<_iq6ve2ql.DatabaseQuota>(
        jsonSerialization['quota'],
      ),
      metricsExportEndpoint:
          jsonSerialization['metricsExportEndpoint'] as String?,
      metricsExportSecretFingerprint:
          jsonSerialization['metricsExportSecretFingerprint'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cloudCapsuleId;

  String providerId;

  _ikd8hsk5.DatabaseProvider provider;

  _ige3u73h.DatabaseConnection connection;

  _io14rsas.DatabaseScaling scaling;

  _iq6ve2ql.DatabaseQuota quota;

  String? metricsExportEndpoint;

  String? metricsExportSecretFingerprint;

  /// Returns a shallow copy of this [DatabaseResource]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DatabaseResource copyWith({
    int? id,
    String? cloudCapsuleId,
    String? providerId,
    _ikd8hsk5.DatabaseProvider? provider,
    _ige3u73h.DatabaseConnection? connection,
    _io14rsas.DatabaseScaling? scaling,
    _iq6ve2ql.DatabaseQuota? quota,
    String? metricsExportEndpoint,
    String? metricsExportSecretFingerprint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseResource',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'providerId': providerId,
      'provider': provider.toJson(),
      'connection': connection.toJson(),
      'scaling': scaling.toJson(),
      'quota': quota.toJson(),
      if (metricsExportEndpoint != null)
        'metricsExportEndpoint': metricsExportEndpoint,
      if (metricsExportSecretFingerprint != null)
        'metricsExportSecretFingerprint': metricsExportSecretFingerprint,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseResource',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'providerId': providerId,
      'provider': provider.toJson(),
      'connection': connection.toJsonForProtocol(),
      'scaling': scaling.toJsonForProtocol(),
      'quota': quota.toJsonForProtocol(),
      if (metricsExportEndpoint != null)
        'metricsExportEndpoint': metricsExportEndpoint,
      if (metricsExportSecretFingerprint != null)
        'metricsExportSecretFingerprint': metricsExportSecretFingerprint,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseResourceImpl extends DatabaseResource {
  _DatabaseResourceImpl({
    int? id,
    required String cloudCapsuleId,
    required String providerId,
    required _ikd8hsk5.DatabaseProvider provider,
    required _ige3u73h.DatabaseConnection connection,
    required _io14rsas.DatabaseScaling scaling,
    required _iq6ve2ql.DatabaseQuota quota,
    String? metricsExportEndpoint,
    String? metricsExportSecretFingerprint,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         providerId: providerId,
         provider: provider,
         connection: connection,
         scaling: scaling,
         quota: quota,
         metricsExportEndpoint: metricsExportEndpoint,
         metricsExportSecretFingerprint: metricsExportSecretFingerprint,
       );

  /// Returns a shallow copy of this [DatabaseResource]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DatabaseResource copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    String? providerId,
    _ikd8hsk5.DatabaseProvider? provider,
    _ige3u73h.DatabaseConnection? connection,
    _io14rsas.DatabaseScaling? scaling,
    _iq6ve2ql.DatabaseQuota? quota,
    Object? metricsExportEndpoint = _Undefined,
    Object? metricsExportSecretFingerprint = _Undefined,
  }) {
    return DatabaseResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
      connection: connection ?? this.connection.copyWith(),
      scaling: scaling ?? this.scaling.copyWith(),
      quota: quota ?? this.quota.copyWith(),
      metricsExportEndpoint: metricsExportEndpoint is String?
          ? metricsExportEndpoint
          : this.metricsExportEndpoint,
      metricsExportSecretFingerprint: metricsExportSecretFingerprint is String?
          ? metricsExportSecretFingerprint
          : this.metricsExportSecretFingerprint,
    );
  }
}

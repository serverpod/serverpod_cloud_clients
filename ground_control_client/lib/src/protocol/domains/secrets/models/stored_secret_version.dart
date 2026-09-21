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
import '../../../domains/secrets/models/secret_resource.dart' as _i75vpmhh;

abstract class StoredSecretVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StoredSecretVersion._({
    this.id,
    this.createdAt,
    required this.secretResourceId,
    this.secretResource,
    required this.secretId,
    required this.values,
  });

  factory StoredSecretVersion({
    int? id,
    DateTime? createdAt,
    required int secretResourceId,
    _i75vpmhh.SecretResource? secretResource,
    required String secretId,
    required Map<String, String> values,
  }) = _StoredSecretVersionImpl;

  factory StoredSecretVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoredSecretVersion(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      secretResourceId: jsonSerialization['secretResourceId'] as int,
      secretResource: jsonSerialization['secretResource'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_i75vpmhh.SecretResource>(
              jsonSerialization['secretResource'],
            ),
      secretId: jsonSerialization['secretId'] as String,
      values: _iod2a87h.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['values'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime? createdAt;

  int secretResourceId;

  _i75vpmhh.SecretResource? secretResource;

  String secretId;

  Map<String, String> values;

  /// Returns a shallow copy of this [StoredSecretVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StoredSecretVersion copyWith({
    int? id,
    DateTime? createdAt,
    int? secretResourceId,
    _i75vpmhh.SecretResource? secretResource,
    String? secretId,
    Map<String, String>? values,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoredSecretVersion',
      if (id != null) 'id': id,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'secretResourceId': secretResourceId,
      if (secretResource != null) 'secretResource': secretResource?.toJson(),
      'secretId': secretId,
      'values': values.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StoredSecretVersion',
      if (id != null) 'id': id,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'secretResourceId': secretResourceId,
      if (secretResource != null)
        'secretResource': secretResource?.toJsonForProtocol(),
      'secretId': secretId,
      'values': values.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoredSecretVersionImpl extends StoredSecretVersion {
  _StoredSecretVersionImpl({
    int? id,
    DateTime? createdAt,
    required int secretResourceId,
    _i75vpmhh.SecretResource? secretResource,
    required String secretId,
    required Map<String, String> values,
  }) : super._(
         id: id,
         createdAt: createdAt,
         secretResourceId: secretResourceId,
         secretResource: secretResource,
         secretId: secretId,
         values: values,
       );

  /// Returns a shallow copy of this [StoredSecretVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StoredSecretVersion copyWith({
    Object? id = _Undefined,
    Object? createdAt = _Undefined,
    int? secretResourceId,
    Object? secretResource = _Undefined,
    String? secretId,
    Map<String, String>? values,
  }) {
    return StoredSecretVersion(
      id: id is int? ? id : this.id,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      secretResourceId: secretResourceId ?? this.secretResourceId,
      secretResource: secretResource is _i75vpmhh.SecretResource?
          ? secretResource
          : this.secretResource?.copyWith(),
      secretId: secretId ?? this.secretId,
      values:
          values ?? this.values.map((key0, value0) => MapEntry(key0, value0)),
    );
  }
}

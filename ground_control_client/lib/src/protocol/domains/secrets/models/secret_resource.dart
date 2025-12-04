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
import '../../../domains/secrets/models/secret_type.dart' as _i2;

abstract class SecretResource implements _i1.SerializableModel {
  SecretResource._({
    this.id,
    required this.cloudCapsuleId,
    required this.secretId,
    required this.secretType,
    this.latestVersionId,
    this.activeVersionId,
    this.createdAt,
  });

  factory SecretResource({
    int? id,
    required String cloudCapsuleId,
    required String secretId,
    required _i2.SecretType secretType,
    String? latestVersionId,
    String? activeVersionId,
    DateTime? createdAt,
  }) = _SecretResourceImpl;

  factory SecretResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return SecretResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      secretId: jsonSerialization['secretId'] as String,
      secretType:
          _i2.SecretType.fromJson((jsonSerialization['secretType'] as String)),
      latestVersionId: jsonSerialization['latestVersionId'] as String?,
      activeVersionId: jsonSerialization['activeVersionId'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cloudCapsuleId;

  String secretId;

  _i2.SecretType secretType;

  String? latestVersionId;

  String? activeVersionId;

  DateTime? createdAt;

  /// Returns a shallow copy of this [SecretResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SecretResource copyWith({
    int? id,
    String? cloudCapsuleId,
    String? secretId,
    _i2.SecretType? secretType,
    String? latestVersionId,
    String? activeVersionId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'secretId': secretId,
      'secretType': secretType.toJson(),
      if (latestVersionId != null) 'latestVersionId': latestVersionId,
      if (activeVersionId != null) 'activeVersionId': activeVersionId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SecretResourceImpl extends SecretResource {
  _SecretResourceImpl({
    int? id,
    required String cloudCapsuleId,
    required String secretId,
    required _i2.SecretType secretType,
    String? latestVersionId,
    String? activeVersionId,
    DateTime? createdAt,
  }) : super._(
          id: id,
          cloudCapsuleId: cloudCapsuleId,
          secretId: secretId,
          secretType: secretType,
          latestVersionId: latestVersionId,
          activeVersionId: activeVersionId,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [SecretResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SecretResource copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    String? secretId,
    _i2.SecretType? secretType,
    Object? latestVersionId = _Undefined,
    Object? activeVersionId = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return SecretResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      secretId: secretId ?? this.secretId,
      secretType: secretType ?? this.secretType,
      latestVersionId:
          latestVersionId is String? ? latestVersionId : this.latestVersionId,
      activeVersionId:
          activeVersionId is String? ? activeVersionId : this.activeVersionId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

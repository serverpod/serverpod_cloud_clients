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

abstract class AuthTokenInfo implements _i1.SerializableModel {
  AuthTokenInfo._({
    required this.tokenId,
    required this.issuer,
    required this.method,
    required this.createdAt,
    this.expiresAt,
    this.expireAfterUnusedFor,
    this.lastUsedAt,
  });

  factory AuthTokenInfo({
    required String tokenId,
    required String issuer,
    required String method,
    required DateTime createdAt,
    DateTime? expiresAt,
    Duration? expireAfterUnusedFor,
    DateTime? lastUsedAt,
  }) = _AuthTokenInfoImpl;

  factory AuthTokenInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthTokenInfo(
      tokenId: jsonSerialization['tokenId'] as String,
      issuer: jsonSerialization['issuer'] as String,
      method: jsonSerialization['method'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      expireAfterUnusedFor: jsonSerialization['expireAfterUnusedFor'] == null
          ? null
          : _i1.DurationJsonExtension.fromJson(
              jsonSerialization['expireAfterUnusedFor'],
            ),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
    );
  }

  String tokenId;

  String issuer;

  String method;

  DateTime createdAt;

  DateTime? expiresAt;

  Duration? expireAfterUnusedFor;

  DateTime? lastUsedAt;

  /// Returns a shallow copy of this [AuthTokenInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthTokenInfo copyWith({
    String? tokenId,
    String? issuer,
    String? method,
    DateTime? createdAt,
    DateTime? expiresAt,
    Duration? expireAfterUnusedFor,
    DateTime? lastUsedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthTokenInfo',
      'tokenId': tokenId,
      'issuer': issuer,
      'method': method,
      'createdAt': createdAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (expireAfterUnusedFor != null)
        'expireAfterUnusedFor': expireAfterUnusedFor?.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuthTokenInfoImpl extends AuthTokenInfo {
  _AuthTokenInfoImpl({
    required String tokenId,
    required String issuer,
    required String method,
    required DateTime createdAt,
    DateTime? expiresAt,
    Duration? expireAfterUnusedFor,
    DateTime? lastUsedAt,
  }) : super._(
         tokenId: tokenId,
         issuer: issuer,
         method: method,
         createdAt: createdAt,
         expiresAt: expiresAt,
         expireAfterUnusedFor: expireAfterUnusedFor,
         lastUsedAt: lastUsedAt,
       );

  /// Returns a shallow copy of this [AuthTokenInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthTokenInfo copyWith({
    String? tokenId,
    String? issuer,
    String? method,
    DateTime? createdAt,
    Object? expiresAt = _Undefined,
    Object? expireAfterUnusedFor = _Undefined,
    Object? lastUsedAt = _Undefined,
  }) {
    return AuthTokenInfo(
      tokenId: tokenId ?? this.tokenId,
      issuer: issuer ?? this.issuer,
      method: method ?? this.method,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      expireAfterUnusedFor: expireAfterUnusedFor is Duration?
          ? expireAfterUnusedFor
          : this.expireAfterUnusedFor,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
    );
  }
}

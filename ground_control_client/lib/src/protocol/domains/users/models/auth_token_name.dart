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

/// The name a user gave one of their auth tokens.
/// The auth module owns the tokens and stores no name for them, so the names
/// are kept here and matched to the tokens by id on read.
///
/// A row is written when a named token is created and deleted when the token
/// is revoked. Tokens that expire on their own leave their name behind, since
/// the auth module deletes those rows without notifying us.
abstract class AuthTokenName
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AuthTokenName._({
    this.id,
    DateTime? createdAt,
    required this.authTokenId,
    required this.authUserId,
    required this.name,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuthTokenName({
    int? id,
    DateTime? createdAt,
    required _i1.UuidValue authTokenId,
    required _i1.UuidValue authUserId,
    required String name,
  }) = _AuthTokenNameImpl;

  factory AuthTokenName.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthTokenName(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      authTokenId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authTokenId'],
      ),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      name: jsonSerialization['name'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  /// The id of the auth token that this name belongs to.
  _i1.UuidValue authTokenId;

  /// The auth user that owns the token.
  _i1.UuidValue authUserId;

  /// The name the user gave the token when creating it.
  String name;

  /// Returns a shallow copy of this [AuthTokenName]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthTokenName copyWith({
    int? id,
    DateTime? createdAt,
    _i1.UuidValue? authTokenId,
    _i1.UuidValue? authUserId,
    String? name,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthTokenName',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'authTokenId': authTokenId.toJson(),
      'authUserId': authUserId.toJson(),
      'name': name,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuthTokenName',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'authTokenId': authTokenId.toJson(),
      'authUserId': authUserId.toJson(),
      'name': name,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuthTokenNameImpl extends AuthTokenName {
  _AuthTokenNameImpl({
    int? id,
    DateTime? createdAt,
    required _i1.UuidValue authTokenId,
    required _i1.UuidValue authUserId,
    required String name,
  }) : super._(
         id: id,
         createdAt: createdAt,
         authTokenId: authTokenId,
         authUserId: authUserId,
         name: name,
       );

  /// Returns a shallow copy of this [AuthTokenName]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthTokenName copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    _i1.UuidValue? authTokenId,
    _i1.UuidValue? authUserId,
    String? name,
  }) {
    return AuthTokenName(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      authTokenId: authTokenId ?? this.authTokenId,
      authUserId: authUserId ?? this.authUserId,
      name: name ?? this.name,
    );
  }
}

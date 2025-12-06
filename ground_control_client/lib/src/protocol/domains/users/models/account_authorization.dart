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

/// This model and table is deprecated. Use UserInvitation instead.
abstract class AccountAuthorization implements _i1.SerializableModel {
  AccountAuthorization._({
    this.id,
    required this.email,
  });

  factory AccountAuthorization({
    int? id,
    required String email,
  }) = _AccountAuthorizationImpl;

  factory AccountAuthorization.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountAuthorization(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String email;

  /// Returns a shallow copy of this [AccountAuthorization]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountAuthorization copyWith({
    int? id,
    String? email,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountAuthorization',
      if (id != null) 'id': id,
      'email': email,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountAuthorizationImpl extends AccountAuthorization {
  _AccountAuthorizationImpl({
    int? id,
    required String email,
  }) : super._(
         id: id,
         email: email,
       );

  /// Returns a shallow copy of this [AccountAuthorization]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountAuthorization copyWith({
    Object? id = _Undefined,
    String? email,
  }) {
    return AccountAuthorization(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
    );
  }
}

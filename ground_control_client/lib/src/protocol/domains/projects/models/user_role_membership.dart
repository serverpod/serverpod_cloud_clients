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
import '../../../domains/projects/models/role.dart' as _im7cbtgg;
import '../../../domains/users/models/user.dart' as _ijl94k1v;

/// Represents a membership of a user in a role.
abstract class UserRoleMembership
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserRoleMembership._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    required this.userId,
    this.user,
    required this.roleId,
    this.role,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory UserRoleMembership({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int userId,
    _ijl94k1v.User? user,
    required int roleId,
    _im7cbtgg.Role? role,
  }) = _UserRoleMembershipImpl;

  factory UserRoleMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserRoleMembership(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedAt'],
            ),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ijl94k1v.User>(
              jsonSerialization['user'],
            ),
      roleId: jsonSerialization['roleId'] as int,
      role: jsonSerialization['role'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_im7cbtgg.Role>(
              jsonSerialization['role'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? archivedAt;

  int userId;

  /// The user that is a member of the role.
  _ijl94k1v.User? user;

  int roleId;

  /// The role the user is a member of.
  _im7cbtgg.Role? role;

  /// Returns a shallow copy of this [UserRoleMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserRoleMembership copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    int? userId,
    _ijl94k1v.User? user,
    int? roleId,
    _im7cbtgg.Role? role,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserRoleMembership',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'roleId': roleId,
      if (role != null) 'role': role?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserRoleMembership',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'roleId': roleId,
      if (role != null) 'role': role?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserRoleMembershipImpl extends UserRoleMembership {
  _UserRoleMembershipImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    required int userId,
    _ijl94k1v.User? user,
    required int roleId,
    _im7cbtgg.Role? role,
  }) : super._(
         id: id,
         createdAt: createdAt,
         updatedAt: updatedAt,
         archivedAt: archivedAt,
         userId: userId,
         user: user,
         roleId: roleId,
         role: role,
       );

  /// Returns a shallow copy of this [UserRoleMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserRoleMembership copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _Undefined,
    int? userId,
    Object? user = _Undefined,
    int? roleId,
    Object? role = _Undefined,
  }) {
    return UserRoleMembership(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      userId: userId ?? this.userId,
      user: user is _ijl94k1v.User? ? user : this.user?.copyWith(),
      roleId: roleId ?? this.roleId,
      role: role is _im7cbtgg.Role? ? role : this.role?.copyWith(),
    );
  }
}

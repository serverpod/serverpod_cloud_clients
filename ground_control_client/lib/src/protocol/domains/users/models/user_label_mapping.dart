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
import '../../../domains/users/models/user.dart' as _i2;
import '../../../domains/users/models/user_label.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Associates users (including invited, not yet registered) with user labels.
abstract class UserLabelMapping implements _i1.SerializableModel {
  UserLabelMapping._({
    this.id,
    DateTime? createdAt,
    required this.userId,
    this.user,
    required this.label,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserLabelMapping({
    int? id,
    DateTime? createdAt,
    required int userId,
    _i2.User? user,
    required _i3.UserLabel label,
  }) = _UserLabelMappingImpl;

  factory UserLabelMapping.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserLabelMapping(
      id: jsonSerialization['id'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      label: _i3.UserLabel.fromJson((jsonSerialization['label'] as String)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  int userId;

  /// The user that is associated with the label.
  _i2.User? user;

  /// The label associated with the user.
  _i3.UserLabel label;

  /// Returns a shallow copy of this [UserLabelMapping]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserLabelMapping copyWith({
    int? id,
    DateTime? createdAt,
    int? userId,
    _i2.User? user,
    _i3.UserLabel? label,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserLabelMapping',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'label': label.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserLabelMappingImpl extends UserLabelMapping {
  _UserLabelMappingImpl({
    int? id,
    DateTime? createdAt,
    required int userId,
    _i2.User? user,
    required _i3.UserLabel label,
  }) : super._(
         id: id,
         createdAt: createdAt,
         userId: userId,
         user: user,
         label: label,
       );

  /// Returns a shallow copy of this [UserLabelMapping]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserLabelMapping copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    int? userId,
    Object? user = _Undefined,
    _i3.UserLabel? label,
  }) {
    return UserLabelMapping(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      label: label ?? this.label,
    );
  }
}

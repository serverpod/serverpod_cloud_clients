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
import '../../../domains/users/models/user.dart' as _ijl94k1v;
import '../../../domains/users/models/user_label.dart' as _i5ur1pgv;

/// Associates users (including invited, not yet registered) with user labels.
abstract class UserLabelMapping
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _ijl94k1v.User? user,
    required _i5ur1pgv.UserLabel label,
  }) = _UserLabelMappingImpl;

  factory UserLabelMapping.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserLabelMapping(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ijl94k1v.User>(
              jsonSerialization['user'],
            ),
      label: _i5ur1pgv.UserLabel.fromJson(
        (jsonSerialization['label'] as String),
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  int userId;

  /// The user that is associated with the label.
  _ijl94k1v.User? user;

  /// The label associated with the user.
  _i5ur1pgv.UserLabel label;

  /// Returns a shallow copy of this [UserLabelMapping]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserLabelMapping copyWith({
    int? id,
    DateTime? createdAt,
    int? userId,
    _ijl94k1v.User? user,
    _i5ur1pgv.UserLabel? label,
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserLabelMapping',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'label': label.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserLabelMappingImpl extends UserLabelMapping {
  _UserLabelMappingImpl({
    int? id,
    DateTime? createdAt,
    required int userId,
    _ijl94k1v.User? user,
    required _i5ur1pgv.UserLabel label,
  }) : super._(
         id: id,
         createdAt: createdAt,
         userId: userId,
         user: user,
         label: label,
       );

  /// Returns a shallow copy of this [UserLabelMapping]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserLabelMapping copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    int? userId,
    Object? user = _Undefined,
    _i5ur1pgv.UserLabel? label,
  }) {
    return UserLabelMapping(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      user: user is _ijl94k1v.User? ? user : this.user?.copyWith(),
      label: label ?? this.label,
    );
  }
}

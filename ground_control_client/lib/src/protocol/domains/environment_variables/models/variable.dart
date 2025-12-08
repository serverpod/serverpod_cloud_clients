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
import '../../../domains/capsules/models/capsule.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

abstract class EnvironmentVariable implements _i1.SerializableModel {
  EnvironmentVariable._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.capsuleId,
    this.capsule,
    required this.name,
    required this.value,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory EnvironmentVariable({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int capsuleId,
    _i2.Capsule? capsule,
    required String name,
    required String value,
  }) = _EnvironmentVariableImpl;

  factory EnvironmentVariable.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvironmentVariable(
      id: jsonSerialization['id'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      capsuleId: jsonSerialization['capsuleId'] as int,
      capsule: jsonSerialization['capsule'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Capsule>(
              jsonSerialization['capsule'],
            ),
      name: jsonSerialization['name'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  DateTime updatedAt;

  int capsuleId;

  /// An environment variable belongs to a capsule. Cannot be changed.
  _i2.Capsule? capsule;

  /// The name of the environment variable, e.g. 'HOST'. Can be changed.
  String name;

  /// The value of the environment variable, e.g. 'localhost'. Can be changed.
  String value;

  /// Returns a shallow copy of this [EnvironmentVariable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EnvironmentVariable copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? capsuleId,
    _i2.Capsule? capsule,
    String? name,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnvironmentVariable',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'capsuleId': capsuleId,
      if (capsule != null) 'capsule': capsule?.toJson(),
      'name': name,
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvironmentVariableImpl extends EnvironmentVariable {
  _EnvironmentVariableImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int capsuleId,
    _i2.Capsule? capsule,
    required String name,
    required String value,
  }) : super._(
         id: id,
         createdAt: createdAt,
         updatedAt: updatedAt,
         capsuleId: capsuleId,
         capsule: capsule,
         name: name,
         value: value,
       );

  /// Returns a shallow copy of this [EnvironmentVariable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EnvironmentVariable copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? capsuleId,
    Object? capsule = _Undefined,
    String? name,
    String? value,
  }) {
    return EnvironmentVariable(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      capsuleId: capsuleId ?? this.capsuleId,
      capsule: capsule is _i2.Capsule? ? capsule : this.capsule?.copyWith(),
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}

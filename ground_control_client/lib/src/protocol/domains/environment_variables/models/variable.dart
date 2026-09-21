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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class EnvironmentVariable
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EnvironmentVariable._({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.cloudCapsuleId,
    required this.name,
    required this.value,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory EnvironmentVariable({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required String cloudCapsuleId,
    required String name,
    required String value,
  }) = _EnvironmentVariableImpl;

  factory EnvironmentVariable.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvironmentVariable(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
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

  /// Globally unique identifier of the capsule this variable belongs to.
  /// Cannot be changed.
  String cloudCapsuleId;

  /// The name of the environment variable, e.g. 'HOST'. Can be changed.
  String name;

  /// The value of the environment variable, e.g. 'localhost'. Can be changed.
  String value;

  /// Returns a shallow copy of this [EnvironmentVariable]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EnvironmentVariable copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cloudCapsuleId,
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
      'cloudCapsuleId': cloudCapsuleId,
      'name': name,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EnvironmentVariable',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'cloudCapsuleId': cloudCapsuleId,
      'name': name,
      'value': value,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvironmentVariableImpl extends EnvironmentVariable {
  _EnvironmentVariableImpl({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required String cloudCapsuleId,
    required String name,
    required String value,
  }) : super._(
         id: id,
         createdAt: createdAt,
         updatedAt: updatedAt,
         cloudCapsuleId: cloudCapsuleId,
         name: name,
         value: value,
       );

  /// Returns a shallow copy of this [EnvironmentVariable]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EnvironmentVariable copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cloudCapsuleId,
    String? name,
    String? value,
  }) {
    return EnvironmentVariable(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}

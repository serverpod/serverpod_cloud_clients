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

/// The environment variables a capsule was last deployed with, so that the
/// variables it is running can be told apart from the ones that are only
/// stored.
abstract class DeployedVariables
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DeployedVariables._({
    this.id,
    required this.cloudCapsuleId,
    required this.values,
    DateTime? deployedAt,
  }) : deployedAt = deployedAt ?? DateTime.now();

  factory DeployedVariables({
    int? id,
    required String cloudCapsuleId,
    required Map<String, String> values,
    DateTime? deployedAt,
  }) = _DeployedVariablesImpl;

  factory DeployedVariables.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeployedVariables(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      values: _iod2a87h.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['values'],
      ),
      deployedAt: jsonSerialization['deployedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['deployedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Globally unique identifier of the capsule these variables belong to.
  String cloudCapsuleId;

  /// The deployed values, by variable name.
  Map<String, String> values;

  /// When the deployment that used these values was triggered.
  DateTime deployedAt;

  /// Returns a shallow copy of this [DeployedVariables]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DeployedVariables copyWith({
    int? id,
    String? cloudCapsuleId,
    Map<String, String>? values,
    DateTime? deployedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeployedVariables',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'values': values.toJson(),
      'deployedAt': deployedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeployedVariables',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'values': values.toJson(),
      'deployedAt': deployedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeployedVariablesImpl extends DeployedVariables {
  _DeployedVariablesImpl({
    int? id,
    required String cloudCapsuleId,
    required Map<String, String> values,
    DateTime? deployedAt,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         values: values,
         deployedAt: deployedAt,
       );

  /// Returns a shallow copy of this [DeployedVariables]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DeployedVariables copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    Map<String, String>? values,
    DateTime? deployedAt,
  }) {
    return DeployedVariables(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      values:
          values ?? this.values.map((key0, value0) => MapEntry(key0, value0)),
      deployedAt: deployedAt ?? this.deployedAt,
    );
  }
}

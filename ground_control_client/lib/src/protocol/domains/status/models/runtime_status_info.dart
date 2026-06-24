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
import '../../../domains/status/models/runtime_status.dart' as _i2;

/// Runtime serving status information for a capsule.
abstract class RuntimeStatusInfo implements _i1.SerializableModel {
  RuntimeStatusInfo._({
    required this.status,
    required this.availableReplicas,
    this.desiredReplicas,
  });

  factory RuntimeStatusInfo({
    required _i2.RuntimeStatus status,
    required int availableReplicas,
    int? desiredReplicas,
  }) = _RuntimeStatusInfoImpl;

  factory RuntimeStatusInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuntimeStatusInfo(
      status: _i2.RuntimeStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      availableReplicas: jsonSerialization['availableReplicas'] as int,
      desiredReplicas: jsonSerialization['desiredReplicas'] as int?,
    );
  }

  /// The mapped runtime status of the capsule.
  _i2.RuntimeStatus status;

  /// The number of replicas currently available (serving traffic).
  int availableReplicas;

  /// The number of desired replicas, if known. Reserved for future use.
  int? desiredReplicas;

  /// Returns a shallow copy of this [RuntimeStatusInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RuntimeStatusInfo copyWith({
    _i2.RuntimeStatus? status,
    int? availableReplicas,
    int? desiredReplicas,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuntimeStatusInfo',
      'status': status.toJson(),
      'availableReplicas': availableReplicas,
      if (desiredReplicas != null) 'desiredReplicas': desiredReplicas,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RuntimeStatusInfoImpl extends RuntimeStatusInfo {
  _RuntimeStatusInfoImpl({
    required _i2.RuntimeStatus status,
    required int availableReplicas,
    int? desiredReplicas,
  }) : super._(
         status: status,
         availableReplicas: availableReplicas,
         desiredReplicas: desiredReplicas,
       );

  /// Returns a shallow copy of this [RuntimeStatusInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RuntimeStatusInfo copyWith({
    _i2.RuntimeStatus? status,
    int? availableReplicas,
    Object? desiredReplicas = _Undefined,
  }) {
    return RuntimeStatusInfo(
      status: status ?? this.status,
      availableReplicas: availableReplicas ?? this.availableReplicas,
      desiredReplicas: desiredReplicas is int?
          ? desiredReplicas
          : this.desiredReplicas,
    );
  }
}

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

/// Scaling configuration for a compute size that supports variable replica scaling.
abstract class ComputeScalingInfo implements _i1.SerializableModel {
  ComputeScalingInfo._({
    required this.defaultMinReplicas,
    required this.defaultMaxReplicas,
    required this.allowedReplicasMin,
    required this.allowedReplicasMax,
  });

  factory ComputeScalingInfo({
    required int defaultMinReplicas,
    required int defaultMaxReplicas,
    required int allowedReplicasMin,
    required int allowedReplicasMax,
  }) = _ComputeScalingInfoImpl;

  factory ComputeScalingInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeScalingInfo(
      defaultMinReplicas: jsonSerialization['defaultMinReplicas'] as int,
      defaultMaxReplicas: jsonSerialization['defaultMaxReplicas'] as int,
      allowedReplicasMin: jsonSerialization['allowedReplicasMin'] as int,
      allowedReplicasMax: jsonSerialization['allowedReplicasMax'] as int,
    );
  }

  /// The default minimum number of replicas.
  int defaultMinReplicas;

  /// The default maximum number of replicas.
  int defaultMaxReplicas;

  /// The minimum number of replicas allowed.
  int allowedReplicasMin;

  /// The maximum number of replicas allowed.
  int allowedReplicasMax;

  /// Returns a shallow copy of this [ComputeScalingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ComputeScalingInfo copyWith({
    int? defaultMinReplicas,
    int? defaultMaxReplicas,
    int? allowedReplicasMin,
    int? allowedReplicasMax,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeScalingInfo',
      'defaultMinReplicas': defaultMinReplicas,
      'defaultMaxReplicas': defaultMaxReplicas,
      'allowedReplicasMin': allowedReplicasMin,
      'allowedReplicasMax': allowedReplicasMax,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ComputeScalingInfoImpl extends ComputeScalingInfo {
  _ComputeScalingInfoImpl({
    required int defaultMinReplicas,
    required int defaultMaxReplicas,
    required int allowedReplicasMin,
    required int allowedReplicasMax,
  }) : super._(
         defaultMinReplicas: defaultMinReplicas,
         defaultMaxReplicas: defaultMaxReplicas,
         allowedReplicasMin: allowedReplicasMin,
         allowedReplicasMax: allowedReplicasMax,
       );

  /// Returns a shallow copy of this [ComputeScalingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ComputeScalingInfo copyWith({
    int? defaultMinReplicas,
    int? defaultMaxReplicas,
    int? allowedReplicasMin,
    int? allowedReplicasMax,
  }) {
    return ComputeScalingInfo(
      defaultMinReplicas: defaultMinReplicas ?? this.defaultMinReplicas,
      defaultMaxReplicas: defaultMaxReplicas ?? this.defaultMaxReplicas,
      allowedReplicasMin: allowedReplicasMin ?? this.allowedReplicasMin,
      allowedReplicasMax: allowedReplicasMax ?? this.allowedReplicasMax,
    );
  }
}

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
import 'package:ground_control_client/src/protocol/protocol.dart' as _i2;

/// Definition of a compute product including defaults and constraints.
abstract class ComputeProductInfo implements _i1.SerializableModel {
  ComputeProductInfo._({
    required this.productId,
    required this.name,
    required this.description,
    required this.defaultInstanceType,
    required this.defaultMinReplicas,
    required this.defaultMaxReplicas,
    required this.allowedInstanceTypes,
    required this.allowedReplicasMin,
    required this.allowedReplicasMax,
  });

  factory ComputeProductInfo({
    required String productId,
    required String name,
    required String description,
    required String defaultInstanceType,
    required int defaultMinReplicas,
    required int defaultMaxReplicas,
    required List<String> allowedInstanceTypes,
    required int allowedReplicasMin,
    required int allowedReplicasMax,
  }) = _ComputeProductInfoImpl;

  factory ComputeProductInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeProductInfo(
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      defaultInstanceType: jsonSerialization['defaultInstanceType'] as String,
      defaultMinReplicas: jsonSerialization['defaultMinReplicas'] as int,
      defaultMaxReplicas: jsonSerialization['defaultMaxReplicas'] as int,
      allowedInstanceTypes: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['allowedInstanceTypes'],
      ),
      allowedReplicasMin: jsonSerialization['allowedReplicasMin'] as int,
      allowedReplicasMax: jsonSerialization['allowedReplicasMax'] as int,
    );
  }

  /// The id of the product.
  String productId;

  /// The user-friendly name of the product.
  String name;

  /// The user-friendly description of the product.
  String description;

  /// The default instance type name.
  String defaultInstanceType;

  /// The default minimum number of replicas.
  int defaultMinReplicas;

  /// The default maximum number of replicas.
  int defaultMaxReplicas;

  /// The allowed instance type names.
  List<String> allowedInstanceTypes;

  /// The minimum number of replicas allowed.
  int allowedReplicasMin;

  /// The maximum number of replicas allowed.
  int allowedReplicasMax;

  /// Returns a shallow copy of this [ComputeProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ComputeProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    String? defaultInstanceType,
    int? defaultMinReplicas,
    int? defaultMaxReplicas,
    List<String>? allowedInstanceTypes,
    int? allowedReplicasMin,
    int? allowedReplicasMax,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeProductInfo',
      'productId': productId,
      'name': name,
      'description': description,
      'defaultInstanceType': defaultInstanceType,
      'defaultMinReplicas': defaultMinReplicas,
      'defaultMaxReplicas': defaultMaxReplicas,
      'allowedInstanceTypes': allowedInstanceTypes.toJson(),
      'allowedReplicasMin': allowedReplicasMin,
      'allowedReplicasMax': allowedReplicasMax,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ComputeProductInfoImpl extends ComputeProductInfo {
  _ComputeProductInfoImpl({
    required String productId,
    required String name,
    required String description,
    required String defaultInstanceType,
    required int defaultMinReplicas,
    required int defaultMaxReplicas,
    required List<String> allowedInstanceTypes,
    required int allowedReplicasMin,
    required int allowedReplicasMax,
  }) : super._(
         productId: productId,
         name: name,
         description: description,
         defaultInstanceType: defaultInstanceType,
         defaultMinReplicas: defaultMinReplicas,
         defaultMaxReplicas: defaultMaxReplicas,
         allowedInstanceTypes: allowedInstanceTypes,
         allowedReplicasMin: allowedReplicasMin,
         allowedReplicasMax: allowedReplicasMax,
       );

  /// Returns a shallow copy of this [ComputeProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ComputeProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    String? defaultInstanceType,
    int? defaultMinReplicas,
    int? defaultMaxReplicas,
    List<String>? allowedInstanceTypes,
    int? allowedReplicasMin,
    int? allowedReplicasMax,
  }) {
    return ComputeProductInfo(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultInstanceType: defaultInstanceType ?? this.defaultInstanceType,
      defaultMinReplicas: defaultMinReplicas ?? this.defaultMinReplicas,
      defaultMaxReplicas: defaultMaxReplicas ?? this.defaultMaxReplicas,
      allowedInstanceTypes:
          allowedInstanceTypes ??
          this.allowedInstanceTypes.map((e0) => e0).toList(),
      allowedReplicasMin: allowedReplicasMin ?? this.allowedReplicasMin,
      allowedReplicasMax: allowedReplicasMax ?? this.allowedReplicasMax,
    );
  }
}

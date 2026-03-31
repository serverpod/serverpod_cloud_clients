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
import '../../../domains/products/models/compute_product_info.dart' as _i2;
import '../../../domains/capsules/models/compute_size_option.dart' as _i3;
import '../../../domains/products/models/compute_scaling_info.dart' as _i4;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i5;

/// A catalog of available compute products.
abstract class ComputeCatalogInfo implements _i1.SerializableModel {
  ComputeCatalogInfo._({
    required this.computes,
    required this.defaultCompute,
    required this.scaling,
  });

  factory ComputeCatalogInfo({
    required List<_i2.ComputeProductInfo> computes,
    required _i3.ComputeSizeOption defaultCompute,
    required _i4.ComputeScalingInfo scaling,
  }) = _ComputeCatalogInfoImpl;

  factory ComputeCatalogInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeCatalogInfo(
      computes: _i5.Protocol().deserialize<List<_i2.ComputeProductInfo>>(
        jsonSerialization['computes'],
      ),
      defaultCompute: _i3.ComputeSizeOption.fromJson(
        (jsonSerialization['defaultCompute'] as String),
      ),
      scaling: _i5.Protocol().deserialize<_i4.ComputeScalingInfo>(
        jsonSerialization['scaling'],
      ),
    );
  }

  /// The compute product definitions available.
  List<_i2.ComputeProductInfo> computes;

  /// The default compute product.
  _i3.ComputeSizeOption defaultCompute;

  /// Scaling configuration.
  _i4.ComputeScalingInfo scaling;

  /// Returns a shallow copy of this [ComputeCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ComputeCatalogInfo copyWith({
    List<_i2.ComputeProductInfo>? computes,
    _i3.ComputeSizeOption? defaultCompute,
    _i4.ComputeScalingInfo? scaling,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeCatalogInfo',
      'computes': computes.toJson(valueToJson: (v) => v.toJson()),
      'defaultCompute': defaultCompute.toJson(),
      'scaling': scaling.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ComputeCatalogInfoImpl extends ComputeCatalogInfo {
  _ComputeCatalogInfoImpl({
    required List<_i2.ComputeProductInfo> computes,
    required _i3.ComputeSizeOption defaultCompute,
    required _i4.ComputeScalingInfo scaling,
  }) : super._(
         computes: computes,
         defaultCompute: defaultCompute,
         scaling: scaling,
       );

  /// Returns a shallow copy of this [ComputeCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ComputeCatalogInfo copyWith({
    List<_i2.ComputeProductInfo>? computes,
    _i3.ComputeSizeOption? defaultCompute,
    _i4.ComputeScalingInfo? scaling,
  }) {
    return ComputeCatalogInfo(
      computes: computes ?? this.computes.map((e0) => e0.copyWith()).toList(),
      defaultCompute: defaultCompute ?? this.defaultCompute,
      scaling: scaling ?? this.scaling.copyWith(),
    );
  }
}

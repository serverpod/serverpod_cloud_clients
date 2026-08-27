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
import '../../../domains/capsules/models/compute_size_option.dart' as _ike5w393;
import '../../../domains/products/models/compute_product_info.dart'
    as _itbzu52c;
import '../../../domains/products/models/compute_scaling_info.dart'
    as _i6ffibot;

/// A catalog of available compute products.
abstract class ComputeCatalogInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ComputeCatalogInfo._({
    required this.computes,
    required this.defaultCompute,
    required this.scaling,
  });

  factory ComputeCatalogInfo({
    required List<_itbzu52c.ComputeProductInfo> computes,
    required _ike5w393.ComputeSizeOption defaultCompute,
    required _i6ffibot.ComputeScalingInfo scaling,
  }) = _ComputeCatalogInfoImpl;

  factory ComputeCatalogInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeCatalogInfo(
      computes: _iod2a87h.Protocol()
          .deserialize<List<_itbzu52c.ComputeProductInfo>>(
            jsonSerialization['computes'],
          ),
      defaultCompute: _ike5w393.ComputeSizeOption.fromJson(
        (jsonSerialization['defaultCompute'] as String),
      ),
      scaling: _iod2a87h.Protocol().deserialize<_i6ffibot.ComputeScalingInfo>(
        jsonSerialization['scaling'],
      ),
    );
  }

  /// The compute product definitions available.
  List<_itbzu52c.ComputeProductInfo> computes;

  /// The default compute product.
  _ike5w393.ComputeSizeOption defaultCompute;

  /// Scaling configuration.
  _i6ffibot.ComputeScalingInfo scaling;

  /// Returns a shallow copy of this [ComputeCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ComputeCatalogInfo copyWith({
    List<_itbzu52c.ComputeProductInfo>? computes,
    _ike5w393.ComputeSizeOption? defaultCompute,
    _i6ffibot.ComputeScalingInfo? scaling,
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ComputeCatalogInfo',
      'computes': computes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'defaultCompute': defaultCompute.toJson(),
      'scaling': scaling.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ComputeCatalogInfoImpl extends ComputeCatalogInfo {
  _ComputeCatalogInfoImpl({
    required List<_itbzu52c.ComputeProductInfo> computes,
    required _ike5w393.ComputeSizeOption defaultCompute,
    required _i6ffibot.ComputeScalingInfo scaling,
  }) : super._(
         computes: computes,
         defaultCompute: defaultCompute,
         scaling: scaling,
       );

  /// Returns a shallow copy of this [ComputeCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ComputeCatalogInfo copyWith({
    List<_itbzu52c.ComputeProductInfo>? computes,
    _ike5w393.ComputeSizeOption? defaultCompute,
    _i6ffibot.ComputeScalingInfo? scaling,
  }) {
    return ComputeCatalogInfo(
      computes: computes ?? this.computes.map((e0) => e0.copyWith()).toList(),
      defaultCompute: defaultCompute ?? this.defaultCompute,
      scaling: scaling ?? this.scaling.copyWith(),
    );
  }
}

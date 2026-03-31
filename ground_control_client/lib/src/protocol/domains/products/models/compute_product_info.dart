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
import '../../../domains/capsules/models/compute_size_option.dart' as _i2;

/// Definition of a compute product including defaults and constraints.
abstract class ComputeProductInfo implements _i1.SerializableModel {
  ComputeProductInfo._({
    required this.size,
    required this.productId,
    required this.name,
    required this.description,
  });

  factory ComputeProductInfo({
    required _i2.ComputeSizeOption size,
    required String productId,
    required String name,
    required String description,
  }) = _ComputeProductInfoImpl;

  factory ComputeProductInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeProductInfo(
      size: _i2.ComputeSizeOption.fromJson(
        (jsonSerialization['size'] as String),
      ),
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
    );
  }

  /// The compute size.
  _i2.ComputeSizeOption size;

  /// The id of the product.
  String productId;

  /// The user-friendly name of the product.
  String name;

  /// The user-friendly description of the product.
  String description;

  /// Returns a shallow copy of this [ComputeProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ComputeProductInfo copyWith({
    _i2.ComputeSizeOption? size,
    String? productId,
    String? name,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeProductInfo',
      'size': size.toJson(),
      'productId': productId,
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ComputeProductInfoImpl extends ComputeProductInfo {
  _ComputeProductInfoImpl({
    required _i2.ComputeSizeOption size,
    required String productId,
    required String name,
    required String description,
  }) : super._(
         size: size,
         productId: productId,
         name: name,
         description: description,
       );

  /// Returns a shallow copy of this [ComputeProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ComputeProductInfo copyWith({
    _i2.ComputeSizeOption? size,
    String? productId,
    String? name,
    String? description,
  }) {
    return ComputeProductInfo(
      size: size ?? this.size,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

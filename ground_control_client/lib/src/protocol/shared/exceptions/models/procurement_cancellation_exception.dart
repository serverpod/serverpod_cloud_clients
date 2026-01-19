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
import '../../../domains/products/models/product_type.dart' as _i2;

/// Exception thrown when the cancellation of a procured product failed.
///
/// This is distinct from access authorization, and from quota limits.
abstract class ProcurementCancellationException
    implements _i1.SerializableException, _i1.SerializableModel {
  ProcurementCancellationException._({
    required this.message,
    required this.productType,
    required this.productId,
  });

  factory ProcurementCancellationException({
    required String message,
    required _i2.ProductType productType,
    required String productId,
  }) = _ProcurementCancellationExceptionImpl;

  factory ProcurementCancellationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ProcurementCancellationException(
      message: jsonSerialization['message'] as String,
      productType: _i2.ProductType.fromJson(
        (jsonSerialization['productType'] as String),
      ),
      productId: jsonSerialization['productId'] as String,
    );
  }

  /// The reason the cancellation failed.
  String message;

  /// The type of the product that was being cancelled.
  _i2.ProductType productType;

  /// The id of the product that was being cancelled.
  String productId;

  /// Returns a shallow copy of this [ProcurementCancellationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProcurementCancellationException copyWith({
    String? message,
    _i2.ProductType? productType,
    String? productId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProcurementCancellationException',
      'message': message,
      'productType': productType.toJson(),
      'productId': productId,
    };
  }

  @override
  String toString() {
    return 'ProcurementCancellationException(message: $message, productType: $productType, productId: $productId)';
  }
}

class _ProcurementCancellationExceptionImpl
    extends ProcurementCancellationException {
  _ProcurementCancellationExceptionImpl({
    required String message,
    required _i2.ProductType productType,
    required String productId,
  }) : super._(
         message: message,
         productType: productType,
         productId: productId,
       );

  /// Returns a shallow copy of this [ProcurementCancellationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProcurementCancellationException copyWith({
    String? message,
    _i2.ProductType? productType,
    String? productId,
  }) {
    return ProcurementCancellationException(
      message: message ?? this.message,
      productType: productType ?? this.productType,
      productId: productId ?? this.productId,
    );
  }
}

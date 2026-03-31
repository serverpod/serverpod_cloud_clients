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
import '../../../domains/products/models/compute_catalog_info.dart' as _i2;
import '../../../domains/products/models/database_catalog_info.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Definition of a project product including its compute and database sub-products.
abstract class ProjectProductInfo implements _i1.SerializableModel {
  ProjectProductInfo._({
    required this.productId,
    required this.name,
    required this.description,
    required this.computeCatalog,
    required this.databaseCatalog,
  });

  factory ProjectProductInfo({
    required String productId,
    required String name,
    required String description,
    required _i2.ComputeCatalogInfo computeCatalog,
    required _i3.DatabaseCatalogInfo databaseCatalog,
  }) = _ProjectProductInfoImpl;

  factory ProjectProductInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectProductInfo(
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      computeCatalog: _i4.Protocol().deserialize<_i2.ComputeCatalogInfo>(
        jsonSerialization['computeCatalog'],
      ),
      databaseCatalog: _i4.Protocol().deserialize<_i3.DatabaseCatalogInfo>(
        jsonSerialization['databaseCatalog'],
      ),
    );
  }

  /// The id of the product.
  String productId;

  /// The user-friendly name of the product.
  String name;

  /// The user-friendly description of the product.
  String description;

  /// The compute products available under this project product.
  _i2.ComputeCatalogInfo computeCatalog;

  /// The database products available under this project product.
  _i3.DatabaseCatalogInfo databaseCatalog;

  /// Returns a shallow copy of this [ProjectProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    _i2.ComputeCatalogInfo? computeCatalog,
    _i3.DatabaseCatalogInfo? databaseCatalog,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectProductInfo',
      'productId': productId,
      'name': name,
      'description': description,
      'computeCatalog': computeCatalog.toJson(),
      'databaseCatalog': databaseCatalog.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProjectProductInfoImpl extends ProjectProductInfo {
  _ProjectProductInfoImpl({
    required String productId,
    required String name,
    required String description,
    required _i2.ComputeCatalogInfo computeCatalog,
    required _i3.DatabaseCatalogInfo databaseCatalog,
  }) : super._(
         productId: productId,
         name: name,
         description: description,
         computeCatalog: computeCatalog,
         databaseCatalog: databaseCatalog,
       );

  /// Returns a shallow copy of this [ProjectProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    _i2.ComputeCatalogInfo? computeCatalog,
    _i3.DatabaseCatalogInfo? databaseCatalog,
  }) {
    return ProjectProductInfo(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      computeCatalog: computeCatalog ?? this.computeCatalog.copyWith(),
      databaseCatalog: databaseCatalog ?? this.databaseCatalog.copyWith(),
    );
  }
}

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
import '../../../domains/products/models/compute_catalog_info.dart'
    as _ixot701a;
import '../../../domains/products/models/database_catalog_info.dart'
    as _ikaa1o73;

/// Definition of a project product including its compute and database sub-products.
abstract class ProjectProductInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _ixot701a.ComputeCatalogInfo computeCatalog,
    required _ikaa1o73.DatabaseCatalogInfo databaseCatalog,
  }) = _ProjectProductInfoImpl;

  factory ProjectProductInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectProductInfo(
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      computeCatalog: _iod2a87h.Protocol()
          .deserialize<_ixot701a.ComputeCatalogInfo>(
            jsonSerialization['computeCatalog'],
          ),
      databaseCatalog: _iod2a87h.Protocol()
          .deserialize<_ikaa1o73.DatabaseCatalogInfo>(
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
  _ixot701a.ComputeCatalogInfo computeCatalog;

  /// The database products available under this project product.
  _ikaa1o73.DatabaseCatalogInfo databaseCatalog;

  /// Returns a shallow copy of this [ProjectProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProjectProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    _ixot701a.ComputeCatalogInfo? computeCatalog,
    _ikaa1o73.DatabaseCatalogInfo? databaseCatalog,
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectProductInfo',
      'productId': productId,
      'name': name,
      'description': description,
      'computeCatalog': computeCatalog.toJsonForProtocol(),
      'databaseCatalog': databaseCatalog.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ProjectProductInfoImpl extends ProjectProductInfo {
  _ProjectProductInfoImpl({
    required String productId,
    required String name,
    required String description,
    required _ixot701a.ComputeCatalogInfo computeCatalog,
    required _ikaa1o73.DatabaseCatalogInfo databaseCatalog,
  }) : super._(
         productId: productId,
         name: name,
         description: description,
         computeCatalog: computeCatalog,
         databaseCatalog: databaseCatalog,
       );

  /// Returns a shallow copy of this [ProjectProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProjectProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    _ixot701a.ComputeCatalogInfo? computeCatalog,
    _ikaa1o73.DatabaseCatalogInfo? databaseCatalog,
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

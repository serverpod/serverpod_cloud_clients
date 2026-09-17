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
import '../../../domains/databases/models/database_size.dart' as _its7dxaf;
import '../../../domains/products/models/database_product_info.dart'
    as _in3ov0v7;

/// A catalog of available database products.
abstract class DatabaseCatalogInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DatabaseCatalogInfo._({required this.databases, this.defaultDatabase});

  factory DatabaseCatalogInfo({
    required List<_in3ov0v7.DatabaseProductInfo> databases,
    _its7dxaf.DatabaseSizeOption? defaultDatabase,
  }) = _DatabaseCatalogInfoImpl;

  factory DatabaseCatalogInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseCatalogInfo(
      databases: _iod2a87h.Protocol()
          .deserialize<List<_in3ov0v7.DatabaseProductInfo>>(
            jsonSerialization['databases'],
          ),
      defaultDatabase: jsonSerialization['defaultDatabase'] == null
          ? null
          : _its7dxaf.DatabaseSizeOption.fromJson(
              (jsonSerialization['defaultDatabase'] as String),
            ),
    );
  }

  /// The database product definitions available.
  List<_in3ov0v7.DatabaseProductInfo> databases;

  /// The default database product, if any.
  _its7dxaf.DatabaseSizeOption? defaultDatabase;

  /// Returns a shallow copy of this [DatabaseCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DatabaseCatalogInfo copyWith({
    List<_in3ov0v7.DatabaseProductInfo>? databases,
    _its7dxaf.DatabaseSizeOption? defaultDatabase,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseCatalogInfo',
      'databases': databases.toJson(valueToJson: (v) => v.toJson()),
      if (defaultDatabase != null) 'defaultDatabase': defaultDatabase?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseCatalogInfo',
      'databases': databases.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (defaultDatabase != null) 'defaultDatabase': defaultDatabase?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseCatalogInfoImpl extends DatabaseCatalogInfo {
  _DatabaseCatalogInfoImpl({
    required List<_in3ov0v7.DatabaseProductInfo> databases,
    _its7dxaf.DatabaseSizeOption? defaultDatabase,
  }) : super._(databases: databases, defaultDatabase: defaultDatabase);

  /// Returns a shallow copy of this [DatabaseCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DatabaseCatalogInfo copyWith({
    List<_in3ov0v7.DatabaseProductInfo>? databases,
    Object? defaultDatabase = _Undefined,
  }) {
    return DatabaseCatalogInfo(
      databases:
          databases ?? this.databases.map((e0) => e0.copyWith()).toList(),
      defaultDatabase: defaultDatabase is _its7dxaf.DatabaseSizeOption?
          ? defaultDatabase
          : this.defaultDatabase,
    );
  }
}

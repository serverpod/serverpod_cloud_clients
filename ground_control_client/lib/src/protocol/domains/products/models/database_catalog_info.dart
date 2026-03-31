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
import '../../../domains/products/models/database_product_info.dart' as _i2;
import '../../../features/databases/models/database_size.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// A catalog of available database products.
abstract class DatabaseCatalogInfo implements _i1.SerializableModel {
  DatabaseCatalogInfo._({required this.databases, this.defaultDatabase});

  factory DatabaseCatalogInfo({
    required List<_i2.DatabaseProductInfo> databases,
    _i3.DatabaseSizeOption? defaultDatabase,
  }) = _DatabaseCatalogInfoImpl;

  factory DatabaseCatalogInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseCatalogInfo(
      databases: _i4.Protocol().deserialize<List<_i2.DatabaseProductInfo>>(
        jsonSerialization['databases'],
      ),
      defaultDatabase: jsonSerialization['defaultDatabase'] == null
          ? null
          : _i3.DatabaseSizeOption.fromJson(
              (jsonSerialization['defaultDatabase'] as String),
            ),
    );
  }

  /// The database product definitions available.
  List<_i2.DatabaseProductInfo> databases;

  /// The default database product, if any.
  _i3.DatabaseSizeOption? defaultDatabase;

  /// Returns a shallow copy of this [DatabaseCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseCatalogInfo copyWith({
    List<_i2.DatabaseProductInfo>? databases,
    _i3.DatabaseSizeOption? defaultDatabase,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseCatalogInfoImpl extends DatabaseCatalogInfo {
  _DatabaseCatalogInfoImpl({
    required List<_i2.DatabaseProductInfo> databases,
    _i3.DatabaseSizeOption? defaultDatabase,
  }) : super._(databases: databases, defaultDatabase: defaultDatabase);

  /// Returns a shallow copy of this [DatabaseCatalogInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseCatalogInfo copyWith({
    List<_i2.DatabaseProductInfo>? databases,
    Object? defaultDatabase = _Undefined,
  }) {
    return DatabaseCatalogInfo(
      databases:
          databases ?? this.databases.map((e0) => e0.copyWith()).toList(),
      defaultDatabase: defaultDatabase is _i3.DatabaseSizeOption?
          ? defaultDatabase
          : this.defaultDatabase,
    );
  }
}

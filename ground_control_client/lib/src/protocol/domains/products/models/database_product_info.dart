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
import '../../../domains/products/models/database_size_info.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

/// Definition of a database product including defaults and constraints.
abstract class DatabaseProductInfo implements _i1.SerializableModel {
  DatabaseProductInfo._({
    required this.productId,
    required this.name,
    required this.description,
    required this.defaultSize,
    required this.allowedSizes,
    this.cuHoursPerMonthLimit,
    this.storageLimitGB,
  });

  factory DatabaseProductInfo({
    required String productId,
    required String name,
    required String description,
    required _i2.DatabaseSizeInfo defaultSize,
    required List<_i2.DatabaseSizeInfo> allowedSizes,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
  }) = _DatabaseProductInfoImpl;

  factory DatabaseProductInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseProductInfo(
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      defaultSize: _i3.Protocol().deserialize<_i2.DatabaseSizeInfo>(
        jsonSerialization['defaultSize'],
      ),
      allowedSizes: _i3.Protocol().deserialize<List<_i2.DatabaseSizeInfo>>(
        jsonSerialization['allowedSizes'],
      ),
      cuHoursPerMonthLimit: jsonSerialization['cuHoursPerMonthLimit'] as int?,
      storageLimitGB: jsonSerialization['storageLimitGB'] as int?,
    );
  }

  /// The id of the product.
  String productId;

  /// The user-friendly name of the product.
  String name;

  /// The user-friendly description of the product.
  String description;

  /// The default database size configuration.
  _i2.DatabaseSizeInfo defaultSize;

  /// The allowed database sizes with their configurations.
  List<_i2.DatabaseSizeInfo> allowedSizes;

  /// The limit on compute unit hours per month, if any.
  int? cuHoursPerMonthLimit;

  /// The storage limit in GB, if any.
  int? storageLimitGB;

  /// Returns a shallow copy of this [DatabaseProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    _i2.DatabaseSizeInfo? defaultSize,
    List<_i2.DatabaseSizeInfo>? allowedSizes,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseProductInfo',
      'productId': productId,
      'name': name,
      'description': description,
      'defaultSize': defaultSize.toJson(),
      'allowedSizes': allowedSizes.toJson(valueToJson: (v) => v.toJson()),
      if (cuHoursPerMonthLimit != null)
        'cuHoursPerMonthLimit': cuHoursPerMonthLimit,
      if (storageLimitGB != null) 'storageLimitGB': storageLimitGB,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseProductInfoImpl extends DatabaseProductInfo {
  _DatabaseProductInfoImpl({
    required String productId,
    required String name,
    required String description,
    required _i2.DatabaseSizeInfo defaultSize,
    required List<_i2.DatabaseSizeInfo> allowedSizes,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
  }) : super._(
         productId: productId,
         name: name,
         description: description,
         defaultSize: defaultSize,
         allowedSizes: allowedSizes,
         cuHoursPerMonthLimit: cuHoursPerMonthLimit,
         storageLimitGB: storageLimitGB,
       );

  /// Returns a shallow copy of this [DatabaseProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseProductInfo copyWith({
    String? productId,
    String? name,
    String? description,
    _i2.DatabaseSizeInfo? defaultSize,
    List<_i2.DatabaseSizeInfo>? allowedSizes,
    Object? cuHoursPerMonthLimit = _Undefined,
    Object? storageLimitGB = _Undefined,
  }) {
    return DatabaseProductInfo(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultSize: defaultSize ?? this.defaultSize.copyWith(),
      allowedSizes:
          allowedSizes ?? this.allowedSizes.map((e0) => e0.copyWith()).toList(),
      cuHoursPerMonthLimit: cuHoursPerMonthLimit is int?
          ? cuHoursPerMonthLimit
          : this.cuHoursPerMonthLimit,
      storageLimitGB: storageLimitGB is int?
          ? storageLimitGB
          : this.storageLimitGB,
    );
  }
}

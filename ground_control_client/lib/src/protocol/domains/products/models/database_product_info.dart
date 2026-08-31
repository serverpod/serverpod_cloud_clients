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
import '../../../domains/products/models/database_scaling_info.dart'
    as _in8146o7;

/// Definition of a database product including defaults and constraints.
abstract class DatabaseProductInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DatabaseProductInfo._({
    required this.size,
    required this.productId,
    required this.name,
    required this.description,
    this.scaling,
    this.cuHoursPerMonthLimit,
    this.storageLimitGB,
  });

  factory DatabaseProductInfo({
    required _its7dxaf.DatabaseSizeOption size,
    required String productId,
    required String name,
    required String description,
    _in8146o7.DatabaseScalingInfo? scaling,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
  }) = _DatabaseProductInfoImpl;

  factory DatabaseProductInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseProductInfo(
      size: _its7dxaf.DatabaseSizeOption.fromJson(
        (jsonSerialization['size'] as String),
      ),
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      scaling: jsonSerialization['scaling'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_in8146o7.DatabaseScalingInfo>(
              jsonSerialization['scaling'],
            ),
      cuHoursPerMonthLimit: jsonSerialization['cuHoursPerMonthLimit'] as int?,
      storageLimitGB: jsonSerialization['storageLimitGB'] as int?,
    );
  }

  /// The database size.
  _its7dxaf.DatabaseSizeOption size;

  /// The id of the product.
  String productId;

  /// The user-friendly name of the product.
  String name;

  /// The user-friendly description of the product.
  String description;

  /// Scaling configuration, if this size supports variable CU allocation.
  _in8146o7.DatabaseScalingInfo? scaling;

  /// The limit on compute unit hours per month, if any.
  int? cuHoursPerMonthLimit;

  /// The storage limit in GB, if any.
  int? storageLimitGB;

  /// Returns a shallow copy of this [DatabaseProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DatabaseProductInfo copyWith({
    _its7dxaf.DatabaseSizeOption? size,
    String? productId,
    String? name,
    String? description,
    _in8146o7.DatabaseScalingInfo? scaling,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseProductInfo',
      'size': size.toJson(),
      'productId': productId,
      'name': name,
      'description': description,
      if (scaling != null) 'scaling': scaling?.toJson(),
      if (cuHoursPerMonthLimit != null)
        'cuHoursPerMonthLimit': cuHoursPerMonthLimit,
      if (storageLimitGB != null) 'storageLimitGB': storageLimitGB,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseProductInfo',
      'size': size.toJson(),
      'productId': productId,
      'name': name,
      'description': description,
      if (scaling != null) 'scaling': scaling?.toJsonForProtocol(),
      if (cuHoursPerMonthLimit != null)
        'cuHoursPerMonthLimit': cuHoursPerMonthLimit,
      if (storageLimitGB != null) 'storageLimitGB': storageLimitGB,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseProductInfoImpl extends DatabaseProductInfo {
  _DatabaseProductInfoImpl({
    required _its7dxaf.DatabaseSizeOption size,
    required String productId,
    required String name,
    required String description,
    _in8146o7.DatabaseScalingInfo? scaling,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
  }) : super._(
         size: size,
         productId: productId,
         name: name,
         description: description,
         scaling: scaling,
         cuHoursPerMonthLimit: cuHoursPerMonthLimit,
         storageLimitGB: storageLimitGB,
       );

  /// Returns a shallow copy of this [DatabaseProductInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DatabaseProductInfo copyWith({
    _its7dxaf.DatabaseSizeOption? size,
    String? productId,
    String? name,
    String? description,
    Object? scaling = _Undefined,
    Object? cuHoursPerMonthLimit = _Undefined,
    Object? storageLimitGB = _Undefined,
  }) {
    return DatabaseProductInfo(
      size: size ?? this.size,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      scaling: scaling is _in8146o7.DatabaseScalingInfo?
          ? scaling
          : this.scaling?.copyWith(),
      cuHoursPerMonthLimit: cuHoursPerMonthLimit is int?
          ? cuHoursPerMonthLimit
          : this.cuHoursPerMonthLimit,
      storageLimitGB: storageLimitGB is int?
          ? storageLimitGB
          : this.storageLimitGB,
    );
  }
}

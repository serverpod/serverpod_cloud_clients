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

abstract class DatabaseInfo implements _i1.SerializableModel {
  DatabaseInfo._({
    required this.cloudCapsuleId,
    this.size,
    this.minCu,
    this.maxCu,
    required this.memoryMb,
    this.storageLimitGB,
    this.computeHoursLimit,
  });

  factory DatabaseInfo({
    required String cloudCapsuleId,
    String? size,
    double? minCu,
    double? maxCu,
    required int memoryMb,
    int? storageLimitGB,
    int? computeHoursLimit,
  }) = _DatabaseInfoImpl;

  factory DatabaseInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseInfo(
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      size: jsonSerialization['size'] as String?,
      minCu: (jsonSerialization['minCu'] as num?)?.toDouble(),
      maxCu: (jsonSerialization['maxCu'] as num?)?.toDouble(),
      memoryMb: jsonSerialization['memoryMb'] as int,
      storageLimitGB: jsonSerialization['storageLimitGB'] as int?,
      computeHoursLimit: jsonSerialization['computeHoursLimit'] as int?,
    );
  }

  /// The cloud capsule ID.
  String cloudCapsuleId;

  /// The size of the database, small, medium, large, large+.
  String? size;

  /// The minimum number of CPUs that the database can be scaled to.
  double? minCu;

  /// The maximum number of CPUs that the database can be scaled to.
  double? maxCu;

  /// The memory of the database in MB.
  int memoryMb;

  /// The storage limit of the database in GB.
  int? storageLimitGB;

  /// The compute hours limit of the database in hours.
  int? computeHoursLimit;

  /// Returns a shallow copy of this [DatabaseInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseInfo copyWith({
    String? cloudCapsuleId,
    String? size,
    double? minCu,
    double? maxCu,
    int? memoryMb,
    int? storageLimitGB,
    int? computeHoursLimit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseInfo',
      'cloudCapsuleId': cloudCapsuleId,
      if (size != null) 'size': size,
      if (minCu != null) 'minCu': minCu,
      if (maxCu != null) 'maxCu': maxCu,
      'memoryMb': memoryMb,
      if (storageLimitGB != null) 'storageLimitGB': storageLimitGB,
      if (computeHoursLimit != null) 'computeHoursLimit': computeHoursLimit,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseInfoImpl extends DatabaseInfo {
  _DatabaseInfoImpl({
    required String cloudCapsuleId,
    String? size,
    double? minCu,
    double? maxCu,
    required int memoryMb,
    int? storageLimitGB,
    int? computeHoursLimit,
  }) : super._(
         cloudCapsuleId: cloudCapsuleId,
         size: size,
         minCu: minCu,
         maxCu: maxCu,
         memoryMb: memoryMb,
         storageLimitGB: storageLimitGB,
         computeHoursLimit: computeHoursLimit,
       );

  /// Returns a shallow copy of this [DatabaseInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseInfo copyWith({
    String? cloudCapsuleId,
    Object? size = _Undefined,
    Object? minCu = _Undefined,
    Object? maxCu = _Undefined,
    int? memoryMb,
    Object? storageLimitGB = _Undefined,
    Object? computeHoursLimit = _Undefined,
  }) {
    return DatabaseInfo(
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      size: size is String? ? size : this.size,
      minCu: minCu is double? ? minCu : this.minCu,
      maxCu: maxCu is double? ? maxCu : this.maxCu,
      memoryMb: memoryMb ?? this.memoryMb,
      storageLimitGB: storageLimitGB is int?
          ? storageLimitGB
          : this.storageLimitGB,
      computeHoursLimit: computeHoursLimit is int?
          ? computeHoursLimit
          : this.computeHoursLimit,
    );
  }
}

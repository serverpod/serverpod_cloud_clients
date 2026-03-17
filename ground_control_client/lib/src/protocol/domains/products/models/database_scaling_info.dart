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
import 'package:ground_control_client/src/protocol/protocol.dart' as _i2;

/// Scaling configuration for a database size that supports variable CU allocation.
abstract class DatabaseScalingInfo implements _i1.SerializableModel {
  DatabaseScalingInfo._({
    required this.defaultMinCu,
    required this.defaultMaxCu,
    required this.allowedCuValues,
    required this.maxCuSpread,
  });

  factory DatabaseScalingInfo({
    required double defaultMinCu,
    required double defaultMaxCu,
    required List<double> allowedCuValues,
    required int maxCuSpread,
  }) = _DatabaseScalingInfoImpl;

  factory DatabaseScalingInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseScalingInfo(
      defaultMinCu: (jsonSerialization['defaultMinCu'] as num).toDouble(),
      defaultMaxCu: (jsonSerialization['defaultMaxCu'] as num).toDouble(),
      allowedCuValues: _i2.Protocol().deserialize<List<double>>(
        jsonSerialization['allowedCuValues'],
      ),
      maxCuSpread: jsonSerialization['maxCuSpread'] as int,
    );
  }

  /// The default minimum compute units for this size.
  double defaultMinCu;

  /// The default maximum compute units for this size.
  double defaultMaxCu;

  /// The compute unit values that may be selected for min and max CU.
  List<double> allowedCuValues;

  /// The maximum allowed spread between the selected min and max CU.
  int maxCuSpread;

  /// Returns a shallow copy of this [DatabaseScalingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseScalingInfo copyWith({
    double? defaultMinCu,
    double? defaultMaxCu,
    List<double>? allowedCuValues,
    int? maxCuSpread,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseScalingInfo',
      'defaultMinCu': defaultMinCu,
      'defaultMaxCu': defaultMaxCu,
      'allowedCuValues': allowedCuValues.toJson(),
      'maxCuSpread': maxCuSpread,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DatabaseScalingInfoImpl extends DatabaseScalingInfo {
  _DatabaseScalingInfoImpl({
    required double defaultMinCu,
    required double defaultMaxCu,
    required List<double> allowedCuValues,
    required int maxCuSpread,
  }) : super._(
         defaultMinCu: defaultMinCu,
         defaultMaxCu: defaultMaxCu,
         allowedCuValues: allowedCuValues,
         maxCuSpread: maxCuSpread,
       );

  /// Returns a shallow copy of this [DatabaseScalingInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseScalingInfo copyWith({
    double? defaultMinCu,
    double? defaultMaxCu,
    List<double>? allowedCuValues,
    int? maxCuSpread,
  }) {
    return DatabaseScalingInfo(
      defaultMinCu: defaultMinCu ?? this.defaultMinCu,
      defaultMaxCu: defaultMaxCu ?? this.defaultMaxCu,
      allowedCuValues:
          allowedCuValues ?? this.allowedCuValues.map((e0) => e0).toList(),
      maxCuSpread: maxCuSpread ?? this.maxCuSpread,
    );
  }
}

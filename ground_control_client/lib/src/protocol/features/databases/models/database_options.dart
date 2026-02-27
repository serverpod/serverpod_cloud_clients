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

abstract class DatabaseOptions implements _i1.SerializableModel {
  DatabaseOptions._({
    required this.availableCuValues,
    this.currentMinCu,
    this.currentMaxCu,
    required this.hasDatabaseEnabled,
  });

  factory DatabaseOptions({
    required List<double> availableCuValues,
    double? currentMinCu,
    double? currentMaxCu,
    required bool hasDatabaseEnabled,
  }) = _DatabaseOptionsImpl;

  factory DatabaseOptions.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseOptions(
      availableCuValues: _i2.Protocol().deserialize<List<double>>(
        jsonSerialization['availableCuValues'],
      ),
      currentMinCu: (jsonSerialization['currentMinCu'] as num?)?.toDouble(),
      currentMaxCu: (jsonSerialization['currentMaxCu'] as num?)?.toDouble(),
      hasDatabaseEnabled: jsonSerialization['hasDatabaseEnabled'] as bool,
    );
  }

  List<double> availableCuValues;

  double? currentMinCu;

  double? currentMaxCu;

  bool hasDatabaseEnabled;

  /// Returns a shallow copy of this [DatabaseOptions]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseOptions copyWith({
    List<double>? availableCuValues,
    double? currentMinCu,
    double? currentMaxCu,
    bool? hasDatabaseEnabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseOptions',
      'availableCuValues': availableCuValues.toJson(),
      if (currentMinCu != null) 'currentMinCu': currentMinCu,
      if (currentMaxCu != null) 'currentMaxCu': currentMaxCu,
      'hasDatabaseEnabled': hasDatabaseEnabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseOptionsImpl extends DatabaseOptions {
  _DatabaseOptionsImpl({
    required List<double> availableCuValues,
    double? currentMinCu,
    double? currentMaxCu,
    required bool hasDatabaseEnabled,
  }) : super._(
         availableCuValues: availableCuValues,
         currentMinCu: currentMinCu,
         currentMaxCu: currentMaxCu,
         hasDatabaseEnabled: hasDatabaseEnabled,
       );

  /// Returns a shallow copy of this [DatabaseOptions]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseOptions copyWith({
    List<double>? availableCuValues,
    Object? currentMinCu = _Undefined,
    Object? currentMaxCu = _Undefined,
    bool? hasDatabaseEnabled,
  }) {
    return DatabaseOptions(
      availableCuValues:
          availableCuValues ?? this.availableCuValues.map((e0) => e0).toList(),
      currentMinCu: currentMinCu is double? ? currentMinCu : this.currentMinCu,
      currentMaxCu: currentMaxCu is double? ? currentMaxCu : this.currentMaxCu,
      hasDatabaseEnabled: hasDatabaseEnabled ?? this.hasDatabaseEnabled,
    );
  }
}

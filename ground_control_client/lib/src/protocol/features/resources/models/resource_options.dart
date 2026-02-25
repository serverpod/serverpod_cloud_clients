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

abstract class ResourceOptions implements _i1.SerializableModel {
  ResourceOptions._({
    required this.availableComputeSizes,
    required this.currentComputeSize,
    required this.availableDatabaseCuValues,
    this.currentDatabaseMinCu,
    this.currentDatabaseMaxCu,
    required this.hasDatabaseEnabled,
  });

  factory ResourceOptions({
    required List<String> availableComputeSizes,
    required String currentComputeSize,
    required List<double> availableDatabaseCuValues,
    double? currentDatabaseMinCu,
    double? currentDatabaseMaxCu,
    required bool hasDatabaseEnabled,
  }) = _ResourceOptionsImpl;

  factory ResourceOptions.fromJson(Map<String, dynamic> jsonSerialization) {
    return ResourceOptions(
      availableComputeSizes: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['availableComputeSizes'],
      ),
      currentComputeSize: jsonSerialization['currentComputeSize'] as String,
      availableDatabaseCuValues: _i2.Protocol().deserialize<List<double>>(
        jsonSerialization['availableDatabaseCuValues'],
      ),
      currentDatabaseMinCu: (jsonSerialization['currentDatabaseMinCu'] as num?)
          ?.toDouble(),
      currentDatabaseMaxCu: (jsonSerialization['currentDatabaseMaxCu'] as num?)
          ?.toDouble(),
      hasDatabaseEnabled: jsonSerialization['hasDatabaseEnabled'] as bool,
    );
  }

  List<String> availableComputeSizes;

  String currentComputeSize;

  List<double> availableDatabaseCuValues;

  double? currentDatabaseMinCu;

  double? currentDatabaseMaxCu;

  bool hasDatabaseEnabled;

  /// Returns a shallow copy of this [ResourceOptions]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ResourceOptions copyWith({
    List<String>? availableComputeSizes,
    String? currentComputeSize,
    List<double>? availableDatabaseCuValues,
    double? currentDatabaseMinCu,
    double? currentDatabaseMaxCu,
    bool? hasDatabaseEnabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ResourceOptions',
      'availableComputeSizes': availableComputeSizes.toJson(),
      'currentComputeSize': currentComputeSize,
      'availableDatabaseCuValues': availableDatabaseCuValues.toJson(),
      if (currentDatabaseMinCu != null)
        'currentDatabaseMinCu': currentDatabaseMinCu,
      if (currentDatabaseMaxCu != null)
        'currentDatabaseMaxCu': currentDatabaseMaxCu,
      'hasDatabaseEnabled': hasDatabaseEnabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ResourceOptionsImpl extends ResourceOptions {
  _ResourceOptionsImpl({
    required List<String> availableComputeSizes,
    required String currentComputeSize,
    required List<double> availableDatabaseCuValues,
    double? currentDatabaseMinCu,
    double? currentDatabaseMaxCu,
    required bool hasDatabaseEnabled,
  }) : super._(
         availableComputeSizes: availableComputeSizes,
         currentComputeSize: currentComputeSize,
         availableDatabaseCuValues: availableDatabaseCuValues,
         currentDatabaseMinCu: currentDatabaseMinCu,
         currentDatabaseMaxCu: currentDatabaseMaxCu,
         hasDatabaseEnabled: hasDatabaseEnabled,
       );

  /// Returns a shallow copy of this [ResourceOptions]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ResourceOptions copyWith({
    List<String>? availableComputeSizes,
    String? currentComputeSize,
    List<double>? availableDatabaseCuValues,
    Object? currentDatabaseMinCu = _Undefined,
    Object? currentDatabaseMaxCu = _Undefined,
    bool? hasDatabaseEnabled,
  }) {
    return ResourceOptions(
      availableComputeSizes:
          availableComputeSizes ??
          this.availableComputeSizes.map((e0) => e0).toList(),
      currentComputeSize: currentComputeSize ?? this.currentComputeSize,
      availableDatabaseCuValues:
          availableDatabaseCuValues ??
          this.availableDatabaseCuValues.map((e0) => e0).toList(),
      currentDatabaseMinCu: currentDatabaseMinCu is double?
          ? currentDatabaseMinCu
          : this.currentDatabaseMinCu,
      currentDatabaseMaxCu: currentDatabaseMaxCu is double?
          ? currentDatabaseMaxCu
          : this.currentDatabaseMaxCu,
      hasDatabaseEnabled: hasDatabaseEnabled ?? this.hasDatabaseEnabled,
    );
  }
}

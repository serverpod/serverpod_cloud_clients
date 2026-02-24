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

abstract class DatabaseScaling implements _i1.SerializableModel {
  DatabaseScaling._({required this.minCu, required this.maxCu});

  factory DatabaseScaling({required double minCu, required double maxCu}) =
      _DatabaseScalingImpl;

  factory DatabaseScaling.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseScaling(
      minCu: (jsonSerialization['minCu'] as num).toDouble(),
      maxCu: (jsonSerialization['maxCu'] as num).toDouble(),
    );
  }

  double minCu;

  double maxCu;

  /// Returns a shallow copy of this [DatabaseScaling]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseScaling copyWith({double? minCu, double? maxCu});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'DatabaseScaling', 'minCu': minCu, 'maxCu': maxCu};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DatabaseScalingImpl extends DatabaseScaling {
  _DatabaseScalingImpl({required double minCu, required double maxCu})
    : super._(minCu: minCu, maxCu: maxCu);

  /// Returns a shallow copy of this [DatabaseScaling]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseScaling copyWith({double? minCu, double? maxCu}) {
    return DatabaseScaling(
      minCu: minCu ?? this.minCu,
      maxCu: maxCu ?? this.maxCu,
    );
  }
}

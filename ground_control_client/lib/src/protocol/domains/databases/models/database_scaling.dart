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

import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/databases/models/database_size.dart' as _its7dxaf;

abstract class DatabaseScaling
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DatabaseScaling._({
    required this.minCu,
    required this.maxCu,
    required this.size,
  });

  factory DatabaseScaling({
    required double minCu,
    required double maxCu,
    required _its7dxaf.DatabaseSizeOption size,
  }) = _DatabaseScalingImpl;

  factory DatabaseScaling.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseScaling(
      minCu: (jsonSerialization['minCu'] as num).toDouble(),
      maxCu: (jsonSerialization['maxCu'] as num).toDouble(),
      size: _its7dxaf.DatabaseSizeOption.fromJson(
        (jsonSerialization['size'] as String),
      ),
    );
  }

  double minCu;

  double maxCu;

  _its7dxaf.DatabaseSizeOption size;

  /// Returns a shallow copy of this [DatabaseScaling]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DatabaseScaling copyWith({
    double? minCu,
    double? maxCu,
    _its7dxaf.DatabaseSizeOption? size,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseScaling',
      'minCu': minCu,
      'maxCu': maxCu,
      'size': size.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseScaling',
      'minCu': minCu,
      'maxCu': maxCu,
      'size': size.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DatabaseScalingImpl extends DatabaseScaling {
  _DatabaseScalingImpl({
    required double minCu,
    required double maxCu,
    required _its7dxaf.DatabaseSizeOption size,
  }) : super._(minCu: minCu, maxCu: maxCu, size: size);

  /// Returns a shallow copy of this [DatabaseScaling]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DatabaseScaling copyWith({
    double? minCu,
    double? maxCu,
    _its7dxaf.DatabaseSizeOption? size,
  }) {
    return DatabaseScaling(
      minCu: minCu ?? this.minCu,
      maxCu: maxCu ?? this.maxCu,
      size: size ?? this.size,
    );
  }
}

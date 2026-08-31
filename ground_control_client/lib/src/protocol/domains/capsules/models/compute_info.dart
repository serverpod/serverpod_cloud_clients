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
import '../../../domains/capsules/models/compute_size_option.dart' as _ike5w393;

abstract class ComputeInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ComputeInfo._({
    required this.cloudCapsuleId,
    required this.size,
    required this.minInstances,
    required this.maxInstances,
    required this.memoryMb,
  });

  factory ComputeInfo({
    required String cloudCapsuleId,
    required _ike5w393.ComputeSizeOption size,
    required int minInstances,
    required int maxInstances,
    required int memoryMb,
  }) = _ComputeInfoImpl;

  factory ComputeInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ComputeInfo(
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      size: _ike5w393.ComputeSizeOption.fromJson(
        (jsonSerialization['size'] as String),
      ),
      minInstances: jsonSerialization['minInstances'] as int,
      maxInstances: jsonSerialization['maxInstances'] as int,
      memoryMb: jsonSerialization['memoryMb'] as int,
    );
  }

  /// The globally unique identifier of the capsule.
  String cloudCapsuleId;

  /// The size of the capsule compute. small, medium, large, or unknown.
  /// A value of unknown means the size could not be determined.
  _ike5w393.ComputeSizeOption size;

  /// The minimum number of podlets the capsule can scale to.
  int minInstances;

  /// The maximum number of podlets the capsule can scale to.
  int maxInstances;

  /// The memory of the capsule compute in megabytes.
  int memoryMb;

  /// Returns a shallow copy of this [ComputeInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ComputeInfo copyWith({
    String? cloudCapsuleId,
    _ike5w393.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    int? memoryMb,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ComputeInfo',
      'cloudCapsuleId': cloudCapsuleId,
      'size': size.toJson(),
      'minInstances': minInstances,
      'maxInstances': maxInstances,
      'memoryMb': memoryMb,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ComputeInfo',
      'cloudCapsuleId': cloudCapsuleId,
      'size': size.toJson(),
      'minInstances': minInstances,
      'maxInstances': maxInstances,
      'memoryMb': memoryMb,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ComputeInfoImpl extends ComputeInfo {
  _ComputeInfoImpl({
    required String cloudCapsuleId,
    required _ike5w393.ComputeSizeOption size,
    required int minInstances,
    required int maxInstances,
    required int memoryMb,
  }) : super._(
         cloudCapsuleId: cloudCapsuleId,
         size: size,
         minInstances: minInstances,
         maxInstances: maxInstances,
         memoryMb: memoryMb,
       );

  /// Returns a shallow copy of this [ComputeInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ComputeInfo copyWith({
    String? cloudCapsuleId,
    _ike5w393.ComputeSizeOption? size,
    int? minInstances,
    int? maxInstances,
    int? memoryMb,
  }) {
    return ComputeInfo(
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      size: size ?? this.size,
      minInstances: minInstances ?? this.minInstances,
      maxInstances: maxInstances ?? this.maxInstances,
      memoryMb: memoryMb ?? this.memoryMb,
    );
  }
}

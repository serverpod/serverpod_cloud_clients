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

abstract class BucketQuota implements _i1.SerializableModel {
  BucketQuota._({this.sizeBytes});

  factory BucketQuota({int? sizeBytes}) = _BucketQuotaImpl;

  factory BucketQuota.fromJson(Map<String, dynamic> jsonSerialization) {
    return BucketQuota(sizeBytes: jsonSerialization['sizeBytes'] as int?);
  }

  int? sizeBytes;

  /// Returns a shallow copy of this [BucketQuota]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BucketQuota copyWith({int? sizeBytes});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketQuota',
      if (sizeBytes != null) 'sizeBytes': sizeBytes,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BucketQuotaImpl extends BucketQuota {
  _BucketQuotaImpl({int? sizeBytes}) : super._(sizeBytes: sizeBytes);

  /// Returns a shallow copy of this [BucketQuota]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BucketQuota copyWith({Object? sizeBytes = _Undefined}) {
    return BucketQuota(
      sizeBytes: sizeBytes is int? ? sizeBytes : this.sizeBytes,
    );
  }
}

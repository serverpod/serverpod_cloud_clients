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
import '../../../domains/buckets/models/bucket_provider.dart' as _i2;
import '../../../domains/buckets/models/bucket_visibility.dart' as _i3;
import '../../../domains/buckets/models/bucket_status.dart' as _i4;
import '../../../domains/buckets/models/bucket_quota.dart' as _i5;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i6;

abstract class BucketResource implements _i1.SerializableModel {
  BucketResource._({
    this.id,
    required this.cloudCapsuleId,
    required this.provider,
    required this.storageId,
    required this.visibility,
    required this.bucketName,
    required this.region,
    required this.status,
    required this.quota,
  });

  factory BucketResource({
    int? id,
    required String cloudCapsuleId,
    required _i2.BucketProvider provider,
    required String storageId,
    required _i3.BucketVisibility visibility,
    required String bucketName,
    required String region,
    required _i4.BucketStatus status,
    required _i5.BucketQuota quota,
  }) = _BucketResourceImpl;

  factory BucketResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return BucketResource(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      provider: _i2.BucketProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      storageId: jsonSerialization['storageId'] as String,
      visibility: _i3.BucketVisibility.fromJson(
        (jsonSerialization['visibility'] as String),
      ),
      bucketName: jsonSerialization['bucketName'] as String,
      region: jsonSerialization['region'] as String,
      status: _i4.BucketStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      quota: _i6.Protocol().deserialize<_i5.BucketQuota>(
        jsonSerialization['quota'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cloudCapsuleId;

  _i2.BucketProvider provider;

  String storageId;

  _i3.BucketVisibility visibility;

  String bucketName;

  String region;

  _i4.BucketStatus status;

  _i5.BucketQuota quota;

  /// Returns a shallow copy of this [BucketResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BucketResource copyWith({
    int? id,
    String? cloudCapsuleId,
    _i2.BucketProvider? provider,
    String? storageId,
    _i3.BucketVisibility? visibility,
    String? bucketName,
    String? region,
    _i4.BucketStatus? status,
    _i5.BucketQuota? quota,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketResource',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'provider': provider.toJson(),
      'storageId': storageId,
      'visibility': visibility.toJson(),
      'bucketName': bucketName,
      'region': region,
      'status': status.toJson(),
      'quota': quota.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BucketResourceImpl extends BucketResource {
  _BucketResourceImpl({
    int? id,
    required String cloudCapsuleId,
    required _i2.BucketProvider provider,
    required String storageId,
    required _i3.BucketVisibility visibility,
    required String bucketName,
    required String region,
    required _i4.BucketStatus status,
    required _i5.BucketQuota quota,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         provider: provider,
         storageId: storageId,
         visibility: visibility,
         bucketName: bucketName,
         region: region,
         status: status,
         quota: quota,
       );

  /// Returns a shallow copy of this [BucketResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BucketResource copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    _i2.BucketProvider? provider,
    String? storageId,
    _i3.BucketVisibility? visibility,
    String? bucketName,
    String? region,
    _i4.BucketStatus? status,
    _i5.BucketQuota? quota,
  }) {
    return BucketResource(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      provider: provider ?? this.provider,
      storageId: storageId ?? this.storageId,
      visibility: visibility ?? this.visibility,
      bucketName: bucketName ?? this.bucketName,
      region: region ?? this.region,
      status: status ?? this.status,
      quota: quota ?? this.quota.copyWith(),
    );
  }
}

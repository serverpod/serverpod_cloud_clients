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
import '../../../domains/buckets/models/bucket_service_account_status.dart'
    as _i2;

abstract class BucketServiceAccount implements _i1.SerializableModel {
  BucketServiceAccount._({
    this.id,
    required this.cloudCapsuleId,
    required this.saEmail,
    this.activeKeyId,
    required this.status,
  });

  factory BucketServiceAccount({
    int? id,
    required String cloudCapsuleId,
    required String saEmail,
    String? activeKeyId,
    required _i2.BucketServiceAccountStatus status,
  }) = _BucketServiceAccountImpl;

  factory BucketServiceAccount.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return BucketServiceAccount(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      saEmail: jsonSerialization['saEmail'] as String,
      activeKeyId: jsonSerialization['activeKeyId'] as String?,
      status: _i2.BucketServiceAccountStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cloudCapsuleId;

  String saEmail;

  String? activeKeyId;

  _i2.BucketServiceAccountStatus status;

  /// Returns a shallow copy of this [BucketServiceAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BucketServiceAccount copyWith({
    int? id,
    String? cloudCapsuleId,
    String? saEmail,
    String? activeKeyId,
    _i2.BucketServiceAccountStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketServiceAccount',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'saEmail': saEmail,
      if (activeKeyId != null) 'activeKeyId': activeKeyId,
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BucketServiceAccountImpl extends BucketServiceAccount {
  _BucketServiceAccountImpl({
    int? id,
    required String cloudCapsuleId,
    required String saEmail,
    String? activeKeyId,
    required _i2.BucketServiceAccountStatus status,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         saEmail: saEmail,
         activeKeyId: activeKeyId,
         status: status,
       );

  /// Returns a shallow copy of this [BucketServiceAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BucketServiceAccount copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    String? saEmail,
    Object? activeKeyId = _Undefined,
    _i2.BucketServiceAccountStatus? status,
  }) {
    return BucketServiceAccount(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      saEmail: saEmail ?? this.saEmail,
      activeKeyId: activeKeyId is String? ? activeKeyId : this.activeKeyId,
      status: status ?? this.status,
    );
  }
}

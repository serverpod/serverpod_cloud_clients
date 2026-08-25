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
import '../../../domains/databases/models/database_provisioning_status.dart'
    as _i2;
import '../../../domains/databases/models/database_scaling.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Tracks an in-flight (or failed, or being torn down) database provisioning
/// for a capsule. A row here means the capsule's database is not ready yet;
/// once provisioning succeeds this row is deleted and a `DatabaseResource`
/// row exists instead.
///
/// The row carries the fully resolved provisioning configuration, so the
/// worker that acts on it needs no product or billing reads. Those inputs can
/// drift between the request and the delivery of its message: a plan change,
/// a cancelled procurement or a removed payment method would otherwise fail a
/// provisioning that was already paid for and promised to the user.
abstract class DatabaseProvisioning
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DatabaseProvisioning._({
    this.id,
    required this.cloudCapsuleId,
    required this.status,
    required this.scaling,
    this.cuHoursPerMonthLimit,
    this.storageLimitGB,
    required this.procurementResourceId,
    this.providerId,
    int? attempts,
    this.lastError,
    this.startedAt,
    DateTime? createdAt,
  }) : attempts = attempts ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory DatabaseProvisioning({
    int? id,
    required String cloudCapsuleId,
    required _i2.DatabaseProvisioningStatus status,
    required _i3.DatabaseScaling scaling,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
    required String procurementResourceId,
    String? providerId,
    int? attempts,
    String? lastError,
    DateTime? startedAt,
    DateTime? createdAt,
  }) = _DatabaseProvisioningImpl;

  factory DatabaseProvisioning.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DatabaseProvisioning(
      id: jsonSerialization['id'] as int?,
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      status: _i2.DatabaseProvisioningStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      scaling: _i4.Protocol().deserialize<_i3.DatabaseScaling>(
        jsonSerialization['scaling'],
      ),
      cuHoursPerMonthLimit: jsonSerialization['cuHoursPerMonthLimit'] as int?,
      storageLimitGB: jsonSerialization['storageLimitGB'] as int?,
      procurementResourceId:
          jsonSerialization['procurementResourceId'] as String,
      providerId: jsonSerialization['providerId'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String cloudCapsuleId;

  _i2.DatabaseProvisioningStatus status;

  /// The database size and CU range resolved at registration time.
  /// `minCu` and `maxCu` are the `requestCu` and `limitCu` of the resolved
  /// `CapsuleDbConfiguration`.
  _i3.DatabaseScaling scaling;

  /// Compute-hours quota from the resolved `CapsuleDbConfiguration`.
  /// Null means no limit.
  int? cuHoursPerMonthLimit;

  /// Storage quota from the resolved `CapsuleDbConfiguration`.
  /// Null means no limit.
  int? storageLimitGB;

  /// The product-allocation resourceId this provisioning is billed under.
  /// Always the cloudCapsuleId — set at registration, before the external
  /// database (and therefore its provider id) exists.
  String procurementResourceId;

  /// The external database id, set as soon as the provisioning call returns
  /// it and before any further external calls, so a crash after this point
  /// can adopt the existing external resource instead of creating another.
  String? providerId;

  /// Number of provisioning attempts made so far, including the current one.
  int attempts;

  /// The error message from the most recent failed attempt.
  String? lastError;

  /// When the current `provisioning` attempt was claimed. Used as a lease:
  /// an attempt older than the lease duration is considered abandoned and
  /// may be reclaimed.
  DateTime? startedAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [DatabaseProvisioning]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseProvisioning copyWith({
    int? id,
    String? cloudCapsuleId,
    _i2.DatabaseProvisioningStatus? status,
    _i3.DatabaseScaling? scaling,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
    String? procurementResourceId,
    String? providerId,
    int? attempts,
    String? lastError,
    DateTime? startedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseProvisioning',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'status': status.toJson(),
      'scaling': scaling.toJson(),
      if (cuHoursPerMonthLimit != null)
        'cuHoursPerMonthLimit': cuHoursPerMonthLimit,
      if (storageLimitGB != null) 'storageLimitGB': storageLimitGB,
      'procurementResourceId': procurementResourceId,
      if (providerId != null) 'providerId': providerId,
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseProvisioning',
      if (id != null) 'id': id,
      'cloudCapsuleId': cloudCapsuleId,
      'status': status.toJson(),
      'scaling': scaling.toJsonForProtocol(),
      if (cuHoursPerMonthLimit != null)
        'cuHoursPerMonthLimit': cuHoursPerMonthLimit,
      if (storageLimitGB != null) 'storageLimitGB': storageLimitGB,
      'procurementResourceId': procurementResourceId,
      if (providerId != null) 'providerId': providerId,
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseProvisioningImpl extends DatabaseProvisioning {
  _DatabaseProvisioningImpl({
    int? id,
    required String cloudCapsuleId,
    required _i2.DatabaseProvisioningStatus status,
    required _i3.DatabaseScaling scaling,
    int? cuHoursPerMonthLimit,
    int? storageLimitGB,
    required String procurementResourceId,
    String? providerId,
    int? attempts,
    String? lastError,
    DateTime? startedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         cloudCapsuleId: cloudCapsuleId,
         status: status,
         scaling: scaling,
         cuHoursPerMonthLimit: cuHoursPerMonthLimit,
         storageLimitGB: storageLimitGB,
         procurementResourceId: procurementResourceId,
         providerId: providerId,
         attempts: attempts,
         lastError: lastError,
         startedAt: startedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DatabaseProvisioning]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseProvisioning copyWith({
    Object? id = _Undefined,
    String? cloudCapsuleId,
    _i2.DatabaseProvisioningStatus? status,
    _i3.DatabaseScaling? scaling,
    Object? cuHoursPerMonthLimit = _Undefined,
    Object? storageLimitGB = _Undefined,
    String? procurementResourceId,
    Object? providerId = _Undefined,
    int? attempts,
    Object? lastError = _Undefined,
    Object? startedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return DatabaseProvisioning(
      id: id is int? ? id : this.id,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      status: status ?? this.status,
      scaling: scaling ?? this.scaling.copyWith(),
      cuHoursPerMonthLimit: cuHoursPerMonthLimit is int?
          ? cuHoursPerMonthLimit
          : this.cuHoursPerMonthLimit,
      storageLimitGB: storageLimitGB is int?
          ? storageLimitGB
          : this.storageLimitGB,
      procurementResourceId:
          procurementResourceId ?? this.procurementResourceId,
      providerId: providerId is String? ? providerId : this.providerId,
      attempts: attempts ?? this.attempts,
      lastError: lastError is String? ? lastError : this.lastError,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

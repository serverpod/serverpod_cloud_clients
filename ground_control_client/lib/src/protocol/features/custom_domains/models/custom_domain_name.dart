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
import '../../../features/custom_domains/models/dns_record_type.dart'
    as _iy8uljps;
import '../../../features/custom_domains/models/domain_name_status.dart'
    as _iuex1ymu;
import '../../../features/custom_domains/models/domain_name_target.dart'
    as _ijnwcgjj;

abstract class CustomDomainName
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CustomDomainName._({
    this.id,
    required this.name,
    required this.status,
    required this.target,
    DateTime? createdAt,
    required this.capsuleId,
    required this.dnsRecordVerificationValue,
    required this.dnsRecordType,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CustomDomainName({
    int? id,
    required String name,
    required _iuex1ymu.DomainNameStatus status,
    required _ijnwcgjj.DomainNameTarget target,
    DateTime? createdAt,
    required int capsuleId,
    required String dnsRecordVerificationValue,
    required _iy8uljps.DnsRecordType dnsRecordType,
  }) = _CustomDomainNameImpl;

  factory CustomDomainName.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomDomainName(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      status: _iuex1ymu.DomainNameStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      target: _ijnwcgjj.DomainNameTarget.fromJson(
        (jsonSerialization['target'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      capsuleId: jsonSerialization['capsuleId'] as int,
      dnsRecordVerificationValue:
          jsonSerialization['dnsRecordVerificationValue'] as String,
      dnsRecordType: _iy8uljps.DnsRecordType.fromJson(
        (jsonSerialization['dnsRecordType'] as String),
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  _iuex1ymu.DomainNameStatus status;

  _ijnwcgjj.DomainNameTarget target;

  DateTime? createdAt;

  int capsuleId;

  String dnsRecordVerificationValue;

  _iy8uljps.DnsRecordType dnsRecordType;

  /// Returns a shallow copy of this [CustomDomainName]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CustomDomainName copyWith({
    int? id,
    String? name,
    _iuex1ymu.DomainNameStatus? status,
    _ijnwcgjj.DomainNameTarget? target,
    DateTime? createdAt,
    int? capsuleId,
    String? dnsRecordVerificationValue,
    _iy8uljps.DnsRecordType? dnsRecordType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomDomainName',
      if (id != null) 'id': id,
      'name': name,
      'status': status.toJson(),
      'target': target.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'capsuleId': capsuleId,
      'dnsRecordVerificationValue': dnsRecordVerificationValue,
      'dnsRecordType': dnsRecordType.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomDomainName',
      if (id != null) 'id': id,
      'name': name,
      'status': status.toJson(),
      'target': target.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'capsuleId': capsuleId,
      'dnsRecordVerificationValue': dnsRecordVerificationValue,
      'dnsRecordType': dnsRecordType.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomDomainNameImpl extends CustomDomainName {
  _CustomDomainNameImpl({
    int? id,
    required String name,
    required _iuex1ymu.DomainNameStatus status,
    required _ijnwcgjj.DomainNameTarget target,
    DateTime? createdAt,
    required int capsuleId,
    required String dnsRecordVerificationValue,
    required _iy8uljps.DnsRecordType dnsRecordType,
  }) : super._(
         id: id,
         name: name,
         status: status,
         target: target,
         createdAt: createdAt,
         capsuleId: capsuleId,
         dnsRecordVerificationValue: dnsRecordVerificationValue,
         dnsRecordType: dnsRecordType,
       );

  /// Returns a shallow copy of this [CustomDomainName]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CustomDomainName copyWith({
    Object? id = _Undefined,
    String? name,
    _iuex1ymu.DomainNameStatus? status,
    _ijnwcgjj.DomainNameTarget? target,
    Object? createdAt = _Undefined,
    int? capsuleId,
    String? dnsRecordVerificationValue,
    _iy8uljps.DnsRecordType? dnsRecordType,
  }) {
    return CustomDomainName(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      target: target ?? this.target,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      capsuleId: capsuleId ?? this.capsuleId,
      dnsRecordVerificationValue:
          dnsRecordVerificationValue ?? this.dnsRecordVerificationValue,
      dnsRecordType: dnsRecordType ?? this.dnsRecordType,
    );
  }
}

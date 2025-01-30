/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../features/custom_domain_name/models/domain_name_status.dart'
    as _i2;
import '../../../features/custom_domain_name/models/domain_name_target.dart'
    as _i3;
import '../../../features/custom_domain_name/models/dns_record_type.dart'
    as _i4;

abstract class CustomDomainName implements _i1.SerializableModel {
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
    required _i2.DomainNameStatus status,
    required _i3.DomainNameTarget target,
    DateTime? createdAt,
    required int capsuleId,
    required String dnsRecordVerificationValue,
    required _i4.DnsRecordType dnsRecordType,
  }) = _CustomDomainNameImpl;

  factory CustomDomainName.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomDomainName(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      status: _i2.DomainNameStatus.fromJson(
          (jsonSerialization['status'] as String)),
      target: _i3.DomainNameTarget.fromJson(
          (jsonSerialization['target'] as String)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      capsuleId: jsonSerialization['capsuleId'] as int,
      dnsRecordVerificationValue:
          jsonSerialization['dnsRecordVerificationValue'] as String,
      dnsRecordType: _i4.DnsRecordType.fromJson(
          (jsonSerialization['dnsRecordType'] as String)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  _i2.DomainNameStatus status;

  _i3.DomainNameTarget target;

  DateTime? createdAt;

  int capsuleId;

  String dnsRecordVerificationValue;

  _i4.DnsRecordType dnsRecordType;

  CustomDomainName copyWith({
    int? id,
    String? name,
    _i2.DomainNameStatus? status,
    _i3.DomainNameTarget? target,
    DateTime? createdAt,
    int? capsuleId,
    String? dnsRecordVerificationValue,
    _i4.DnsRecordType? dnsRecordType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
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
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomDomainNameImpl extends CustomDomainName {
  _CustomDomainNameImpl({
    int? id,
    required String name,
    required _i2.DomainNameStatus status,
    required _i3.DomainNameTarget target,
    DateTime? createdAt,
    required int capsuleId,
    required String dnsRecordVerificationValue,
    required _i4.DnsRecordType dnsRecordType,
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

  @override
  CustomDomainName copyWith({
    Object? id = _Undefined,
    String? name,
    _i2.DomainNameStatus? status,
    _i3.DomainNameTarget? target,
    Object? createdAt = _Undefined,
    int? capsuleId,
    String? dnsRecordVerificationValue,
    _i4.DnsRecordType? dnsRecordType,
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

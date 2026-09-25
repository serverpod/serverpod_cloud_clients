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
import '../../../domains/custom_domains/models/dns_record_type.dart'
    as _iun9asme;
import '../../../domains/custom_domains/models/domain_name_status.dart'
    as _ivm7u5lm;
import '../../../domains/custom_domains/models/domain_name_target.dart'
    as _i425okov;

abstract class CustomDomainName
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CustomDomainName._({
    this.id,
    required this.name,
    required this.status,
    required this.target,
    DateTime? createdAt,
    required this.cloudCapsuleId,
    int? capsuleId,
    required this.dnsRecordVerificationValue,
    required this.dnsRecordType,
  }) : createdAt = createdAt ?? DateTime.now(),
       capsuleId = capsuleId ?? 0;

  factory CustomDomainName({
    int? id,
    required String name,
    required _ivm7u5lm.DomainNameStatus status,
    required _i425okov.DomainNameTarget target,
    DateTime? createdAt,
    required String cloudCapsuleId,
    int? capsuleId,
    required String dnsRecordVerificationValue,
    required _iun9asme.DnsRecordType dnsRecordType,
  }) = _CustomDomainNameImpl;

  factory CustomDomainName.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomDomainName(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      status: _ivm7u5lm.DomainNameStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      target: _i425okov.DomainNameTarget.fromJson(
        (jsonSerialization['target'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      cloudCapsuleId: jsonSerialization['cloudCapsuleId'] as String,
      capsuleId: jsonSerialization['capsuleId'] as int?,
      dnsRecordVerificationValue:
          jsonSerialization['dnsRecordVerificationValue'] as String,
      dnsRecordType: _iun9asme.DnsRecordType.fromJson(
        (jsonSerialization['dnsRecordType'] as String),
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  _ivm7u5lm.DomainNameStatus status;

  _i425okov.DomainNameTarget target;

  DateTime? createdAt;

  /// Globally unique identifier of the capsule this domain belongs to.
  /// Cannot be changed.
  String cloudCapsuleId;

  /// Deprecated. Older clients still decode this field.
  /// It is not stored, and it is always 0.
  int? capsuleId;

  String dnsRecordVerificationValue;

  _iun9asme.DnsRecordType dnsRecordType;

  /// Returns a shallow copy of this [CustomDomainName]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CustomDomainName copyWith({
    int? id,
    String? name,
    _ivm7u5lm.DomainNameStatus? status,
    _i425okov.DomainNameTarget? target,
    DateTime? createdAt,
    String? cloudCapsuleId,
    int? capsuleId,
    String? dnsRecordVerificationValue,
    _iun9asme.DnsRecordType? dnsRecordType,
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
      'cloudCapsuleId': cloudCapsuleId,
      if (capsuleId != null) 'capsuleId': capsuleId,
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
      'cloudCapsuleId': cloudCapsuleId,
      if (capsuleId != null) 'capsuleId': capsuleId,
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
    required _ivm7u5lm.DomainNameStatus status,
    required _i425okov.DomainNameTarget target,
    DateTime? createdAt,
    required String cloudCapsuleId,
    int? capsuleId,
    required String dnsRecordVerificationValue,
    required _iun9asme.DnsRecordType dnsRecordType,
  }) : super._(
         id: id,
         name: name,
         status: status,
         target: target,
         createdAt: createdAt,
         cloudCapsuleId: cloudCapsuleId,
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
    _ivm7u5lm.DomainNameStatus? status,
    _i425okov.DomainNameTarget? target,
    Object? createdAt = _Undefined,
    String? cloudCapsuleId,
    Object? capsuleId = _Undefined,
    String? dnsRecordVerificationValue,
    _iun9asme.DnsRecordType? dnsRecordType,
  }) {
    return CustomDomainName(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      target: target ?? this.target,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      cloudCapsuleId: cloudCapsuleId ?? this.cloudCapsuleId,
      capsuleId: capsuleId is int? ? capsuleId : this.capsuleId,
      dnsRecordVerificationValue:
          dnsRecordVerificationValue ?? this.dnsRecordVerificationValue,
      dnsRecordType: dnsRecordType ?? this.dnsRecordType,
    );
  }
}

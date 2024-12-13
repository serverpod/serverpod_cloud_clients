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

abstract class NewCustomDomainNamesEvent implements _i1.SerializableModel {
  NewCustomDomainNamesEvent._({
    required this.domainName,
    required this.attempts,
    required this.cloudEnvironmentId,
  });

  factory NewCustomDomainNamesEvent({
    required String domainName,
    required int attempts,
    required String cloudEnvironmentId,
  }) = _NewCustomDomainNamesEventImpl;

  factory NewCustomDomainNamesEvent.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return NewCustomDomainNamesEvent(
      domainName: jsonSerialization['domainName'] as String,
      attempts: jsonSerialization['attempts'] as int,
      cloudEnvironmentId: jsonSerialization['cloudEnvironmentId'] as String,
    );
  }

  String domainName;

  int attempts;

  String cloudEnvironmentId;

  NewCustomDomainNamesEvent copyWith({
    String? domainName,
    int? attempts,
    String? cloudEnvironmentId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'domainName': domainName,
      'attempts': attempts,
      'cloudEnvironmentId': cloudEnvironmentId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _NewCustomDomainNamesEventImpl extends NewCustomDomainNamesEvent {
  _NewCustomDomainNamesEventImpl({
    required String domainName,
    required int attempts,
    required String cloudEnvironmentId,
  }) : super._(
          domainName: domainName,
          attempts: attempts,
          cloudEnvironmentId: cloudEnvironmentId,
        );

  @override
  NewCustomDomainNamesEvent copyWith({
    String? domainName,
    int? attempts,
    String? cloudEnvironmentId,
  }) {
    return NewCustomDomainNamesEvent(
      domainName: domainName ?? this.domainName,
      attempts: attempts ?? this.attempts,
      cloudEnvironmentId: cloudEnvironmentId ?? this.cloudEnvironmentId,
    );
  }
}
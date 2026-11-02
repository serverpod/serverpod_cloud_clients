/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

part of 'store_credential_info.dart';

/// The identity of a Google Play service account.
abstract class GooglePlayCredentialInfo extends _i26f4ubs.StoreCredentialInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GooglePlayCredentialInfo._({required this.serviceAccountEmail});

  factory GooglePlayCredentialInfo({required String serviceAccountEmail}) =
      _GooglePlayCredentialInfoImpl;

  factory GooglePlayCredentialInfo.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GooglePlayCredentialInfo(
      serviceAccountEmail: jsonSerialization['serviceAccountEmail'] as String,
    );
  }

  /// The `client_email` of the service account's JSON key.
  String serviceAccountEmail;

  /// Returns a shallow copy of this [GooglePlayCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @override
  @_isc.useResult
  GooglePlayCredentialInfo copyWith({String? serviceAccountEmail});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GooglePlayCredentialInfo',
      'serviceAccountEmail': serviceAccountEmail,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GooglePlayCredentialInfo',
      'serviceAccountEmail': serviceAccountEmail,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _GooglePlayCredentialInfoImpl extends GooglePlayCredentialInfo {
  _GooglePlayCredentialInfoImpl({required String serviceAccountEmail})
    : super._(serviceAccountEmail: serviceAccountEmail);

  /// Returns a shallow copy of this [GooglePlayCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GooglePlayCredentialInfo copyWith({String? serviceAccountEmail}) {
    return GooglePlayCredentialInfo(
      serviceAccountEmail: serviceAccountEmail ?? this.serviceAccountEmail,
    );
  }
}

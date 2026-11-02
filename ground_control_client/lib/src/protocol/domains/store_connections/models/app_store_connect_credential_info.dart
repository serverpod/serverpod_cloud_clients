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

/// The ids of an App Store Connect API key.
abstract class AppStoreConnectCredentialInfo
    extends _i26f4ubs.StoreCredentialInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppStoreConnectCredentialInfo._({
    required this.issuerId,
    required this.keyId,
  });

  factory AppStoreConnectCredentialInfo({
    required String issuerId,
    required String keyId,
  }) = _AppStoreConnectCredentialInfoImpl;

  factory AppStoreConnectCredentialInfo.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppStoreConnectCredentialInfo(
      issuerId: jsonSerialization['issuerId'] as String,
      keyId: jsonSerialization['keyId'] as String,
    );
  }

  String issuerId;

  String keyId;

  /// Returns a shallow copy of this [AppStoreConnectCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @override
  @_isc.useResult
  AppStoreConnectCredentialInfo copyWith({String? issuerId, String? keyId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppStoreConnectCredentialInfo',
      'issuerId': issuerId,
      'keyId': keyId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppStoreConnectCredentialInfo',
      'issuerId': issuerId,
      'keyId': keyId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppStoreConnectCredentialInfoImpl extends AppStoreConnectCredentialInfo {
  _AppStoreConnectCredentialInfoImpl({
    required String issuerId,
    required String keyId,
  }) : super._(issuerId: issuerId, keyId: keyId);

  /// Returns a shallow copy of this [AppStoreConnectCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppStoreConnectCredentialInfo copyWith({String? issuerId, String? keyId}) {
    return AppStoreConnectCredentialInfo(
      issuerId: issuerId ?? this.issuerId,
      keyId: keyId ?? this.keyId,
    );
  }
}

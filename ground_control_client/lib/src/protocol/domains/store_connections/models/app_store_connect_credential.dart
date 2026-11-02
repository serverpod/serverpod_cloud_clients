/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

part of 'store_credential.dart';

/// An App Store Connect API key.
abstract class AppStoreConnectCredential extends _i26f4ubs.StoreCredential
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppStoreConnectCredential._({
    required this.issuerId,
    required this.keyId,
    required this.privateKey,
  });

  factory AppStoreConnectCredential({
    required String issuerId,
    required String keyId,
    required String privateKey,
  }) = _AppStoreConnectCredentialImpl;

  factory AppStoreConnectCredential.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppStoreConnectCredential(
      issuerId: jsonSerialization['issuerId'] as String,
      keyId: jsonSerialization['keyId'] as String,
      privateKey: jsonSerialization['privateKey'] as String,
    );
  }

  String issuerId;

  String keyId;

  /// The contents of the `.p8` file.
  String privateKey;

  /// Returns a shallow copy of this [AppStoreConnectCredential]
  /// with some or all fields replaced by the given arguments.
  @override
  @_isc.useResult
  AppStoreConnectCredential copyWith({
    String? issuerId,
    String? keyId,
    String? privateKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppStoreConnectCredential',
      'issuerId': issuerId,
      'keyId': keyId,
      'privateKey': privateKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppStoreConnectCredential',
      'issuerId': issuerId,
      'keyId': keyId,
      'privateKey': privateKey,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppStoreConnectCredentialImpl extends AppStoreConnectCredential {
  _AppStoreConnectCredentialImpl({
    required String issuerId,
    required String keyId,
    required String privateKey,
  }) : super._(issuerId: issuerId, keyId: keyId, privateKey: privateKey);

  /// Returns a shallow copy of this [AppStoreConnectCredential]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppStoreConnectCredential copyWith({
    String? issuerId,
    String? keyId,
    String? privateKey,
  }) {
    return AppStoreConnectCredential(
      issuerId: issuerId ?? this.issuerId,
      keyId: keyId ?? this.keyId,
      privateKey: privateKey ?? this.privateKey,
    );
  }
}

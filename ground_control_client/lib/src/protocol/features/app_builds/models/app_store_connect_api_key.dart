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

/// An App Store Connect team API key. Write-only: Ground Control never
/// returns it.
abstract class AppStoreConnectApiKey
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppStoreConnectApiKey._({
    required this.privateKey,
    required this.keyId,
    required this.issuerId,
  });

  factory AppStoreConnectApiKey({
    required String privateKey,
    required String keyId,
    required String issuerId,
  }) = _AppStoreConnectApiKeyImpl;

  factory AppStoreConnectApiKey.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppStoreConnectApiKey(
      privateKey: jsonSerialization['privateKey'] as String,
      keyId: jsonSerialization['keyId'] as String,
      issuerId: jsonSerialization['issuerId'] as String,
    );
  }

  /// The contents of the `.p8` file.
  String privateKey;

  /// Both shown with the key under Users and Access, Integrations, in
  /// App Store Connect.
  String keyId;

  String issuerId;

  /// Returns a shallow copy of this [AppStoreConnectApiKey]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppStoreConnectApiKey copyWith({
    String? privateKey,
    String? keyId,
    String? issuerId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppStoreConnectApiKey',
      'privateKey': privateKey,
      'keyId': keyId,
      'issuerId': issuerId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppStoreConnectApiKey',
      'privateKey': privateKey,
      'keyId': keyId,
      'issuerId': issuerId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppStoreConnectApiKeyImpl extends AppStoreConnectApiKey {
  _AppStoreConnectApiKeyImpl({
    required String privateKey,
    required String keyId,
    required String issuerId,
  }) : super._(privateKey: privateKey, keyId: keyId, issuerId: issuerId);

  /// Returns a shallow copy of this [AppStoreConnectApiKey]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppStoreConnectApiKey copyWith({
    String? privateKey,
    String? keyId,
    String? issuerId,
  }) {
    return AppStoreConnectApiKey(
      privateKey: privateKey ?? this.privateKey,
      keyId: keyId ?? this.keyId,
      issuerId: issuerId ?? this.issuerId,
    );
  }
}

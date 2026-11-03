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

/// The owner's App Store Connect key a capsule publishes iOS builds with.
abstract class AppStoreAccess
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppStoreAccess._({
    required this.appStoreConnectKeyId,
    required this.appStoreConnectKeyName,
  });

  factory AppStoreAccess({
    required _isc.UuidValue appStoreConnectKeyId,
    required String appStoreConnectKeyName,
  }) = _AppStoreAccessImpl;

  factory AppStoreAccess.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppStoreAccess(
      appStoreConnectKeyId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['appStoreConnectKeyId'],
      ),
      appStoreConnectKeyName:
          jsonSerialization['appStoreConnectKeyName'] as String,
    );
  }

  _isc.UuidValue appStoreConnectKeyId;

  /// The key's name, for members who cannot list the owner's keys.
  String appStoreConnectKeyName;

  /// Returns a shallow copy of this [AppStoreAccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppStoreAccess copyWith({
    _isc.UuidValue? appStoreConnectKeyId,
    String? appStoreConnectKeyName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppStoreAccess',
      'appStoreConnectKeyId': appStoreConnectKeyId.toJson(),
      'appStoreConnectKeyName': appStoreConnectKeyName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppStoreAccess',
      'appStoreConnectKeyId': appStoreConnectKeyId.toJson(),
      'appStoreConnectKeyName': appStoreConnectKeyName,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppStoreAccessImpl extends AppStoreAccess {
  _AppStoreAccessImpl({
    required _isc.UuidValue appStoreConnectKeyId,
    required String appStoreConnectKeyName,
  }) : super._(
         appStoreConnectKeyId: appStoreConnectKeyId,
         appStoreConnectKeyName: appStoreConnectKeyName,
       );

  /// Returns a shallow copy of this [AppStoreAccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppStoreAccess copyWith({
    _isc.UuidValue? appStoreConnectKeyId,
    String? appStoreConnectKeyName,
  }) {
    return AppStoreAccess(
      appStoreConnectKeyId: appStoreConnectKeyId ?? this.appStoreConnectKeyId,
      appStoreConnectKeyName:
          appStoreConnectKeyName ?? this.appStoreConnectKeyName,
    );
  }
}

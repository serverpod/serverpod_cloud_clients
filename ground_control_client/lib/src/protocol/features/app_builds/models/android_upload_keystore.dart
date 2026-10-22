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

/// The upload keystore an Android app bundle is signed with. Write-only:
/// Ground Control never returns it.
abstract class AndroidUploadKeystore
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AndroidUploadKeystore._({
    required this.keystoreBase64,
    required this.keystorePassword,
    required this.keyAlias,
    required this.keyPassword,
  });

  factory AndroidUploadKeystore({
    required String keystoreBase64,
    required String keystorePassword,
    required String keyAlias,
    required String keyPassword,
  }) = _AndroidUploadKeystoreImpl;

  factory AndroidUploadKeystore.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AndroidUploadKeystore(
      keystoreBase64: jsonSerialization['keystoreBase64'] as String,
      keystorePassword: jsonSerialization['keystorePassword'] as String,
      keyAlias: jsonSerialization['keyAlias'] as String,
      keyPassword: jsonSerialization['keyPassword'] as String,
    );
  }

  /// The keystore file, base64 encoded.
  String keystoreBase64;

  String keystorePassword;

  /// The upload key inside the keystore and its own password.
  String keyAlias;

  String keyPassword;

  /// Returns a shallow copy of this [AndroidUploadKeystore]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AndroidUploadKeystore copyWith({
    String? keystoreBase64,
    String? keystorePassword,
    String? keyAlias,
    String? keyPassword,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AndroidUploadKeystore',
      'keystoreBase64': keystoreBase64,
      'keystorePassword': keystorePassword,
      'keyAlias': keyAlias,
      'keyPassword': keyPassword,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AndroidUploadKeystore',
      'keystoreBase64': keystoreBase64,
      'keystorePassword': keystorePassword,
      'keyAlias': keyAlias,
      'keyPassword': keyPassword,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AndroidUploadKeystoreImpl extends AndroidUploadKeystore {
  _AndroidUploadKeystoreImpl({
    required String keystoreBase64,
    required String keystorePassword,
    required String keyAlias,
    required String keyPassword,
  }) : super._(
         keystoreBase64: keystoreBase64,
         keystorePassword: keystorePassword,
         keyAlias: keyAlias,
         keyPassword: keyPassword,
       );

  /// Returns a shallow copy of this [AndroidUploadKeystore]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AndroidUploadKeystore copyWith({
    String? keystoreBase64,
    String? keystorePassword,
    String? keyAlias,
    String? keyPassword,
  }) {
    return AndroidUploadKeystore(
      keystoreBase64: keystoreBase64 ?? this.keystoreBase64,
      keystorePassword: keystorePassword ?? this.keystorePassword,
      keyAlias: keyAlias ?? this.keyAlias,
      keyPassword: keyPassword ?? this.keyPassword,
    );
  }
}

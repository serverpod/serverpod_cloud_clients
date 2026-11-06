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
import 'dart:typed_data' as _idt;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A freshly generated Android upload keystore. Returned once, by the
/// call that generated it; the password is never returned again.
abstract class GeneratedAndroidKeystore
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GeneratedAndroidKeystore._({
    required this.keystore,
    required this.password,
    required this.keyAlias,
  });

  factory GeneratedAndroidKeystore({
    required _idt.ByteData keystore,
    required String password,
    required String keyAlias,
  }) = _GeneratedAndroidKeystoreImpl;

  factory GeneratedAndroidKeystore.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GeneratedAndroidKeystore(
      keystore: _isc.ByteDataJsonExtension.fromJson(
        jsonSerialization['keystore'],
      ),
      password: jsonSerialization['password'] as String,
      keyAlias: jsonSerialization['keyAlias'] as String,
    );
  }

  /// The PKCS12 keystore file.
  _idt.ByteData keystore;

  /// Opens the keystore and the key.
  String password;

  String keyAlias;

  /// Returns a shallow copy of this [GeneratedAndroidKeystore]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GeneratedAndroidKeystore copyWith({
    _idt.ByteData? keystore,
    String? password,
    String? keyAlias,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeneratedAndroidKeystore',
      'keystore': keystore.toJson(),
      'password': password,
      'keyAlias': keyAlias,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeneratedAndroidKeystore',
      'keystore': keystore.toJson(),
      'password': password,
      'keyAlias': keyAlias,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _GeneratedAndroidKeystoreImpl extends GeneratedAndroidKeystore {
  _GeneratedAndroidKeystoreImpl({
    required _idt.ByteData keystore,
    required String password,
    required String keyAlias,
  }) : super._(keystore: keystore, password: password, keyAlias: keyAlias);

  /// Returns a shallow copy of this [GeneratedAndroidKeystore]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GeneratedAndroidKeystore copyWith({
    _idt.ByteData? keystore,
    String? password,
    String? keyAlias,
  }) {
    return GeneratedAndroidKeystore(
      keystore: keystore ?? this.keystore.clone(),
      password: password ?? this.password,
      keyAlias: keyAlias ?? this.keyAlias,
    );
  }
}

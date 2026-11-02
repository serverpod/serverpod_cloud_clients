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

/// A Google Play service account key.
abstract class GooglePlayCredential extends _i26f4ubs.StoreCredential
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GooglePlayCredential._({required this.serviceAccountJson});

  factory GooglePlayCredential({required String serviceAccountJson}) =
      _GooglePlayCredentialImpl;

  factory GooglePlayCredential.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GooglePlayCredential(
      serviceAccountJson: jsonSerialization['serviceAccountJson'] as String,
    );
  }

  /// The service account's JSON key file contents.
  String serviceAccountJson;

  /// Returns a shallow copy of this [GooglePlayCredential]
  /// with some or all fields replaced by the given arguments.
  @override
  @_isc.useResult
  GooglePlayCredential copyWith({String? serviceAccountJson});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GooglePlayCredential',
      'serviceAccountJson': serviceAccountJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GooglePlayCredential',
      'serviceAccountJson': serviceAccountJson,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _GooglePlayCredentialImpl extends GooglePlayCredential {
  _GooglePlayCredentialImpl({required String serviceAccountJson})
    : super._(serviceAccountJson: serviceAccountJson);

  /// Returns a shallow copy of this [GooglePlayCredential]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GooglePlayCredential copyWith({String? serviceAccountJson}) {
    return GooglePlayCredential(
      serviceAccountJson: serviceAccountJson ?? this.serviceAccountJson,
    );
  }
}

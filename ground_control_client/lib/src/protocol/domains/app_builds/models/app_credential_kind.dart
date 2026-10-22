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

/// A credential a customer gives Ground Control to publish an app.
/// - `appStoreConnectApiKey` — iOS. An App Store Connect team API key.
/// - `playServiceAccountKey` — Android. A Google Cloud service account key
///   with release access to the app in Play Console.
/// - `androidUploadKeystore` — Android. The upload keystore the app bundle
///   is signed with.
enum AppCredentialKind implements _isc.SerializableModel {
  appStoreConnectApiKey,
  playServiceAccountKey,
  androidUploadKeystore;

  static AppCredentialKind fromJson(String name) {
    switch (name) {
      case 'appStoreConnectApiKey':
        return AppCredentialKind.appStoreConnectApiKey;
      case 'playServiceAccountKey':
        return AppCredentialKind.playServiceAccountKey;
      case 'androidUploadKeystore':
        return AppCredentialKind.androidUploadKeystore;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AppCredentialKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

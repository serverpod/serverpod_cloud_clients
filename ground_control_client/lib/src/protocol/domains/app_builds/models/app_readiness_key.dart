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

/// Identifies one item of a platform's readiness checklist.
///
/// Ground Control computes the checklist; consumers render it. The key
/// lets them attach platform-specific help to an item.
/// - `appIdentifierReported` — the CLI has reported the bundle ID or
///   package name.
/// - `credentialsValid` — the store credential is set.
/// - `agreementsAccepted` — iOS. No App Store Connect agreement is pending.
/// - `bundleIdRegistered` — iOS. The bundle ID is registered with Apple.
/// - `keystoreSet` — Android. The upload keystore is set.
/// - `storeAppFound` — the app record exists in App Store Connect or
///   Play Console.
/// - `encryptionDeclared` — iOS. The customer has answered the export
///   compliance question.
enum AppReadinessKey implements _isc.SerializableModel {
  appIdentifierReported,
  credentialsValid,
  agreementsAccepted,
  bundleIdRegistered,
  keystoreSet,
  storeAppFound,
  encryptionDeclared;

  static AppReadinessKey fromJson(String name) {
    switch (name) {
      case 'appIdentifierReported':
        return AppReadinessKey.appIdentifierReported;
      case 'credentialsValid':
        return AppReadinessKey.credentialsValid;
      case 'agreementsAccepted':
        return AppReadinessKey.agreementsAccepted;
      case 'bundleIdRegistered':
        return AppReadinessKey.bundleIdRegistered;
      case 'keystoreSet':
        return AppReadinessKey.keystoreSet;
      case 'storeAppFound':
        return AppReadinessKey.storeAppFound;
      case 'encryptionDeclared':
        return AppReadinessKey.encryptionDeclared;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AppReadinessKey"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

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

/// Why an app build failed or was not uploaded.
/// - `dependenciesNotResolved` — the app's packages could not be fetched.
/// - `compileFailed` — the app did not compile.
/// - `signingFailed` — the app could not be signed.
/// - `signingCertificateLimitReached` — the Apple team has as many
///   distribution certificates as Apple allows, so none could be created.
///   Revoking an unused one in the Apple developer portal frees a place.
/// - `storeAppNotFound` — the store has no app with the app's identifier.
/// - `versionAlreadyUploaded` — the store already has this version or
///   build number.
/// - `storePermissionDenied` — the store account may not upload the app.
/// - `storeKeyRejected` — the store rejected the key used to sign in to it.
/// - `debugSigned` — the store refused an app signed in debug mode.
/// - `wrongSigningKey` — the store refused an app signed with a key other
///   than the one it expects.
/// - `timedOut` — the build ran longer than the build service allows.
/// - `droppedByBuildService` — the build service lost the build.
/// - `unknown` — none of the above could be determined. It is also the
///   fallback a client receives for a reason it predates.
enum AppBuildFailureReason implements _isc.SerializableModel {
  dependenciesNotResolved,
  compileFailed,
  signingFailed,
  signingCertificateLimitReached,
  storeAppNotFound,
  versionAlreadyUploaded,
  storePermissionDenied,
  storeKeyRejected,
  debugSigned,
  wrongSigningKey,
  timedOut,
  droppedByBuildService,
  unknown;

  static AppBuildFailureReason fromJson(String name) {
    switch (name) {
      case 'dependenciesNotResolved':
        return AppBuildFailureReason.dependenciesNotResolved;
      case 'compileFailed':
        return AppBuildFailureReason.compileFailed;
      case 'signingFailed':
        return AppBuildFailureReason.signingFailed;
      case 'signingCertificateLimitReached':
        return AppBuildFailureReason.signingCertificateLimitReached;
      case 'storeAppNotFound':
        return AppBuildFailureReason.storeAppNotFound;
      case 'versionAlreadyUploaded':
        return AppBuildFailureReason.versionAlreadyUploaded;
      case 'storePermissionDenied':
        return AppBuildFailureReason.storePermissionDenied;
      case 'storeKeyRejected':
        return AppBuildFailureReason.storeKeyRejected;
      case 'debugSigned':
        return AppBuildFailureReason.debugSigned;
      case 'wrongSigningKey':
        return AppBuildFailureReason.wrongSigningKey;
      case 'timedOut':
        return AppBuildFailureReason.timedOut;
      case 'droppedByBuildService':
        return AppBuildFailureReason.droppedByBuildService;
      case 'unknown':
        return AppBuildFailureReason.unknown;
      default:
        return AppBuildFailureReason.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

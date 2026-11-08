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

/// The kind of file an app build artifact is, told by its file name.
/// - `dsym` — the iOS debug symbols archive.
/// - `mapping` — the Android obfuscation mapping file.
/// - `other` — a file this server does not recognize.
enum AppBuildArtifactKind implements _isc.SerializableModel {
  aab,
  apk,
  ipa,
  dsym,
  mapping,
  other;

  static AppBuildArtifactKind fromJson(String name) {
    switch (name) {
      case 'aab':
        return AppBuildArtifactKind.aab;
      case 'apk':
        return AppBuildArtifactKind.apk;
      case 'ipa':
        return AppBuildArtifactKind.ipa;
      case 'dsym':
        return AppBuildArtifactKind.dsym;
      case 'mapping':
        return AppBuildArtifactKind.mapping;
      case 'other':
        return AppBuildArtifactKind.other;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AppBuildArtifactKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../features/platform/models/dart_sdk_version.dart' as _ip471g3j;

/// The Dart SDK version policy for projects deployed to Serverpod Cloud.
abstract class DartSdkVersionPolicy
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DartSdkVersionPolicy._({
    required this.supportedVersions,
    required this.defaultVersion,
    required this.minVersionInclusive,
    required this.maxVersionExclusive,
    required this.documentationUrl,
  });

  factory DartSdkVersionPolicy({
    required List<_ip471g3j.DartSdkVersion> supportedVersions,
    required String defaultVersion,
    required String minVersionInclusive,
    required String maxVersionExclusive,
    required Uri documentationUrl,
  }) = _DartSdkVersionPolicyImpl;

  factory DartSdkVersionPolicy.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DartSdkVersionPolicy(
      supportedVersions: _iod2a87h.Protocol()
          .deserialize<List<_ip471g3j.DartSdkVersion>>(
            jsonSerialization['supportedVersions'],
          ),
      defaultVersion: jsonSerialization['defaultVersion'] as String,
      minVersionInclusive: jsonSerialization['minVersionInclusive'] as String,
      maxVersionExclusive: jsonSerialization['maxVersionExclusive'] as String,
      documentationUrl: _isc.UriJsonExtension.fromJson(
        jsonSerialization['documentationUrl'],
      ),
    );
  }

  /// The supported Dart SDK versions, ordered lowest to highest.
  List<_ip471g3j.DartSdkVersion> supportedVersions;

  /// The version used when a deployment requests no specific Dart SDK version.
  /// Always one of the versions in [supportedVersions], as a minor version
  /// tag, such as "3.8".
  String defaultVersion;

  /// The inclusive lower bound of the supported Dart SDK version range,
  /// as a full semver version, such as "3.8.0".
  String minVersionInclusive;

  /// The exclusive upper bound of the supported Dart SDK version range,
  /// as a full semver version, such as "3.12.0".
  String maxVersionExclusive;

  /// URL of the documentation page describing the Dart SDK version support.
  Uri documentationUrl;

  /// Returns a shallow copy of this [DartSdkVersionPolicy]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DartSdkVersionPolicy copyWith({
    List<_ip471g3j.DartSdkVersion>? supportedVersions,
    String? defaultVersion,
    String? minVersionInclusive,
    String? maxVersionExclusive,
    Uri? documentationUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DartSdkVersionPolicy',
      'supportedVersions': supportedVersions.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'defaultVersion': defaultVersion,
      'minVersionInclusive': minVersionInclusive,
      'maxVersionExclusive': maxVersionExclusive,
      'documentationUrl': documentationUrl.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DartSdkVersionPolicy',
      'supportedVersions': supportedVersions.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'defaultVersion': defaultVersion,
      'minVersionInclusive': minVersionInclusive,
      'maxVersionExclusive': maxVersionExclusive,
      'documentationUrl': documentationUrl.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DartSdkVersionPolicyImpl extends DartSdkVersionPolicy {
  _DartSdkVersionPolicyImpl({
    required List<_ip471g3j.DartSdkVersion> supportedVersions,
    required String defaultVersion,
    required String minVersionInclusive,
    required String maxVersionExclusive,
    required Uri documentationUrl,
  }) : super._(
         supportedVersions: supportedVersions,
         defaultVersion: defaultVersion,
         minVersionInclusive: minVersionInclusive,
         maxVersionExclusive: maxVersionExclusive,
         documentationUrl: documentationUrl,
       );

  /// Returns a shallow copy of this [DartSdkVersionPolicy]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DartSdkVersionPolicy copyWith({
    List<_ip471g3j.DartSdkVersion>? supportedVersions,
    String? defaultVersion,
    String? minVersionInclusive,
    String? maxVersionExclusive,
    Uri? documentationUrl,
  }) {
    return DartSdkVersionPolicy(
      supportedVersions:
          supportedVersions ??
          this.supportedVersions.map((e0) => e0.copyWith()).toList(),
      defaultVersion: defaultVersion ?? this.defaultVersion,
      minVersionInclusive: minVersionInclusive ?? this.minVersionInclusive,
      maxVersionExclusive: maxVersionExclusive ?? this.maxVersionExclusive,
      documentationUrl: documentationUrl ?? this.documentationUrl,
    );
  }
}

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
import '../../../domains/app_builds/models/app_platform.dart' as _ibmlgwb0;
import '../../../domains/app_builds/models/app_readiness_item.dart'
    as _i562dlbx;
import '../../../features/app_builds/models/app_build_summary.dart'
    as _ilsfxlsi;
import '../../../features/app_builds/models/app_credential_info.dart'
    as _i79z3vx8;

/// The publishing setup of one platform. Never contains credential values.
abstract class AppPlatformInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppPlatformInfo._({
    required this.platform,
    required this.enabled,
    this.appIdentifier,
    required this.credentials,
    required this.ready,
    required this.readiness,
    this.latestBuild,
  });

  factory AppPlatformInfo({
    required _ibmlgwb0.AppPlatform platform,
    required bool enabled,
    String? appIdentifier,
    required List<_i79z3vx8.AppCredentialInfo> credentials,
    required bool ready,
    required List<_i562dlbx.AppReadinessItem> readiness,
    _ilsfxlsi.AppBuildSummary? latestBuild,
  }) = _AppPlatformInfoImpl;

  factory AppPlatformInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppPlatformInfo(
      platform: _ibmlgwb0.AppPlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
      enabled: _isc.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      appIdentifier: jsonSerialization['appIdentifier'] as String?,
      credentials: _iod2a87h.Protocol()
          .deserialize<List<_i79z3vx8.AppCredentialInfo>>(
            jsonSerialization['credentials'],
          ),
      ready: _isc.BoolJsonExtension.fromJson(jsonSerialization['ready']),
      readiness: _iod2a87h.Protocol()
          .deserialize<List<_i562dlbx.AppReadinessItem>>(
            jsonSerialization['readiness'],
          ),
      latestBuild: jsonSerialization['latestBuild'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ilsfxlsi.AppBuildSummary>(
              jsonSerialization['latestBuild'],
            ),
    );
  }

  _ibmlgwb0.AppPlatform platform;

  /// Whether builds run for this platform. Turning it off keeps the
  /// credentials.
  bool enabled;

  /// The bundle ID or package name the CLI reported. Null until the CLI
  /// setup step has run.
  String? appIdentifier;

  /// The credentials that are set, with when each was last changed.
  List<_i79z3vx8.AppCredentialInfo> credentials;

  /// True when every readiness item is done and a build can start.
  bool ready;

  /// The checklist a build needs, in the order the customer completes it.
  List<_i562dlbx.AppReadinessItem> readiness;

  /// The most recent build for this platform, if any.
  _ilsfxlsi.AppBuildSummary? latestBuild;

  /// Returns a shallow copy of this [AppPlatformInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppPlatformInfo copyWith({
    _ibmlgwb0.AppPlatform? platform,
    bool? enabled,
    String? appIdentifier,
    List<_i79z3vx8.AppCredentialInfo>? credentials,
    bool? ready,
    List<_i562dlbx.AppReadinessItem>? readiness,
    _ilsfxlsi.AppBuildSummary? latestBuild,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppPlatformInfo',
      'platform': platform.toJson(),
      'enabled': enabled,
      if (appIdentifier != null) 'appIdentifier': appIdentifier,
      'credentials': credentials.toJson(valueToJson: (v) => v.toJson()),
      'ready': ready,
      'readiness': readiness.toJson(valueToJson: (v) => v.toJson()),
      if (latestBuild != null) 'latestBuild': latestBuild?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppPlatformInfo',
      'platform': platform.toJson(),
      'enabled': enabled,
      if (appIdentifier != null) 'appIdentifier': appIdentifier,
      'credentials': credentials.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'ready': ready,
      'readiness': readiness.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (latestBuild != null) 'latestBuild': latestBuild?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppPlatformInfoImpl extends AppPlatformInfo {
  _AppPlatformInfoImpl({
    required _ibmlgwb0.AppPlatform platform,
    required bool enabled,
    String? appIdentifier,
    required List<_i79z3vx8.AppCredentialInfo> credentials,
    required bool ready,
    required List<_i562dlbx.AppReadinessItem> readiness,
    _ilsfxlsi.AppBuildSummary? latestBuild,
  }) : super._(
         platform: platform,
         enabled: enabled,
         appIdentifier: appIdentifier,
         credentials: credentials,
         ready: ready,
         readiness: readiness,
         latestBuild: latestBuild,
       );

  /// Returns a shallow copy of this [AppPlatformInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppPlatformInfo copyWith({
    _ibmlgwb0.AppPlatform? platform,
    bool? enabled,
    Object? appIdentifier = _Undefined,
    List<_i79z3vx8.AppCredentialInfo>? credentials,
    bool? ready,
    List<_i562dlbx.AppReadinessItem>? readiness,
    Object? latestBuild = _Undefined,
  }) {
    return AppPlatformInfo(
      platform: platform ?? this.platform,
      enabled: enabled ?? this.enabled,
      appIdentifier: appIdentifier is String?
          ? appIdentifier
          : this.appIdentifier,
      credentials:
          credentials ?? this.credentials.map((e0) => e0.copyWith()).toList(),
      ready: ready ?? this.ready,
      readiness:
          readiness ?? this.readiness.map((e0) => e0.copyWith()).toList(),
      latestBuild: latestBuild is _ilsfxlsi.AppBuildSummary?
          ? latestBuild
          : this.latestBuild?.copyWith(),
    );
  }
}

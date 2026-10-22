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
import '../../../domains/app_builds/models/app_platform.dart' as _ibmlgwb0;

/// A platform's app identifier as the CLI read it from the project.
abstract class ReportedAppIdentifier
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ReportedAppIdentifier._({
    required this.platform,
    required this.appIdentifier,
  });

  factory ReportedAppIdentifier({
    required _ibmlgwb0.AppPlatform platform,
    required String appIdentifier,
  }) = _ReportedAppIdentifierImpl;

  factory ReportedAppIdentifier.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ReportedAppIdentifier(
      platform: _ibmlgwb0.AppPlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
      appIdentifier: jsonSerialization['appIdentifier'] as String,
    );
  }

  _ibmlgwb0.AppPlatform platform;

  /// The iOS bundle ID or the Android package name.
  String appIdentifier;

  /// Returns a shallow copy of this [ReportedAppIdentifier]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReportedAppIdentifier copyWith({
    _ibmlgwb0.AppPlatform? platform,
    String? appIdentifier,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReportedAppIdentifier',
      'platform': platform.toJson(),
      'appIdentifier': appIdentifier,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReportedAppIdentifier',
      'platform': platform.toJson(),
      'appIdentifier': appIdentifier,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ReportedAppIdentifierImpl extends ReportedAppIdentifier {
  _ReportedAppIdentifierImpl({
    required _ibmlgwb0.AppPlatform platform,
    required String appIdentifier,
  }) : super._(platform: platform, appIdentifier: appIdentifier);

  /// Returns a shallow copy of this [ReportedAppIdentifier]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ReportedAppIdentifier copyWith({
    _ibmlgwb0.AppPlatform? platform,
    String? appIdentifier,
  }) {
    return ReportedAppIdentifier(
      platform: platform ?? this.platform,
      appIdentifier: appIdentifier ?? this.appIdentifier,
    );
  }
}

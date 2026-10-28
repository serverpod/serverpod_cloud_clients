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

/// One of the builds requested for an upload.
abstract class AppBuildRef
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildRef._({required this.buildId, required this.platform});

  factory AppBuildRef({
    required _isc.UuidValue buildId,
    required _ibmlgwb0.AppPlatform platform,
  }) = _AppBuildRefImpl;

  factory AppBuildRef.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildRef(
      buildId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['buildId'],
      ),
      platform: _ibmlgwb0.AppPlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
    );
  }

  _isc.UuidValue buildId;

  _ibmlgwb0.AppPlatform platform;

  /// Returns a shallow copy of this [AppBuildRef]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildRef copyWith({
    _isc.UuidValue? buildId,
    _ibmlgwb0.AppPlatform? platform,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildRef',
      'buildId': buildId.toJson(),
      'platform': platform.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildRef',
      'buildId': buildId.toJson(),
      'platform': platform.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppBuildRefImpl extends AppBuildRef {
  _AppBuildRefImpl({
    required _isc.UuidValue buildId,
    required _ibmlgwb0.AppPlatform platform,
  }) : super._(buildId: buildId, platform: platform);

  /// Returns a shallow copy of this [AppBuildRef]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildRef copyWith({
    _isc.UuidValue? buildId,
    _ibmlgwb0.AppPlatform? platform,
  }) {
    return AppBuildRef(
      buildId: buildId ?? this.buildId,
      platform: platform ?? this.platform,
    );
  }
}

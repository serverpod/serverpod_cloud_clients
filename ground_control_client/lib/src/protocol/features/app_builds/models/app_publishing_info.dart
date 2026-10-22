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
import '../../../features/app_builds/models/app_platform_info.dart'
    as _i112xfuz;

/// A capsule's app publishing setup. Never contains credential values.
abstract class AppPublishingInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppPublishingInfo._({required this.platforms});

  factory AppPublishingInfo({
    required List<_i112xfuz.AppPlatformInfo> platforms,
  }) = _AppPublishingInfoImpl;

  factory AppPublishingInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppPublishingInfo(
      platforms: _iod2a87h.Protocol()
          .deserialize<List<_i112xfuz.AppPlatformInfo>>(
            jsonSerialization['platforms'],
          ),
    );
  }

  /// One entry per platform, in the order of [AppPlatform]. A platform
  /// the capsule has never set up is turned off with an empty setup.
  List<_i112xfuz.AppPlatformInfo> platforms;

  /// Returns a shallow copy of this [AppPublishingInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppPublishingInfo copyWith({List<_i112xfuz.AppPlatformInfo>? platforms});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppPublishingInfo',
      'platforms': platforms.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppPublishingInfo',
      'platforms': platforms.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppPublishingInfoImpl extends AppPublishingInfo {
  _AppPublishingInfoImpl({required List<_i112xfuz.AppPlatformInfo> platforms})
    : super._(platforms: platforms);

  /// Returns a shallow copy of this [AppPublishingInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppPublishingInfo copyWith({List<_i112xfuz.AppPlatformInfo>? platforms}) {
    return AppPublishingInfo(
      platforms:
          platforms ?? this.platforms.map((e0) => e0.copyWith()).toList(),
    );
  }
}

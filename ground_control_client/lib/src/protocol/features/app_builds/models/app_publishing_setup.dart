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
import '../../../features/app_builds/models/android_publishing_setup.dart'
    as _izwch55m;
import '../../../features/app_builds/models/ios_publishing_setup.dart'
    as _ibkizukl;

/// The publishing setup of a capsule, one section per platform. Never
/// contains credential values.
abstract class AppPublishingSetup
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppPublishingSetup._({required this.ios, required this.android});

  factory AppPublishingSetup({
    required _ibkizukl.IosPublishingSetup ios,
    required _izwch55m.AndroidPublishingSetup android,
  }) = _AppPublishingSetupImpl;

  factory AppPublishingSetup.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppPublishingSetup(
      ios: _iod2a87h.Protocol().deserialize<_ibkizukl.IosPublishingSetup>(
        jsonSerialization['ios'],
      ),
      android: _iod2a87h.Protocol()
          .deserialize<_izwch55m.AndroidPublishingSetup>(
            jsonSerialization['android'],
          ),
    );
  }

  _ibkizukl.IosPublishingSetup ios;

  _izwch55m.AndroidPublishingSetup android;

  /// Returns a shallow copy of this [AppPublishingSetup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppPublishingSetup copyWith({
    _ibkizukl.IosPublishingSetup? ios,
    _izwch55m.AndroidPublishingSetup? android,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppPublishingSetup',
      'ios': ios.toJson(),
      'android': android.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppPublishingSetup',
      'ios': ios.toJsonForProtocol(),
      'android': android.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppPublishingSetupImpl extends AppPublishingSetup {
  _AppPublishingSetupImpl({
    required _ibkizukl.IosPublishingSetup ios,
    required _izwch55m.AndroidPublishingSetup android,
  }) : super._(ios: ios, android: android);

  /// Returns a shallow copy of this [AppPublishingSetup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppPublishingSetup copyWith({
    _ibkizukl.IosPublishingSetup? ios,
    _izwch55m.AndroidPublishingSetup? android,
  }) {
    return AppPublishingSetup(
      ios: ios ?? this.ios.copyWith(),
      android: android ?? this.android.copyWith(),
    );
  }
}

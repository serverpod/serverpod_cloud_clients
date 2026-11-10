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

/// An app identifier of a platform, the iOS bundle ID or Android package
/// name, that an upload replaced because the app declares a different one.
abstract class AppIdentifierChange
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppIdentifierChange._({
    required this.platform,
    required this.previous,
    required this.current,
  });

  factory AppIdentifierChange({
    required _ibmlgwb0.AppPlatform platform,
    required String previous,
    required String current,
  }) = _AppIdentifierChangeImpl;

  factory AppIdentifierChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppIdentifierChange(
      platform: _ibmlgwb0.AppPlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
      previous: jsonSerialization['previous'] as String,
      current: jsonSerialization['current'] as String,
    );
  }

  _ibmlgwb0.AppPlatform platform;

  /// The identifier recorded before the upload.
  String previous;

  /// The identifier the app declares, recorded from the upload on.
  String current;

  /// Returns a shallow copy of this [AppIdentifierChange]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppIdentifierChange copyWith({
    _ibmlgwb0.AppPlatform? platform,
    String? previous,
    String? current,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppIdentifierChange',
      'platform': platform.toJson(),
      'previous': previous,
      'current': current,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppIdentifierChange',
      'platform': platform.toJson(),
      'previous': previous,
      'current': current,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppIdentifierChangeImpl extends AppIdentifierChange {
  _AppIdentifierChangeImpl({
    required _ibmlgwb0.AppPlatform platform,
    required String previous,
    required String current,
  }) : super._(platform: platform, previous: previous, current: current);

  /// Returns a shallow copy of this [AppIdentifierChange]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppIdentifierChange copyWith({
    _ibmlgwb0.AppPlatform? platform,
    String? previous,
    String? current,
  }) {
    return AppIdentifierChange(
      platform: platform ?? this.platform,
      previous: previous ?? this.previous,
      current: current ?? this.current,
    );
  }
}

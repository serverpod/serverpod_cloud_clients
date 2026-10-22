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

/// Thrown when a build is requested for a platform that is turned off or
/// whose readiness checklist is not complete.
abstract class AppPlatformNotReadyException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  AppPlatformNotReadyException._({
    required this.message,
    required this.platform,
    required this.readiness,
  });

  factory AppPlatformNotReadyException({
    required String message,
    required _ibmlgwb0.AppPlatform platform,
    required List<_i562dlbx.AppReadinessItem> readiness,
  }) = _AppPlatformNotReadyExceptionImpl;

  factory AppPlatformNotReadyException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppPlatformNotReadyException(
      message: jsonSerialization['message'] as String,
      platform: _ibmlgwb0.AppPlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
      readiness: _iod2a87h.Protocol()
          .deserialize<List<_i562dlbx.AppReadinessItem>>(
            jsonSerialization['readiness'],
          ),
    );
  }

  String message;

  _ibmlgwb0.AppPlatform platform;

  /// The platform's full checklist, done items included.
  List<_i562dlbx.AppReadinessItem> readiness;

  /// Returns a shallow copy of this [AppPlatformNotReadyException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppPlatformNotReadyException copyWith({
    String? message,
    _ibmlgwb0.AppPlatform? platform,
    List<_i562dlbx.AppReadinessItem>? readiness,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppPlatformNotReadyException',
      'message': message,
      'platform': platform.toJson(),
      'readiness': readiness.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppPlatformNotReadyException',
      'message': message,
      'platform': platform.toJson(),
      'readiness': readiness.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return 'AppPlatformNotReadyException(message: $message, platform: $platform, readiness: $readiness)';
  }
}

class _AppPlatformNotReadyExceptionImpl extends AppPlatformNotReadyException {
  _AppPlatformNotReadyExceptionImpl({
    required String message,
    required _ibmlgwb0.AppPlatform platform,
    required List<_i562dlbx.AppReadinessItem> readiness,
  }) : super._(message: message, platform: platform, readiness: readiness);

  /// Returns a shallow copy of this [AppPlatformNotReadyException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppPlatformNotReadyException copyWith({
    String? message,
    _ibmlgwb0.AppPlatform? platform,
    List<_i562dlbx.AppReadinessItem>? readiness,
  }) {
    return AppPlatformNotReadyException(
      message: message ?? this.message,
      platform: platform ?? this.platform,
      readiness:
          readiness ?? this.readiness.map((e0) => e0.copyWith()).toList(),
    );
  }
}

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

/// Thrown by createBuilds when the publishing setup of a requested platform
/// is incomplete. No build is created. The message says what is missing per
/// platform.
abstract class AppPlatformNotSetUpException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  AppPlatformNotSetUpException._({required this.message});

  factory AppPlatformNotSetUpException({required String message}) =
      _AppPlatformNotSetUpExceptionImpl;

  factory AppPlatformNotSetUpException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppPlatformNotSetUpException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [AppPlatformNotSetUpException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppPlatformNotSetUpException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppPlatformNotSetUpException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppPlatformNotSetUpException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AppPlatformNotSetUpException(message: $message)';
  }
}

class _AppPlatformNotSetUpExceptionImpl extends AppPlatformNotSetUpException {
  _AppPlatformNotSetUpExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [AppPlatformNotSetUpException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppPlatformNotSetUpException copyWith({String? message}) {
    return AppPlatformNotSetUpException(message: message ?? this.message);
  }
}

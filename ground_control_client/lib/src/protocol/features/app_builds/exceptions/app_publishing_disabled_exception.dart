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

/// Thrown by every app publishing and app build method while the feature
/// is turned off in this environment.
abstract class AppPublishingDisabledException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  AppPublishingDisabledException._({required this.message});

  factory AppPublishingDisabledException({required String message}) =
      _AppPublishingDisabledExceptionImpl;

  factory AppPublishingDisabledException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AppPublishingDisabledException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [AppPublishingDisabledException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppPublishingDisabledException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppPublishingDisabledException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppPublishingDisabledException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AppPublishingDisabledException(message: $message)';
  }
}

class _AppPublishingDisabledExceptionImpl
    extends AppPublishingDisabledException {
  _AppPublishingDisabledExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [AppPublishingDisabledException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppPublishingDisabledException copyWith({String? message}) {
    return AppPublishingDisabledException(message: message ?? this.message);
  }
}

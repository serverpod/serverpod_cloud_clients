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
import '../../../features/app_builds/models/ios_bundle_id_registration_status.dart'
    as _iba9cq52;

/// The outcome of registering the iOS bundle ID of a capsule with Apple.
abstract class IosBundleIdRegistration
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IosBundleIdRegistration._({required this.status, this.message});

  factory IosBundleIdRegistration({
    required _iba9cq52.IosBundleIdRegistrationStatus status,
    String? message,
  }) = _IosBundleIdRegistrationImpl;

  factory IosBundleIdRegistration.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return IosBundleIdRegistration(
      status: _iba9cq52.IosBundleIdRegistrationStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      message: jsonSerialization['message'] as String?,
    );
  }

  _iba9cq52.IosBundleIdRegistrationStatus status;

  /// Why the bundle ID is not registered. Null when it is.
  String? message;

  /// Returns a shallow copy of this [IosBundleIdRegistration]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IosBundleIdRegistration copyWith({
    _iba9cq52.IosBundleIdRegistrationStatus? status,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IosBundleIdRegistration',
      'status': status.toJson(),
      if (message != null) 'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IosBundleIdRegistration',
      'status': status.toJson(),
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IosBundleIdRegistrationImpl extends IosBundleIdRegistration {
  _IosBundleIdRegistrationImpl({
    required _iba9cq52.IosBundleIdRegistrationStatus status,
    String? message,
  }) : super._(status: status, message: message);

  /// Returns a shallow copy of this [IosBundleIdRegistration]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IosBundleIdRegistration copyWith({
    _iba9cq52.IosBundleIdRegistrationStatus? status,
    Object? message = _Undefined,
  }) {
    return IosBundleIdRegistration(
      status: status ?? this.status,
      message: message is String? ? message : this.message,
    );
  }
}

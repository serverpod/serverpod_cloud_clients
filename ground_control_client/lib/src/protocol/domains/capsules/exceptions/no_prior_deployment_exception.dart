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

/// Exception thrown when no prior deployment exists for a capsule.
abstract class NoPriorDeploymentException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  NoPriorDeploymentException._({required this.capsuleId});

  factory NoPriorDeploymentException({required String capsuleId}) =
      _NoPriorDeploymentExceptionImpl;

  factory NoPriorDeploymentException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return NoPriorDeploymentException(
      capsuleId: jsonSerialization['capsuleId'] as String,
    );
  }

  String capsuleId;

  /// Returns a shallow copy of this [NoPriorDeploymentException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NoPriorDeploymentException copyWith({String? capsuleId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NoPriorDeploymentException',
      'capsuleId': capsuleId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NoPriorDeploymentException',
      'capsuleId': capsuleId,
    };
  }

  @override
  String toString() {
    return 'NoPriorDeploymentException(capsuleId: $capsuleId)';
  }
}

class _NoPriorDeploymentExceptionImpl extends NoPriorDeploymentException {
  _NoPriorDeploymentExceptionImpl({required String capsuleId})
    : super._(capsuleId: capsuleId);

  /// Returns a shallow copy of this [NoPriorDeploymentException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NoPriorDeploymentException copyWith({String? capsuleId}) {
    return NoPriorDeploymentException(capsuleId: capsuleId ?? this.capsuleId);
  }
}

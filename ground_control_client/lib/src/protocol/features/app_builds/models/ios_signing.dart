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

/// How a capsule's iOS builds are signed.
abstract class IosSigning
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IosSigning._({required this.bundleId});

  factory IosSigning({required String bundleId}) = _IosSigningImpl;

  factory IosSigning.fromJson(Map<String, dynamic> jsonSerialization) {
    return IosSigning(bundleId: jsonSerialization['bundleId'] as String);
  }

  String bundleId;

  /// Returns a shallow copy of this [IosSigning]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IosSigning copyWith({String? bundleId});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'IosSigning', 'bundleId': bundleId};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'IosSigning', 'bundleId': bundleId};
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _IosSigningImpl extends IosSigning {
  _IosSigningImpl({required String bundleId}) : super._(bundleId: bundleId);

  /// Returns a shallow copy of this [IosSigning]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IosSigning copyWith({String? bundleId}) {
    return IosSigning(bundleId: bundleId ?? this.bundleId);
  }
}

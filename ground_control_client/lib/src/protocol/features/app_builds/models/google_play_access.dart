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

/// The Google Play service account a capsule publishes Android builds with.
abstract class GooglePlayAccess
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GooglePlayAccess._({required this.serviceAccountEmail});

  factory GooglePlayAccess({required String serviceAccountEmail}) =
      _GooglePlayAccessImpl;

  factory GooglePlayAccess.fromJson(Map<String, dynamic> jsonSerialization) {
    return GooglePlayAccess(
      serviceAccountEmail: jsonSerialization['serviceAccountEmail'] as String,
    );
  }

  String serviceAccountEmail;

  /// Returns a shallow copy of this [GooglePlayAccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GooglePlayAccess copyWith({String? serviceAccountEmail});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GooglePlayAccess',
      'serviceAccountEmail': serviceAccountEmail,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GooglePlayAccess',
      'serviceAccountEmail': serviceAccountEmail,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _GooglePlayAccessImpl extends GooglePlayAccess {
  _GooglePlayAccessImpl({required String serviceAccountEmail})
    : super._(serviceAccountEmail: serviceAccountEmail);

  /// Returns a shallow copy of this [GooglePlayAccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GooglePlayAccess copyWith({String? serviceAccountEmail}) {
    return GooglePlayAccess(
      serviceAccountEmail: serviceAccountEmail ?? this.serviceAccountEmail,
    );
  }
}

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

/// A Dart SDK version supported by Serverpod Cloud.
abstract class DartSdkVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DartSdkVersion._({required this.version});

  factory DartSdkVersion({required String version}) = _DartSdkVersionImpl;

  factory DartSdkVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return DartSdkVersion(version: jsonSerialization['version'] as String);
  }

  /// The Dart SDK minor version, such as "3.8".
  String version;

  /// Returns a shallow copy of this [DartSdkVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DartSdkVersion copyWith({String? version});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'DartSdkVersion', 'version': version};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'DartSdkVersion', 'version': version};
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DartSdkVersionImpl extends DartSdkVersion {
  _DartSdkVersionImpl({required String version}) : super._(version: version);

  /// Returns a shallow copy of this [DartSdkVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DartSdkVersion copyWith({String? version}) {
    return DartSdkVersion(version: version ?? this.version);
  }
}

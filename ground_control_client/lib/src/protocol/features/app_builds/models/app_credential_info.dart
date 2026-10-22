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
import '../../../domains/app_builds/models/app_credential_kind.dart'
    as _iw6szcel;

/// A credential that is set for a platform. The value is never returned.
abstract class AppCredentialInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppCredentialInfo._({required this.kind, required this.setAt});

  factory AppCredentialInfo({
    required _iw6szcel.AppCredentialKind kind,
    required DateTime setAt,
  }) = _AppCredentialInfoImpl;

  factory AppCredentialInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppCredentialInfo(
      kind: _iw6szcel.AppCredentialKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      setAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['setAt']),
    );
  }

  _iw6szcel.AppCredentialKind kind;

  /// When the credential was last set or replaced.
  DateTime setAt;

  /// Returns a shallow copy of this [AppCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppCredentialInfo copyWith({
    _iw6szcel.AppCredentialKind? kind,
    DateTime? setAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppCredentialInfo',
      'kind': kind.toJson(),
      'setAt': setAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppCredentialInfo',
      'kind': kind.toJson(),
      'setAt': setAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppCredentialInfoImpl extends AppCredentialInfo {
  _AppCredentialInfoImpl({
    required _iw6szcel.AppCredentialKind kind,
    required DateTime setAt,
  }) : super._(kind: kind, setAt: setAt);

  /// Returns a shallow copy of this [AppCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppCredentialInfo copyWith({
    _iw6szcel.AppCredentialKind? kind,
    DateTime? setAt,
  }) {
    return AppCredentialInfo(
      kind: kind ?? this.kind,
      setAt: setAt ?? this.setAt,
    );
  }
}

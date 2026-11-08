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

/// How a capsule's Android builds are signed.
abstract class AndroidSigning
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AndroidSigning._({
    required this.keyAlias,
    required this.generated,
    required this.createdAt,
  });

  factory AndroidSigning({
    required String keyAlias,
    required bool generated,
    required DateTime createdAt,
  }) = _AndroidSigningImpl;

  factory AndroidSigning.fromJson(Map<String, dynamic> jsonSerialization) {
    return AndroidSigning(
      keyAlias: jsonSerialization['keyAlias'] as String,
      generated: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['generated'],
      ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  String keyAlias;

  /// Whether Ground Control generated the keystore, as opposed to the user
  /// uploading it.
  bool generated;

  /// When the keystore was generated or uploaded.
  DateTime createdAt;

  /// Returns a shallow copy of this [AndroidSigning]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AndroidSigning copyWith({
    String? keyAlias,
    bool? generated,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AndroidSigning',
      'keyAlias': keyAlias,
      'generated': generated,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AndroidSigning',
      'keyAlias': keyAlias,
      'generated': generated,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AndroidSigningImpl extends AndroidSigning {
  _AndroidSigningImpl({
    required String keyAlias,
    required bool generated,
    required DateTime createdAt,
  }) : super._(keyAlias: keyAlias, generated: generated, createdAt: createdAt);

  /// Returns a shallow copy of this [AndroidSigning]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AndroidSigning copyWith({
    String? keyAlias,
    bool? generated,
    DateTime? createdAt,
  }) {
    return AndroidSigning(
      keyAlias: keyAlias ?? this.keyAlias,
      generated: generated ?? this.generated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

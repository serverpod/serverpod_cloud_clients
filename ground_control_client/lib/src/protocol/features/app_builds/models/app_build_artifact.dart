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
import '../../../features/app_builds/models/app_build_artifact_kind.dart'
    as _irk40i9z;

/// A file an app build produced, as the build service lists it.
abstract class AppBuildArtifact
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildArtifact._({
    required this.id,
    required this.name,
    required this.kind,
    required this.sizeBytes,
  });

  factory AppBuildArtifact({
    required String id,
    required String name,
    required _irk40i9z.AppBuildArtifactKind kind,
    required int sizeBytes,
  }) = _AppBuildArtifactImpl;

  factory AppBuildArtifact.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildArtifact(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      kind: _irk40i9z.AppBuildArtifactKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      sizeBytes: jsonSerialization['sizeBytes'] as int,
    );
  }

  /// Identifies the file in `getArtifactDownloadUrl`. Opaque.
  String id;

  /// The file name.
  String name;

  _irk40i9z.AppBuildArtifactKind kind;

  int sizeBytes;

  /// Returns a shallow copy of this [AppBuildArtifact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildArtifact copyWith({
    String? id,
    String? name,
    _irk40i9z.AppBuildArtifactKind? kind,
    int? sizeBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildArtifact',
      'id': id,
      'name': name,
      'kind': kind.toJson(),
      'sizeBytes': sizeBytes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildArtifact',
      'id': id,
      'name': name,
      'kind': kind.toJson(),
      'sizeBytes': sizeBytes,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppBuildArtifactImpl extends AppBuildArtifact {
  _AppBuildArtifactImpl({
    required String id,
    required String name,
    required _irk40i9z.AppBuildArtifactKind kind,
    required int sizeBytes,
  }) : super._(id: id, name: name, kind: kind, sizeBytes: sizeBytes);

  /// Returns a shallow copy of this [AppBuildArtifact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildArtifact copyWith({
    String? id,
    String? name,
    _irk40i9z.AppBuildArtifactKind? kind,
    int? sizeBytes,
  }) {
    return AppBuildArtifact(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
}

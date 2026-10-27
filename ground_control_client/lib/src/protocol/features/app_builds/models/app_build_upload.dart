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

/// A newly requested app build and where to upload its source.
abstract class AppBuildUpload
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildUpload._({required this.buildId, required this.uploadDescription});

  factory AppBuildUpload({
    required _isc.UuidValue buildId,
    required String uploadDescription,
  }) = _AppBuildUploadImpl;

  factory AppBuildUpload.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildUpload(
      buildId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['buildId'],
      ),
      uploadDescription: jsonSerialization['uploadDescription'] as String,
    );
  }

  _isc.UuidValue buildId;

  /// Describes how to upload the app archive, in the same format as a
  /// server deploy's upload description.
  String uploadDescription;

  /// Returns a shallow copy of this [AppBuildUpload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildUpload copyWith({_isc.UuidValue? buildId, String? uploadDescription});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildUpload',
      'buildId': buildId.toJson(),
      'uploadDescription': uploadDescription,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildUpload',
      'buildId': buildId.toJson(),
      'uploadDescription': uploadDescription,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppBuildUploadImpl extends AppBuildUpload {
  _AppBuildUploadImpl({
    required _isc.UuidValue buildId,
    required String uploadDescription,
  }) : super._(buildId: buildId, uploadDescription: uploadDescription);

  /// Returns a shallow copy of this [AppBuildUpload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildUpload copyWith({
    _isc.UuidValue? buildId,
    String? uploadDescription,
  }) {
    return AppBuildUpload(
      buildId: buildId ?? this.buildId,
      uploadDescription: uploadDescription ?? this.uploadDescription,
    );
  }
}

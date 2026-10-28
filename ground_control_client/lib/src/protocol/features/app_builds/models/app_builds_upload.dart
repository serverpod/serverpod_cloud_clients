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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../features/app_builds/models/app_build_ref.dart' as _i9jyz2kf;

/// Newly requested app builds that share one archive, and where to upload it.
abstract class AppBuildsUpload
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildsUpload._({
    required this.uploadId,
    required this.builds,
    required this.uploadDescription,
  });

  factory AppBuildsUpload({
    required _isc.UuidValue uploadId,
    required List<_i9jyz2kf.AppBuildRef> builds,
    required String uploadDescription,
  }) = _AppBuildsUploadImpl;

  factory AppBuildsUpload.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildsUpload(
      uploadId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['uploadId'],
      ),
      builds: _iod2a87h.Protocol().deserialize<List<_i9jyz2kf.AppBuildRef>>(
        jsonSerialization['builds'],
      ),
      uploadDescription: jsonSerialization['uploadDescription'] as String,
    );
  }

  _isc.UuidValue uploadId;

  /// One build per requested platform.
  List<_i9jyz2kf.AppBuildRef> builds;

  /// Describes how to upload the app archive, in the same format as a
  /// server deploy's upload description.
  String uploadDescription;

  /// Returns a shallow copy of this [AppBuildsUpload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildsUpload copyWith({
    _isc.UuidValue? uploadId,
    List<_i9jyz2kf.AppBuildRef>? builds,
    String? uploadDescription,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildsUpload',
      'uploadId': uploadId.toJson(),
      'builds': builds.toJson(valueToJson: (v) => v.toJson()),
      'uploadDescription': uploadDescription,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildsUpload',
      'uploadId': uploadId.toJson(),
      'builds': builds.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'uploadDescription': uploadDescription,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppBuildsUploadImpl extends AppBuildsUpload {
  _AppBuildsUploadImpl({
    required _isc.UuidValue uploadId,
    required List<_i9jyz2kf.AppBuildRef> builds,
    required String uploadDescription,
  }) : super._(
         uploadId: uploadId,
         builds: builds,
         uploadDescription: uploadDescription,
       );

  /// Returns a shallow copy of this [AppBuildsUpload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildsUpload copyWith({
    _isc.UuidValue? uploadId,
    List<_i9jyz2kf.AppBuildRef>? builds,
    String? uploadDescription,
  }) {
    return AppBuildsUpload(
      uploadId: uploadId ?? this.uploadId,
      builds: builds ?? this.builds.map((e0) => e0.copyWith()).toList(),
      uploadDescription: uploadDescription ?? this.uploadDescription,
    );
  }
}

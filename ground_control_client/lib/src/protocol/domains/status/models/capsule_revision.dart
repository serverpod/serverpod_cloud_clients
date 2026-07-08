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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// The identity of one revision of a capsule deployment.
abstract class CapsuleRevision implements _i1.SerializableModel {
  CapsuleRevision._({this.uploadId, this.buildId});

  factory CapsuleRevision({_i1.UuidValue? uploadId, _i1.UuidValue? buildId}) =
      _CapsuleRevisionImpl;

  factory CapsuleRevision.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapsuleRevision(
      uploadId: jsonSerialization['uploadId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['uploadId']),
      buildId: jsonSerialization['buildId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['buildId']),
    );
  }

  /// The upload this revision was built from.
  _i1.UuidValue? uploadId;

  /// The build produced from that upload.
  _i1.UuidValue? buildId;

  /// Returns a shallow copy of this [CapsuleRevision]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapsuleRevision copyWith({_i1.UuidValue? uploadId, _i1.UuidValue? buildId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleRevision',
      if (uploadId != null) 'uploadId': uploadId?.toJson(),
      if (buildId != null) 'buildId': buildId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapsuleRevisionImpl extends CapsuleRevision {
  _CapsuleRevisionImpl({_i1.UuidValue? uploadId, _i1.UuidValue? buildId})
    : super._(uploadId: uploadId, buildId: buildId);

  /// Returns a shallow copy of this [CapsuleRevision]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapsuleRevision copyWith({
    Object? uploadId = _Undefined,
    Object? buildId = _Undefined,
  }) {
    return CapsuleRevision(
      uploadId: uploadId is _i1.UuidValue? ? uploadId : this.uploadId,
      buildId: buildId is _i1.UuidValue? ? buildId : this.buildId,
    );
  }
}

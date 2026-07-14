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

/// A single stored file in a bucket.
abstract class BucketFile implements _i1.SerializableModel {
  BucketFile._({required this.name, this.sizeBytes, this.updated});

  factory BucketFile({
    required String name,
    int? sizeBytes,
    DateTime? updated,
  }) = _BucketFileImpl;

  factory BucketFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return BucketFile(
      name: jsonSerialization['name'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int?,
      updated: jsonSerialization['updated'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updated']),
    );
  }

  /// The object name, i.e. the full path within the bucket.
  String name;

  /// The size of the file in bytes. Null if the size is unknown.
  int? sizeBytes;

  /// When the file was last updated. Null if unknown.
  DateTime? updated;

  /// Returns a shallow copy of this [BucketFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BucketFile copyWith({String? name, int? sizeBytes, DateTime? updated});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketFile',
      'name': name,
      if (sizeBytes != null) 'sizeBytes': sizeBytes,
      if (updated != null) 'updated': updated?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BucketFileImpl extends BucketFile {
  _BucketFileImpl({required String name, int? sizeBytes, DateTime? updated})
    : super._(name: name, sizeBytes: sizeBytes, updated: updated);

  /// Returns a shallow copy of this [BucketFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BucketFile copyWith({
    String? name,
    Object? sizeBytes = _Undefined,
    Object? updated = _Undefined,
  }) {
    return BucketFile(
      name: name ?? this.name,
      sizeBytes: sizeBytes is int? ? sizeBytes : this.sizeBytes,
      updated: updated is DateTime? ? updated : this.updated,
    );
  }
}

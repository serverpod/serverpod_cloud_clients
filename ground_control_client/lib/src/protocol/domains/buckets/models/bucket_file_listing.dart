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
import '../../../domains/buckets/models/bucket_file.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

/// A single page of files in a bucket together with the token for the next page.
abstract class BucketFileListing implements _i1.SerializableModel {
  BucketFileListing._({required this.files, this.nextPageToken});

  factory BucketFileListing({
    required List<_i2.BucketFile> files,
    String? nextPageToken,
  }) = _BucketFileListingImpl;

  factory BucketFileListing.fromJson(Map<String, dynamic> jsonSerialization) {
    return BucketFileListing(
      files: _i3.Protocol().deserialize<List<_i2.BucketFile>>(
        jsonSerialization['files'],
      ),
      nextPageToken: jsonSerialization['nextPageToken'] as String?,
    );
  }

  /// The files on this page of the listing.
  List<_i2.BucketFile> files;

  /// The token for the next page, or null when the listing has been fully
  /// consumed.
  String? nextPageToken;

  /// Returns a shallow copy of this [BucketFileListing]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BucketFileListing copyWith({
    List<_i2.BucketFile>? files,
    String? nextPageToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BucketFileListing',
      'files': files.toJson(valueToJson: (v) => v.toJson()),
      if (nextPageToken != null) 'nextPageToken': nextPageToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BucketFileListingImpl extends BucketFileListing {
  _BucketFileListingImpl({
    required List<_i2.BucketFile> files,
    String? nextPageToken,
  }) : super._(files: files, nextPageToken: nextPageToken);

  /// Returns a shallow copy of this [BucketFileListing]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BucketFileListing copyWith({
    List<_i2.BucketFile>? files,
    Object? nextPageToken = _Undefined,
  }) {
    return BucketFileListing(
      files: files ?? this.files.map((e0) => e0.copyWith()).toList(),
      nextPageToken: nextPageToken is String?
          ? nextPageToken
          : this.nextPageToken,
    );
  }
}

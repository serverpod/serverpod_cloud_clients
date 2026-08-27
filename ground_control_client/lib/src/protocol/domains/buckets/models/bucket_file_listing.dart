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
import '../../../domains/buckets/models/bucket_file.dart' as _imrmxowf;

/// A single page of files in a bucket together with the token for the next page.
abstract class BucketFileListing
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  BucketFileListing._({required this.files, this.nextPageToken});

  factory BucketFileListing({
    required List<_imrmxowf.BucketFile> files,
    String? nextPageToken,
  }) = _BucketFileListingImpl;

  factory BucketFileListing.fromJson(Map<String, dynamic> jsonSerialization) {
    return BucketFileListing(
      files: _iod2a87h.Protocol().deserialize<List<_imrmxowf.BucketFile>>(
        jsonSerialization['files'],
      ),
      nextPageToken: jsonSerialization['nextPageToken'] as String?,
    );
  }

  /// The files on this page of the listing.
  List<_imrmxowf.BucketFile> files;

  /// The token for the next page, or null when the listing has been fully
  /// consumed.
  String? nextPageToken;

  /// Returns a shallow copy of this [BucketFileListing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BucketFileListing copyWith({
    List<_imrmxowf.BucketFile>? files,
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BucketFileListing',
      'files': files.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextPageToken != null) 'nextPageToken': nextPageToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BucketFileListingImpl extends BucketFileListing {
  _BucketFileListingImpl({
    required List<_imrmxowf.BucketFile> files,
    String? nextPageToken,
  }) : super._(files: files, nextPageToken: nextPageToken);

  /// Returns a shallow copy of this [BucketFileListing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BucketFileListing copyWith({
    List<_imrmxowf.BucketFile>? files,
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

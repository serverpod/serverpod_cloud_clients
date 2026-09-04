import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';

/// One upload performed through a [RecordingFileUploader].
class RecordedUpload {
  final String uploadDescription;
  final List<int> data;

  RecordedUpload({required this.uploadDescription, required this.data});
}

/// A [FileUploaderClient] that records every upload, so a test can assert
/// what a multi-file upload sent.
///
/// Unlike `MockFileUploader` it keeps one entry per upload instead of only
/// the last one, and it can be told to fail.
class RecordingFileUploader implements FileUploaderClient {
  final List<RecordedUpload> uploads = [];

  bool uploadResponse = true;
  DioException? throwOnUpload;

  /// Uploads from this index on report failure. Null uploads every file
  /// successfully.
  int? failFromIndex;

  String _uploadDescription = '';

  /// Returns a factory that hands out this uploader for every description.
  FileUploaderClient Function(String) get factory {
    return (final uploadDescription) {
      _uploadDescription = uploadDescription;
      return this;
    };
  }

  void clear() {
    uploads.clear();
    uploadResponse = true;
    throwOnUpload = null;
    failFromIndex = null;
  }

  @override
  Future<bool> uploadByteData(final ByteData byteData) {
    return upload(
      Stream.value(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      ),
      byteData.lengthInBytes,
    );
  }

  @override
  Future<bool> upload(final Stream<List<int>> stream, final int length) async {
    final data = <int>[];
    await for (final segment in stream) {
      data.addAll(segment);
    }
    uploads.add(
      RecordedUpload(uploadDescription: _uploadDescription, data: data),
    );

    final failure = throwOnUpload;
    if (failure != null) {
      throw failure;
    }

    final failFrom = failFromIndex;
    if (failFrom != null && uploads.length > failFrom) {
      return false;
    }

    return uploadResponse;
  }
}

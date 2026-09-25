import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../file_uploader_client.dart';

/// A mock implementation of [FileUploaderClient] that can be used to test
/// file uploads.
class MockFileUploader implements FileUploaderClient {
  /// The response to the upload request.
  bool uploadResponse;

  /// The data that was uploaded.
  List<int> uploadedData;

  /// Thrown by [upload] instead of returning [uploadResponse].
  Exception? uploadError;

  /// Creates a new [MockFileUploader].
  MockFileUploader({
    this.uploadResponse = true,
    this.uploadedData = const [],
    this.uploadError,
  });

  /// Initializes the [MockFileUploader].
  void init({
    bool uploadResponse = true,
    List<int> uploadedData = const [],
    Exception? uploadError,
  }) {
    this.uploadResponse = uploadResponse;
    this.uploadedData = uploadedData;
    this.uploadError = uploadError;
  }

  /// Uploads a file contained by a [ByteData] object,
  /// returns true if successful.
  @override
  Future<bool> uploadByteData(
    ByteData byteData, {
    UploadProgressCallback? onProgress,
  }) async {
    final stream = http.ByteStream.fromBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    return upload(stream, byteData.lengthInBytes, onProgress: onProgress);
  }

  /// Uploads a file from a [Stream], returns true if successful.
  @override
  Future<bool> upload(
    Stream<List<int>> stream,
    int length, {
    UploadProgressCallback? onProgress,
  }) async {
    uploadedData = await _readStreamData(stream);
    final error = uploadError;
    if (error != null) {
      throw error;
    }
    onProgress?.call(uploadedData.length, length);
    return uploadResponse;
  }

  static Future<List<int>> _readStreamData(Stream<List<int>> stream) async {
    final data = <int>[];
    await for (final segment in stream) {
      data.addAll(segment);
    }
    return data;
  }
}

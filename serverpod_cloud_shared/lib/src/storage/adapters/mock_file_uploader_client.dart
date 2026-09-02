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

  /// Creates a new [MockFileUploader].
  MockFileUploader({this.uploadResponse = true, this.uploadedData = const []});

  /// Initializes the [MockFileUploader].
  void init({bool uploadResponse = true, List<int> uploadedData = const []}) {
    this.uploadResponse = uploadResponse;
    this.uploadedData = uploadedData;
  }

  /// Uploads a file contained by a [ByteData] object,
  /// returns true if successful.
  @override
  Future<bool> uploadByteData(ByteData byteData) async {
    final stream = http.ByteStream.fromBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    return upload(stream, byteData.lengthInBytes);
  }

  /// Uploads a file from a [Stream], returns true if successful.
  @override
  Future<bool> upload(Stream<List<int>> stream, int length) async {
    uploadedData = await _readStreamData(stream);
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

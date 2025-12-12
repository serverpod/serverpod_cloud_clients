import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../file_uploader_client.dart';

class MockFileUploader implements FileUploaderClient {
  bool uploadResponse;
  List<int> uploadedData;

  MockFileUploader({this.uploadResponse = true, this.uploadedData = const []});

  void init({bool uploadResponse = true, List<int> uploadedData = const []}) {
    this.uploadResponse = uploadResponse;
    this.uploadedData = uploadedData;
  }

  /// Uploads a file contained by a [ByteData] object,
  /// returns true if successful.
  Future<bool> uploadByteData(ByteData byteData) async {
    var stream = http.ByteStream.fromBytes(byteData.buffer.asUint8List());
    return upload(stream, byteData.lengthInBytes);
  }

  /// Uploads a file from a [Stream], returns true if successful.
  Future<bool> upload(Stream<List<int>> stream, int length) async {
    uploadedData = await _readStreamData(stream);
    return uploadResponse;
  }

  static Future<List<int>> _readStreamData(Stream<List<int>> stream) async {
    var data = <int>[];
    await for (var segment in stream) {
      data += segment;
    }
    return data;
  }
}

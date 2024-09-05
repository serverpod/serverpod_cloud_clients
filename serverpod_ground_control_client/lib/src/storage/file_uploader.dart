import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// The file uploader uploads files to Serverpod's cloud storage. On the server
/// you can setup a custom storage service, such as S3 or Google Cloud. To
/// directly upload a file, you first need to retrieve an upload description
/// from your server. After the file is uploaded, make sure to notify the server
/// by calling the verifyDirectFileUpload on the current Session object.
class GoogleCloudStorageUploader {
  late final _UploadDescription _uploadDescription;
  bool _attemptedUpload = false;

  /// Creates a new FileUploader from an [uploadDescription] created by the
  /// server.
  GoogleCloudStorageUploader(String uploadDescription) {
    _uploadDescription = _UploadDescription(uploadDescription);
  }

  /// Uploads a file contained by a [ByteData] object, returns true if
  /// successful.
  Future<bool> uploadByteData(ByteData byteData) async {
    var stream = http.ByteStream.fromBytes(byteData.buffer.asUint8List());
    return upload(stream, byteData.lengthInBytes);
  }

  /// Uploads a file from a [Stream], returns true if successful.
  Future<bool> upload(Stream<List<int>> stream, int length) async {
    if (_attemptedUpload) {
      throw Exception(
          'Data has already been uploaded using this FileUploader.');
    }
    _attemptedUpload = true;

    if (_uploadDescription.type == _UploadType.binary) {
      try {
        var result = switch (_uploadDescription.httpMethod) {
          'PUT' => await http.put(
              _uploadDescription.url,
              body: await _readStreamData(stream),
              headers: _uploadDescription.headers,
            ),
          _ => await http.post(
              _uploadDescription.url,
              body: await _readStreamData(stream),
              headers: _uploadDescription.headers,
            ),
        };

        return result.statusCode == 200;
      } catch (e) {
        return false;
      }
    } else if (_uploadDescription.type == _UploadType.multipart) {
      var request = http.MultipartRequest('POST', _uploadDescription.url);
      var multipartFile = http.MultipartFile(
          _uploadDescription.field!, stream, length,
          filename: _uploadDescription.fileName);

      request.files.add(multipartFile);
      for (var key in _uploadDescription.requestFields.keys) {
        request.fields[key] = _uploadDescription.requestFields[key]!;
      }

      try {
        var result = await request.send();
        return result.statusCode == 204;
      } catch (e) {
        return false;
      }
    }
    throw UnimplementedError('Unknown upload type');
  }

  Future<List<int>> _readStreamData(Stream<List<int>> stream) async {
    // TODO: Find more efficient solution?
    var data = <int>[];
    await for (var segment in stream) {
      data += segment;
    }
    return data;
  }
}

enum _UploadType {
  binary,
  multipart,
}

class _UploadDescription {
  late _UploadType type;
  late Uri url;
  String? field;
  String? fileName;
  String? httpMethod = 'POST';
  Map<String, String> headers = {};
  Map<String, String> requestFields = {};

  _UploadDescription(String description) {
    var data = jsonDecode(description);
    if (data['type'] == 'binary') {
      type = _UploadType.binary;
    } else if (data['type'] == 'multipart') {
      type = _UploadType.multipart;
    } else {
      throw const FormatException('Missing type, can be binary or multipart');
    }

    httpMethod = data['httpMethod'];
    headers = (data['headers'] as Map).cast<String, String>();
    headers.remove('host');
    url = Uri.parse(data['url']);

    if (type == _UploadType.multipart) {
      field = data['field'];
      fileName = data['file-name'];
      requestFields = (data['request-fields'] as Map).cast<String, String>();
    }
  }
}

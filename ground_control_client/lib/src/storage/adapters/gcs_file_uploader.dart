import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ground_control_client/src/utils/retry.dart';

import '../file_uploader_client.dart';

/// The file uploader uploads files to Serverpod's cloud storage. On the server
/// you can setup a custom storage service, such as S3 or Google Cloud. To
/// directly upload a file, you first need to retrieve an upload description
/// from your server. After the file is uploaded, make sure to notify the server
/// by calling the verifyDirectFileUpload on the current Session object.
class GoogleCloudStorageUploader implements FileUploaderClient {
  late final _UploadDescription _uploadDescription;
  bool _attemptedUpload = false;
  late final Dio _dio;

  /// Creates a new FileUploader from an [uploadDescription] created by the
  /// server. Optionally, you can pass a [Dio] instance to use for the upload to control
  /// the timeout and other settings.
  GoogleCloudStorageUploader(String uploadDescription, {Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
    _uploadDescription = _UploadDescription(uploadDescription);
  }

  /// Uploads a file contained by a [ByteData] object, returns true if
  /// successful.
  @override
  Future<bool> uploadByteData(ByteData byteData) async {
    var stream = Stream.fromIterable([byteData.buffer.asUint8List()]);
    return upload(stream, byteData.lengthInBytes);
  }

  /// Uploads a file from a [Stream], returns true if successful.
  @override
  Future<bool> upload(Stream<List<int>> stream, int length) async {
    if (_attemptedUpload) {
      throw Exception(
          'Data has already been uploaded using this FileUploader.');
    }
    _attemptedUpload = true;

    final broadcastStream =
        stream.isBroadcast ? stream : stream.asBroadcastStream();

    switch (_uploadDescription.type) {
      case _UploadType.binary:
        final Response result;
        try {
          result = switch (_uploadDescription.httpMethod) {
            'PUT' => await withRetry(
                () => _dio.putUri(
                  _uploadDescription.url,
                  data: broadcastStream,
                  options: Options(headers: _uploadDescription.headers),
                ),
                shouldRetryOnException: _shouldRetry,
              ),
            _ => await withRetry(
                () => _dio.postUri(
                  _uploadDescription.url,
                  data: broadcastStream,
                  options: Options(headers: _uploadDescription.headers),
                ),
                shouldRetryOnException: _shouldRetry,
              ),
          };
        } on DioException {
          rethrow;
        } catch (e) {
          throw Exception('Failed to upload binary file, error: $e');
        }

        if (result.statusCode == 200) {
          return true;
        }
        throw Exception('Failed to upload binary file, '
            'response code ${result.statusCode}, body: ${result.data}, '
            '$_uploadDescription');

      case _UploadType.multipart:
        var multipartFile = MultipartFile.fromStream(
          () => broadcastStream,
          length,
          filename: _uploadDescription.fileName,
        );
        final formData = FormData.fromMap({
          'files': [
            multipartFile,
          ],
        });

        for (var key in _uploadDescription.requestFields.keys) {
          final value = _uploadDescription.requestFields[key];
          if (value == null) {
            continue;
          }
          formData.fields.add(
            MapEntry(
              key,
              value,
            ),
          );
        }

        final Response result;
        try {
          result = await withRetry(
            () => _dio.postUri(
              _uploadDescription.url,
              data: formData,
              options: Options(headers: _uploadDescription.headers),
            ),
            shouldRetryOnException: _shouldRetry,
          );
        } on DioException {
          rethrow;
        } catch (e) {
          throw Exception('Failed to upload multipart file, error: $e');
        }
        if (result.statusCode == 204) {
          return true;
        }
        throw Exception('Failed to upload multipart file, '
            'response code ${result.statusCode}, body: ${result.data}, '
            '$_uploadDescription');
    }
  }

  bool _shouldRetry(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;
    }
    return false;
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

  String toString() {
    return '_UploadDescription{type: $type, url: $url, field: $field, fileName: $fileName, requestFields: $requestFields}';
  }
}

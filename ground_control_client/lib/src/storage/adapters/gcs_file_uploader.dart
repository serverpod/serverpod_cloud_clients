import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../file_uploader_client.dart';

/// The file uploader uploads files to Serverpod's cloud storage. On the server
/// you can setup a custom storage service, such as S3 or Google Cloud. To
/// directly upload a file, you first need to retrieve an upload description
/// from your server. After the file is uploaded, make sure to notify the server
/// by calling the verifyDirectFileUpload on the current Session object.
class GoogleCloudStorageUploader implements FileUploaderClient {
  late final _UploadDescription _uploadDescription;
  bool _attemptedUpload = false;
  int retryCount = 0;
  int _maxRetries = 2;
  late final Dio _dio;

  /// Creates a new FileUploader from an [uploadDescription] created by the
  /// server. Optionally, you can pass a [Dio] instance to use for the upload to control
  /// the timeout and other settings.
  GoogleCloudStorageUploader(String uploadDescription, {Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 100),
            sendTimeout: const Duration(seconds: 200),
            receiveTimeout: const Duration(seconds: 100),
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
            'PUT' => await _dio.putUri(
                _uploadDescription.url,
                data: broadcastStream,
                options: Options(headers: _uploadDescription.headers),
              ),
            _ => await _dio.postUri(
                _uploadDescription.url,
                data: broadcastStream,
                options: Options(headers: _uploadDescription.headers),
              ),
          };
        } on DioException catch (e) {
          if (_shouldRetry(e)) {
            return await _retryUpload(
              broadcastStream,
              length,
            );
          }
          throw Exception(
            'Failed to upload binary file, error: ${_uploadDioErrorFormatter(e)}',
          );
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
          formData.fields.add(
            MapEntry(
              key,
              _uploadDescription.requestFields[key]!,
            ),
          );
        }

        final Response result;
        try {
          result = await _dio.postUri(
            _uploadDescription.url,
            data: formData,
            options: Options(headers: _uploadDescription.headers),
          );
        } on DioException catch (e) {
          if (_shouldRetry(e)) {
            return await _retryUpload(
              broadcastStream,
              length,
            );
          }
          throw Exception(
            'Failed to upload multipart file, error: ${_uploadDioErrorFormatter(e)}',
          );
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

  Future<bool> _retryUpload(
    final Stream<List<int>> stream,
    final int length,
  ) async {
    retryCount++;
    _attemptedUpload = false;
    print('\nRetrying upload... $retryCount of $_maxRetries');
    return upload(stream, length);
  }

  String _uploadDioErrorFormatter(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection Timeout. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Send Timeout. Please check your internet connection and try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive Timeout. Please check your internet connection and try again.';
      default:
        return e.toString();
    }
  }

  bool _shouldRetry(DioException e) {
    return retryCount < _maxRetries &&
        (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout);
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

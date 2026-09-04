import 'dart:io';

import 'package:dio/dio.dart';

/// Downloads a file over HTTP to the local file system.
abstract class FileDownloaderClient {
  /// Downloads [url] into [destination] and returns the number of bytes
  /// written.
  ///
  /// Throws [DioException] on an HTTP error status or a network failure.
  Future<int> download(Uri url, File destination);
}

/// A [FileDownloaderClient] backed by dio, the same HTTP client the uploads
/// use.
class DioFileDownloader implements FileDownloaderClient {
  final Dio _dio;

  DioFileDownloader({Dio? dio, Duration? timeout})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: timeout ?? const Duration(seconds: 30),
              sendTimeout: timeout ?? const Duration(seconds: 30),
              receiveTimeout: timeout ?? const Duration(seconds: 30),
            ),
          );

  @override
  Future<int> download(final Uri url, final File destination) async {
    await _dio.downloadUri(url, destination.path);

    return destination.length();
  }
}

typedef FileDownloaderFactory = FileDownloaderClient Function();

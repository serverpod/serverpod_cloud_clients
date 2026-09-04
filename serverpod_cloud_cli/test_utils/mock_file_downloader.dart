import 'dart:io';

import 'package:dio/dio.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_downloader.dart';

/// One download performed through a [MockFileDownloader].
class RecordedDownload {
  final Uri url;
  final File destination;

  RecordedDownload({required this.url, required this.destination});
}

/// A [FileDownloaderClient] that writes [bytes] to the destination instead of
/// making an HTTP request, and records what it was asked to download.
class MockFileDownloader implements FileDownloaderClient {
  final List<RecordedDownload> downloads = [];

  List<int> bytes;
  DioException? throwOnDownload;

  MockFileDownloader({this.bytes = const []});

  /// Returns a factory that hands out this downloader.
  FileDownloaderClient Function() get factory =>
      () => this;

  void init({List<int> bytes = const []}) {
    this.bytes = bytes;
  }

  void clear() {
    downloads.clear();
    bytes = const [];
    throwOnDownload = null;
  }

  @override
  Future<int> download(final Uri url, final File destination) async {
    downloads.add(RecordedDownload(url: url, destination: destination));

    final failure = throwOnDownload;
    if (failure != null) {
      throw failure;
    }

    await destination.writeAsBytes(bytes);

    return bytes.length;
  }
}

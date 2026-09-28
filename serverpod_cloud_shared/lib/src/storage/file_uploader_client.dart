import 'dart:typed_data';

/// Reports upload progress as [sentBytes] out of [totalBytes].
typedef UploadProgressCallback = void Function(int sentBytes, int totalBytes);

/// The file uploader uploads files to some storage.
abstract class FileUploaderClient {
  /// Uploads a file contained by a [ByteData] object,
  /// returns true if successful.
  Future<bool> uploadByteData(
    ByteData byteData, {
    UploadProgressCallback? onProgress,
  });

  /// Uploads a file from a [Stream], returns true if successful.
  /// [onProgress] reports the bytes sent so far.
  Future<bool> upload(
    Stream<List<int>> stream,
    int length, {
    UploadProgressCallback? onProgress,
  });
}

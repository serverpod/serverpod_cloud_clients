import 'dart:typed_data';

/// The file uploader uploads files to some storage.
abstract class FileUploaderClient {
  /// Uploads a file contained by a [ByteData] object,
  /// returns true if successful.
  Future<bool> uploadByteData(final ByteData byteData);

  /// Uploads a file from a [Stream], returns true if successful.
  Future<bool> upload(final Stream<List<int>> stream, final int length);
}

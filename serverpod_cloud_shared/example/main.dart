import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';

/// A placeholder upload description. In real use, the upload description is
/// created by the Ground Control server and describes where and how to
/// upload the file. Replace it with an actual server-created description to
/// run this example.
const uploadDescription = '''
{
  "type": "binary",
  "httpMethod": "PUT",
  "headers": {"content-type": "application/octet-stream"},
  "url": "https://storage.googleapis.com/my-bucket/my-file"
}
''';

Future<void> main() async {
  final data = utf8.encode('Hello, Serverpod Cloud!');

  final uploader = GoogleCloudStorageUploader(uploadDescription);
  try {
    final success = await uploader.upload(
      Stream.fromIterable([data]),
      data.length,
    );
    if (success) {
      stdout.writeln('Upload succeeded.');
    } else {
      stderr.writeln('Upload failed.');
      exitCode = 1;
    }
  } catch (error) {
    stderr.writeln('Upload failed: $error');
    exitCode = 1;
  }
}

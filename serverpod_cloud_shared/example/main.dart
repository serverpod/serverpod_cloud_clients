import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// A placeholder upload description. In real use, the upload description is
/// created by the Ground Control server and describes where and how to
/// upload the file. Replace it with an actual server-created description to
/// run this example.
const uploadDescription = '''
{
  "type": "binary",
  "method": "PUT",
  "headers": {"content-type": "application/octet-stream"},
  "url": "https://storage.googleapis.com/my-bucket/my-file"
}
''';

Future<void> main() async {
  final data = utf8.encode('Hello, Serverpod Cloud!');
  final description = jsonDecode(uploadDescription) as Map<String, dynamic>;
  final url = Uri.parse(description['url'] as String);
  final headers = (description['headers'] as Map).cast<String, String>();

  try {
    final response = await http.put(url, headers: headers, body: data);
    if (response.statusCode == 200 || response.statusCode == 204) {
      stdout.writeln('Upload succeeded.');
    } else {
      stderr.writeln('Upload failed: HTTP ${response.statusCode}');
      exitCode = 1;
    }
  } catch (error) {
    stderr.writeln('Upload failed: $error');
    exitCode = 1;
  }
}

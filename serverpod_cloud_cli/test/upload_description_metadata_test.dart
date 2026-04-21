import 'package:serverpod_cloud_cli/util/upload_description_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('resolvedDartImageTagFromUploadDescription', () {
    test('Given a binary upload JSON with x-goog-meta-dart-version '
        'when resolvedDartImageTagFromUploadDescription is called '
        'then the tag is returned', () {
      const json = '''
{"type":"binary","url":"https://example.com","httpMethod":"PUT","headers":{"x-goog-meta-dart-version":"3.10","host":"ignored"}}''';
      expect(resolvedDartImageTagFromUploadDescription(json), '3.10');
    });

    test('Given JSON without dart-version header '
        'when resolvedDartImageTagFromUploadDescription is called '
        'then null is returned', () {
      const json = '{"type":"binary","url":"https://x","headers":{}}';
      expect(resolvedDartImageTagFromUploadDescription(json), isNull);
    });

    test('Given invalid JSON '
        'when resolvedDartImageTagFromUploadDescription is called '
        'then null is returned', () {
      expect(resolvedDartImageTagFromUploadDescription('{'), isNull);
    });
  });
}

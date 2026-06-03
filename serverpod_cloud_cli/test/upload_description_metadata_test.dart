import 'package:serverpod_cloud_cli/util/upload_description_metadata.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid_value.dart';

void main() {
  group('resolvedDartImageTagFromUploadDescription', () {
    test('Given a binary upload JSON with x-goog-meta-dart-version '
        'when resolvedDartImageTagFromUploadDescription is called '
        'then the tag is returned', () {
      const json = '''
{"type":"binary","url":"https://example.com","httpMethod":"PUT","headers":{"x-goog-meta-dart-version":"3.10","host":"ignored"}}''';
      expect(resolveDartImageTagFromUploadDescription(json), '3.10');
    });

    test('Given JSON without dart-version header '
        'when resolvedDartImageTagFromUploadDescription is called '
        'then null is returned', () {
      const json = '{"type":"binary","url":"https://x","headers":{}}';
      expect(resolveDartImageTagFromUploadDescription(json), isNull);
    });

    test('Given invalid JSON '
        'when resolvedDartImageTagFromUploadDescription is called '
        'then null is returned', () {
      expect(resolveDartImageTagFromUploadDescription('{'), isNull);
    });
  });

  group('resolvedUploadIdFromUploadDescription', () {
    test('Given a binary upload JSON with x-goog-meta-upload-id '
        'when resolvedUploadIdFromUploadDescription is called '
        'then the upload ID is returned', () {
      const json = '''
{"type":"binary","url":"https://example.com","httpMethod":"PUT","headers":{"x-goog-meta-upload-id":"upload-00000008-0000-4000-8000-000000000000","host":"ignored"}}''';
      expect(
        resolveUploadIdFromUploadDescription(json),
        UuidValue.raw('00000008-0000-4000-8000-000000000000'),
      );
    });

    test('Given JSON without upload-id header '
        'when resolvedUploadIdFromUploadDescription is called '
        'then null is returned', () {
      const json = '{"type":"binary","url":"https://x","headers":{}}';
      expect(resolveUploadIdFromUploadDescription(json), isNull);
    });

    test('Given invalid JSON '
        'when resolvedUploadIdFromUploadDescription is called '
        'then null is returned', () {
      expect(resolveUploadIdFromUploadDescription('{'), isNull);
    });

    test('Given upload-id that does not have the correct prefix '
        'when resolvedUploadIdFromUploadDescription is called '
        'then null is returned', () {
      const json =
          '{"type":"binary","url":"https://example.com","httpMethod":"PUT","headers":{"x-goog-meta-upload-id":"00000008-0000-4000-8000-000000000000","host":"ignored"}}';
      expect(resolveUploadIdFromUploadDescription(json), isNull);
    });

    test('Given upload-id that is not a valid UUID '
        'when resolvedUploadIdFromUploadDescription is called '
        'then null is returned', () {
      const json =
          '{"type":"binary","url":"https://example.com","httpMethod":"PUT","headers":{"x-goog-meta-upload-id":"upload-not-a-uuid","host":"ignored"}}';
      expect(resolveUploadIdFromUploadDescription(json), isNull);
    });
  });
}

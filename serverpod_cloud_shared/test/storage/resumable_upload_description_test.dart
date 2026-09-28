import 'dart:convert';

import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  const sessionUrl =
      'https://storage.googleapis.com/upload/storage/v1/b/bucket/o'
      '?uploadType=resumable&name=capsule%2Fupload.zip&upload_id=abc';

  group('Given a resumable upload description', () {
    final description = ResumableUploadDescription(
      url: Uri.parse(sessionUrl),
      metadata: const {'upload-id': 'upload-1'},
    );

    test('when encoding then it has the type, the session url '
        'and the metadata', () {
      final map = jsonDecode(description.encode()) as Map<String, dynamic>;

      expect(map, {
        'type': 'resumable',
        'url': sessionUrl,
        'metadata': {'upload-id': 'upload-1'},
      });
    });

    test('when parsing the encoded form then the url and metadata '
        'round-trip', () {
      final parsed = ResumableUploadDescription.parse(description.encode());

      expect(parsed.url, description.url);
      expect(parsed.metadata, description.metadata);
    });

    test('when parsing without metadata then the metadata is empty', () {
      final parsed = ResumableUploadDescription.parse(
        jsonEncode({'type': 'resumable', 'url': sessionUrl}),
      );

      expect(parsed.metadata, isEmpty);
    });

    test('when checking the encoded form then it is resumable', () {
      expect(
        ResumableUploadDescription.isResumable(description.encode()),
        isTrue,
      );
    });
  });

  group('Given other descriptions', () {
    test('when checking a binary description then it is not resumable', () {
      expect(
        ResumableUploadDescription.isResumable(
          jsonEncode({'type': 'binary', 'url': sessionUrl}),
        ),
        isFalse,
      );
    });

    test('when checking non-JSON then it is not resumable', () {
      expect(ResumableUploadDescription.isResumable('not json'), isFalse);
    });

    test(
      'when parsing a binary description then a FormatException is thrown',
      () {
        expect(
          () => ResumableUploadDescription.parse(
            jsonEncode({'type': 'binary', 'url': sessionUrl}),
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('when parsing without a url then a FormatException is thrown', () {
      expect(
        () =>
            ResumableUploadDescription.parse(jsonEncode({'type': 'resumable'})),
        throwsA(isA<FormatException>()),
      );
    });

    test('when parsing a relative url then a FormatException is thrown', () {
      expect(
        () => ResumableUploadDescription.parse(
          jsonEncode({'type': 'resumable', 'url': '/session'}),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

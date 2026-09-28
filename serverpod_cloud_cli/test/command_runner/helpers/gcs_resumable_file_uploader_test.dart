import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/gcs_resumable_file_uploader.dart';
import 'package:test/test.dart';

const _chunkSize = GcsResumableFileUploader.chunkSizeUnit;

/// A request the fake storage received.
class _ReceivedRequest {
  final String method;
  final String? contentRange;
  final int bodyLength;
  final Map<String, String> headers;

  _ReceivedRequest({
    required this.method,
    required this.contentRange,
    required this.bodyLength,
    required this.headers,
  });
}

/// Fake GCS resumable upload session: `PUT /session` takes chunks and
/// answers 308 until the last byte, and a `bytes */total` query reports the
/// persisted range.
class _FakeResumableStorage {
  late final HttpServer _server;
  final List<_ReceivedRequest> requests = [];
  final BytesBuilder _persisted = BytesBuilder();
  Uint8List? finalizedObject;

  int _chunkRequests = 0;

  /// Leaves a chunk request unread and unanswered.
  bool neverReadChunkBody = false;

  /// Reads a chunk request fully and never answers it.
  bool neverAnswerChunk = false;

  /// Drops the connection on this chunk request (1-based) after persisting
  /// [persistBytesBeforeDrop] of it.
  int? dropConnectionOnChunk;
  int persistBytesBeforeDrop = 0;

  /// Answers this status on chunk requests instead of storing them.
  int? failChunksWithStatus;

  /// Limits [failChunksWithStatus] to the first N chunk requests; 0 is all.
  int failChunksTimes = 0;

  bool neverReportPersisted = false;

  Uri get sessionUri => Uri.parse('http://localhost:${_server.port}/session');

  String get description =>
      jsonEncode({'url': sessionUri.toString(), 'type': 'resumable'});

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> stop() => _server.close(force: true);

  Future<void> _handle(final HttpRequest request) async {
    if (request.uri.path == '/session' && request.method == 'PUT') {
      return _handleSession(request);
    }
    await request.drain<void>();
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  Future<void> _handleSession(final HttpRequest request) async {
    final contentRange = request.headers.value('content-range') ?? '';
    final total = int.parse(contentRange.split('/').last);

    if (contentRange.startsWith('bytes */')) {
      await request.drain<void>();
      _record(request, 0);
      return _respondWithStatus(request);
    }

    _chunkRequests++;
    if (neverReadChunkBody) return;
    final range = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(contentRange);
    if (range == null) {
      await request.drain<void>();
      _record(request, 0);
      return _respond(request, HttpStatus.badRequest);
    }
    final start = int.parse(range.group(1)!);

    if (_chunkRequests == dropConnectionOnChunk) {
      final body = await _readBody(request);
      _record(request, body.length);
      _persisted.add(body.sublist(0, persistBytesBeforeDrop));
      final socket = await request.response.detachSocket();
      socket.destroy();
      return;
    }

    final failStatus = failChunksWithStatus;
    if (failStatus != null &&
        (failChunksTimes == 0 || _chunkRequests <= failChunksTimes)) {
      await request.drain<void>();
      _record(request, 0);
      return _respond(request, failStatus);
    }

    if (start != _persisted.length) {
      await request.drain<void>();
      _record(request, 0);
      return _respond(request, HttpStatus.badRequest);
    }

    final body = await _readBody(request);
    _record(request, body.length);
    if (neverAnswerChunk) return;
    if (neverReportPersisted) {
      return _respond(request, 308);
    }
    _persisted.add(body);
    if (_persisted.length == total) {
      finalizedObject = _persisted.toBytes();
      return _respond(request, HttpStatus.ok);
    }
    return _respondWithStatus(request);
  }

  Future<void> _respondWithStatus(final HttpRequest request) {
    if (finalizedObject != null) {
      return _respond(request, HttpStatus.ok);
    }
    if (_persisted.length > 0) {
      request.response.headers.set('range', 'bytes=0-${_persisted.length - 1}');
    }
    return _respond(request, 308);
  }

  Future<void> _respond(final HttpRequest request, final int status) {
    request.response.statusCode = status;
    return request.response.close();
  }

  void _record(final HttpRequest request, final int bodyLength) {
    final headers = <String, String>{};
    request.headers.forEach((final name, final values) {
      headers[name] = values.join(',');
    });
    requests.add(
      _ReceivedRequest(
        method: request.method,
        contentRange: request.headers.value('content-range'),
        bodyLength: bodyLength,
        headers: headers,
      ),
    );
  }

  static Future<Uint8List> _readBody(final HttpRequest request) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in request) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }
}

Uint8List _randomBytes(final int length) {
  final random = Random(42);
  return Uint8List.fromList(
    List.generate(length, (final _) => random.nextInt(256)),
  );
}

Iterable<_ReceivedRequest> _chunkRequests(final List<_ReceivedRequest> all) =>
    all.where((final r) => !r.contentRange!.startsWith('bytes */'));

void main() {
  late _FakeResumableStorage storage;

  setUp(() async {
    storage = _FakeResumableStorage();
    await storage.start();
  });

  tearDown(() => storage.stop());

  GcsResumableFileUploader uploader({
    final int maxRetries = GcsResumableFileUploader.defaultMaxRetries,
    final Duration? timeout,
    final int chunkSize = _chunkSize,
  }) {
    return GcsResumableFileUploader(
      storage.description,
      chunkSize: chunkSize,
      maxRetries: maxRetries,
      retryDelay: (final _) => Duration.zero,
      timeout: timeout,
    );
  }

  group('Given a resumable upload description', () {
    test('when the chunk size is not a multiple of 256 KiB '
        'then an ArgumentError is thrown', () {
      expect(
        () => GcsResumableFileUploader(storage.description, chunkSize: 1000),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('when the description is binary then a FormatException is thrown', () {
      expect(
        () => GcsResumableFileUploader(
          jsonEncode({'url': 'http://localhost/x', 'type': 'binary'}),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    group('when uploading a file that spans three chunks', () {
      final bytes = _randomBytes(_chunkSize * 2 + _chunkSize ~/ 2);
      final progress = <(int, int)>[];
      late bool result;

      setUp(() async {
        progress.clear();
        result = await uploader().upload(
          Stream.value(bytes),
          bytes.length,
          onProgress: (final sent, final total) => progress.add((sent, total)),
        );
      });

      test('then the upload succeeds', () {
        expect(result, isTrue);
      });

      test('then the storage holds the exact bytes', () {
        expect(storage.finalizedObject, equals(bytes));
      });

      test('then each chunk is sent to the session in order', () {
        expect(storage.requests.map((final r) => (r.method, r.contentRange)), [
          ('PUT', 'bytes 0-${_chunkSize - 1}/${bytes.length}'),
          ('PUT', 'bytes $_chunkSize-${_chunkSize * 2 - 1}/${bytes.length}'),
          (
            'PUT',
            'bytes ${_chunkSize * 2}-${bytes.length - 1}/${bytes.length}',
          ),
        ]);
      });

      test('then each chunk declares its length', () {
        expect(storage.requests.map((final r) => r.headers['content-length']), [
          '$_chunkSize',
          '$_chunkSize',
          '${_chunkSize ~/ 2}',
        ]);
      });

      test('then progress ends at the full size', () {
        expect(progress.last, (bytes.length, bytes.length));
        expect(progress.map((final p) => p.$2).toSet(), {bytes.length});
      });
    });

    group('when the connection drops during the second chunk '
        'after part of it was persisted', () {
      final bytes = _randomBytes(_chunkSize * 3);
      late bool result;

      setUp(() async {
        storage.dropConnectionOnChunk = 2;
        storage.persistBytesBeforeDrop = _chunkSize ~/ 2;
        result = await uploader().upload(Stream.value(bytes), bytes.length);
      });

      test('then the upload still succeeds with the exact bytes', () {
        expect(result, isTrue);
        expect(storage.finalizedObject, equals(bytes));
      });

      test(
        'then the persisted offset is queried and the upload resumes from it',
        () {
          final afterDrop = storage.requests.skip(2).toList();
          expect(afterDrop.first.contentRange, 'bytes */${bytes.length}');
          expect(
            afterDrop[1].contentRange,
            'bytes ${_chunkSize + _chunkSize ~/ 2}-'
            '${_chunkSize * 2 + _chunkSize ~/ 2 - 1}/${bytes.length}',
          );
        },
      );
    });

    group('when the storage answers 503 to the first two chunk requests', () {
      final bytes = _randomBytes(_chunkSize);
      late bool result;

      setUp(() async {
        storage.failChunksWithStatus = 503;
        storage.failChunksTimes = 2;
        result = await uploader().upload(Stream.value(bytes), bytes.length);
      });

      test('then the upload succeeds with the exact bytes', () {
        expect(result, isTrue);
        expect(storage.finalizedObject, equals(bytes));
      });

      test('then the chunk is sent three times', () {
        expect(_chunkRequests(storage.requests).length, 3);
      });
    });

    group('when the storage answers 400 to a chunk request', () {
      final bytes = _randomBytes(_chunkSize);

      setUp(() {
        storage.failChunksWithStatus = 400;
      });

      test('then the DioException is thrown without a retry', () async {
        await expectLater(
          uploader().upload(Stream.value(bytes), bytes.length),
          throwsA(
            isA<DioException>().having(
              (final e) => e.response?.statusCode,
              'statusCode',
              400,
            ),
          ),
        );
        expect(_chunkRequests(storage.requests).length, 1);
      });
    });

    group('when every chunk request keeps failing', () {
      final bytes = _randomBytes(_chunkSize);

      setUp(() {
        storage.failChunksWithStatus = 503;
      });

      test(
        'then the last error is thrown after the retries are spent',
        () async {
          await expectLater(
            uploader(maxRetries: 2).upload(Stream.value(bytes), bytes.length),
            throwsA(
              isA<DioException>().having(
                (final e) => e.response?.statusCode,
                'statusCode',
                503,
              ),
            ),
          );
          expect(_chunkRequests(storage.requests).length, 3);
        },
      );
    });

    group('when the storage acknowledges chunks without persisting them', () {
      final bytes = _randomBytes(_chunkSize * 2);

      setUp(() {
        storage.neverReportPersisted = true;
      });

      test('then a ResumableUploadException is thrown '
          'after the retries are spent', () async {
        await expectLater(
          uploader(maxRetries: 1).upload(Stream.value(bytes), bytes.length),
          throwsA(isA<ResumableUploadException>()),
        );
        expect(_chunkRequests(storage.requests).length, 2);
      });
    });

    group('when the storage stops reading a chunk', () {
      const chunkSize = 16 * 1024 * 1024;
      final bytes = Uint8List(chunkSize);

      setUp(() {
        storage.neverReadChunkBody = true;
      });

      test('then a sendTimeout DioException is thrown '
          'after the timeout without progress', () async {
        await expectLater(
          uploader(
            maxRetries: 0,
            chunkSize: chunkSize,
            timeout: const Duration(milliseconds: 300),
          ).upload(Stream.value(bytes), bytes.length),
          throwsA(
            isA<DioException>().having(
              (final e) => e.type,
              'type',
              DioExceptionType.sendTimeout,
            ),
          ),
        );
      });
    });

    group('when the storage never answers a chunk', () {
      setUp(() {
        storage.neverAnswerChunk = true;
      });

      test(
        'then a receiveTimeout DioException is thrown after the timeout',
        () async {
          await expectLater(
            uploader(
              maxRetries: 0,
              timeout: const Duration(milliseconds: 300),
            ).upload(Stream.value(Uint8List(10)), 10),
            throwsA(
              isA<DioException>().having(
                (final e) => e.type,
                'type',
                DioExceptionType.receiveTimeout,
              ),
            ),
          );
        },
      );
    });

    test(
      'when the stream length does not match then an ArgumentError is thrown',
      () async {
        await expectLater(
          uploader().upload(Stream.value(Uint8List(10)), 11),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'when uploading twice with one uploader then a StateError is thrown',
      () async {
        final instance = uploader();
        await instance.upload(Stream.value(Uint8List(10)), 10);
        await expectLater(
          instance.upload(Stream.value(Uint8List(10)), 10),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}

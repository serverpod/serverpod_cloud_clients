import 'dart:async';
import 'dart:io' show HttpException, SocketException;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';

/// The storage broke the resumable upload protocol.
final class ResumableUploadException implements Exception {
  final String message;

  ResumableUploadException(this.message);

  @override
  String toString() => 'ResumableUploadException: $message';
}

/// Uploads a file to a Google Cloud Storage resumable upload session in
/// chunks of [chunkSize] bytes. A chunk that fails with a transient error is
/// resumed from the offset the storage reports, up to [maxRetries] attempts
/// without progress. A request with no send progress for [timeout] fails with
/// [DioExceptionType.sendTimeout].
final class GcsResumableFileUploader implements FileUploaderClient {
  /// Default chunk size.
  static const int defaultChunkSize = 8 * 1024 * 1024;

  /// GCS requires chunk sizes in multiples of 256 KiB.
  static const int chunkSizeUnit = 256 * 1024;

  /// Default consecutive failed attempts before giving up.
  static const int defaultMaxRetries = 8;

  /// Socket write size, so progress and the stall timer follow the wire.
  static const int _sendSliceSize = 64 * 1024;

  static const Duration _maxRetryDelay = Duration(seconds: 32);
  static const int _resumeIncomplete = 308;

  final Dio _dio;
  final Duration? _stallTimeout;
  final int _chunkSize;
  final int _maxRetries;
  final Duration Function(int attempt) _retryDelay;
  final Uri _sessionUri;
  bool _attemptedUpload = false;

  /// [timeout] bounds connecting, the response wait, and time without send
  /// progress. [chunkSize] must be a multiple of [chunkSizeUnit].
  ///
  /// Throws [FormatException] if [uploadDescription] is not a resumable
  /// description.
  GcsResumableFileUploader(
    final String uploadDescription, {
    final Dio? dio,
    final Duration? timeout,
    final int chunkSize = defaultChunkSize,
    final int maxRetries = defaultMaxRetries,
    final Duration Function(int attempt)? retryDelay,
  }) : _sessionUri = ResumableUploadDescription.parse(uploadDescription).url,
       _stallTimeout = timeout,
       _chunkSize = chunkSize,
       _maxRetries = maxRetries,
       _retryDelay = retryDelay ?? _exponentialDelay,
       _dio =
           dio ??
           Dio(BaseOptions(connectTimeout: timeout, receiveTimeout: timeout)) {
    if (chunkSize <= 0 || chunkSize % chunkSizeUnit != 0) {
      throw ArgumentError.value(
        chunkSize,
        'chunkSize',
        'must be a positive multiple of $chunkSizeUnit bytes',
      );
    }
    if (maxRetries < 0) {
      throw ArgumentError.value(
        maxRetries,
        'maxRetries',
        'must not be negative',
      );
    }
  }

  static Duration _exponentialDelay(final int attempt) {
    final delay = Duration(seconds: math.pow(2, attempt - 1).toInt());
    return delay > _maxRetryDelay ? _maxRetryDelay : delay;
  }

  @override
  Future<bool> uploadByteData(
    final ByteData byteData, {
    final UploadProgressCallback? onProgress,
  }) {
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return upload(Stream.value(bytes), bytes.length, onProgress: onProgress);
  }

  /// Reads [stream] into memory, then uploads it. Returns true when the
  /// storage finalized the file.
  ///
  /// Throws [DioException] on a transfer failure that outlasts the retries,
  /// [ResumableUploadException] when the storage keeps answering without
  /// persisting or breaks the protocol.
  @override
  Future<bool> upload(
    final Stream<List<int>> stream,
    final int length, {
    final UploadProgressCallback? onProgress,
  }) async {
    if (_attemptedUpload) {
      throw StateError('Data has already been uploaded using this uploader.');
    }
    _attemptedUpload = true;

    final bytes = await _collectBytes(stream);
    if (bytes.length != length) {
      throw ArgumentError.value(
        length,
        'length',
        'does not match the ${bytes.length} bytes read from the stream',
      );
    }
    final total = bytes.length;
    final sessionUri = _sessionUri;

    var offset = 0;
    var failures = 0;
    var resumeFromStatus = false;
    while (true) {
      try {
        if (resumeFromStatus) {
          final status = await _queryStatus(sessionUri, total);
          if (status.completed) {
            onProgress?.call(total, total);
            return true;
          }
          if (status.persistedBytes > offset) {
            failures = 0;
          }
          offset = status.persistedBytes;
          resumeFromStatus = false;
        }

        final end = math.min(offset + _chunkSize, total);
        final result = await _sendChunk(
          sessionUri,
          bytes,
          start: offset,
          end: end,
          total: total,
          onProgress: onProgress,
        );
        if (result.completed) {
          onProgress?.call(total, total);
          return true;
        }
        if (result.persistedBytes <= offset) {
          if (failures >= _maxRetries) {
            throw ResumableUploadException(
              'The storage did not persist the upload chunk at offset $offset.',
            );
          }
          failures++;
          resumeFromStatus = true;
          await Future<void>.delayed(_retryDelay(failures));
          continue;
        }
        offset = result.persistedBytes;
        failures = 0;
      } on DioException catch (e) {
        if (!_isTransient(e) || failures >= _maxRetries) {
          rethrow;
        }
        failures++;
        resumeFromStatus = true;
        await Future<void>.delayed(_retryDelay(failures));
      }
    }
  }

  Future<_ChunkResult> _sendChunk(
    final Uri sessionUri,
    final Uint8List bytes, {
    required final int start,
    required final int end,
    required final int total,
    required final UploadProgressCallback? onProgress,
  }) async {
    final chunk = Uint8List.sublistView(bytes, start, end);
    final response = await _send(
      (final cancelToken, final onSendProgress) => _dio.putUri(
        sessionUri,
        data: Stream.fromIterable(_slices(chunk)),
        options: Options(
          headers: {
            'content-length': chunk.length.toString(),
            'content-range': _contentRange(start, end, total),
          },
          followRedirects: false,
          validateStatus: _isChunkStatus,
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      totalBytes: chunk.length,
      onProgress: (final sent) => onProgress?.call(start + sent, total),
    );
    return _ChunkResult.fromResponse(response);
  }

  Future<_ChunkResult> _queryStatus(
    final Uri sessionUri,
    final int total,
  ) async {
    final response = await _send(
      (final cancelToken, final onSendProgress) => _dio.putUri(
        sessionUri,
        data: Uint8List(0),
        options: Options(
          headers: {'content-range': 'bytes */$total'},
          followRedirects: false,
          validateStatus: _isChunkStatus,
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      totalBytes: 0,
      onProgress: (_) {},
    );
    return _ChunkResult.fromResponse(response);
  }

  static String _contentRange(final int start, final int end, final int total) {
    if (total == 0) {
      return 'bytes */0';
    }
    return 'bytes $start-${end - 1}/$total';
  }

  static bool _isChunkStatus(final int? status) {
    if (status == null) return false;
    return status == _resumeIncomplete || (status >= 200 && status < 300);
  }

  /// Runs [request], cancelling it when no send progress arrives within the
  /// stall timeout.
  Future<Response<T>> _send<T>(
    final Future<Response<T>> Function(
      CancelToken cancelToken,
      ProgressCallback onSendProgress,
    )
    request, {
    required final int totalBytes,
    required final void Function(int sentBytes) onProgress,
  }) async {
    final stallTimeout = _stallTimeout;
    final cancelToken = CancelToken();
    Timer? stallTimer;

    void restartStallTimer() {
      stallTimer?.cancel();
      if (stallTimeout == null) return;
      stallTimer = Timer(stallTimeout, cancelToken.cancel);
    }

    if (totalBytes > 0) {
      restartStallTimer();
    }
    try {
      return await request(cancelToken, (final sent, _) {
        if (sent >= totalBytes) {
          stallTimer?.cancel();
        } else {
          restartStallTimer();
        }
        onProgress(sent);
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel && stallTimeout != null) {
        throw DioException.sendTimeout(
          timeout: stallTimeout,
          requestOptions: e.requestOptions,
        );
      }
      rethrow;
    } finally {
      stallTimer?.cancel();
    }
  }

  /// A dropped connection is [DioExceptionType.unknown] with a socket or
  /// HTTP error.
  static bool _isTransient(final DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
        408 || 429 => true,
        final status? when status >= 500 => true,
        _ => false,
      },
      DioExceptionType.unknown =>
        e.error is SocketException || e.error is HttpException,
      _ => false,
    };
  }

  static Iterable<Uint8List> _slices(final Uint8List bytes) sync* {
    for (var start = 0; start < bytes.length; start += _sendSliceSize) {
      final end = math.min(start + _sendSliceSize, bytes.length);
      yield Uint8List.sublistView(bytes, start, end);
    }
  }

  static Future<Uint8List> _collectBytes(final Stream<List<int>> stream) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }
}

/// Outcome of a chunk request or status query.
class _ChunkResult {
  final bool completed;

  /// Bytes the storage has persisted.
  final int persistedBytes;

  const _ChunkResult({required this.completed, required this.persistedBytes});

  factory _ChunkResult.fromResponse(final Response response) {
    final status = response.statusCode;
    if (status != null && status >= 200 && status < 300) {
      return const _ChunkResult(completed: true, persistedBytes: 0);
    }
    return _ChunkResult(
      completed: false,
      persistedBytes: _persistedBytesFromRange(response.headers.value('range')),
    );
  }

  /// Parses `Range: bytes=0-<last>`; absent or malformed means nothing
  /// persisted.
  static int _persistedBytesFromRange(final String? range) {
    if (range == null) return 0;
    final match = RegExp(r'^bytes=0-(\d+)$').firstMatch(range.trim());
    final last = int.tryParse(match?.group(1) ?? '');
    if (last == null) return 0;
    return last + 1;
  }
}

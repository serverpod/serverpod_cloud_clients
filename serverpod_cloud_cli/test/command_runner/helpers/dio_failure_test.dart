import 'package:dio/dio.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/dio_failure.dart';
import 'package:test/test.dart';

void main() {
  DioException dioException(final DioExceptionType type) {
    return DioException(requestOptions: RequestOptions(), type: type);
  }

  group('Given a timeout or connection failure', () {
    for (final (type, message) in [
      (DioExceptionType.connectionTimeout, 'Connection Timeout.'),
      (DioExceptionType.sendTimeout, 'Send Timeout.'),
      (DioExceptionType.receiveTimeout, 'Receive Timeout.'),
      (DioExceptionType.connectionError, 'Connection Error.'),
    ]) {
      group('when translating $type', () {
        test('then the error names the failure', () {
          final failure = failureFromDioException(
            dioException(type),
            action: 'upload the file',
          );

          expect(failure.errors.single, startsWith(message));
        });

        test('then the hint suggests a longer timeout', () {
          final failure = failureFromDioException(
            dioException(type),
            action: 'upload the file',
          );

          expect(
            failure.hint,
            'Try increasing the timeout with the --timeout option.',
          );
        });
      });
    }
  });

  group('Given any other transfer failure', () {
    test('when translating then the error names the action', () {
      final failure = failureFromDioException(
        dioException(DioExceptionType.badResponse),
        action: 'download the file',
      );

      expect(failure.errors.single, 'Failed to download the file.');
    });

    test('when translating then the exception is nested', () {
      final exception = dioException(DioExceptionType.badResponse);

      final failure = failureFromDioException(
        exception,
        action: 'download the file',
      );

      expect(failure.nestedException, same(exception));
    });
  });
}

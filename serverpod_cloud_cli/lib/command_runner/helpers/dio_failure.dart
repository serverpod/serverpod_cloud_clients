import 'package:dio/dio.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// Translates a [DioException] from an HTTP transfer into a [FailureException].
///
/// [action] names what was attempted, for example `upload the file`.
FailureException failureFromDioException(
  final DioException e, {
  required final String action,
}) {
  const timeoutHint = 'Try increasing the timeout with the --timeout option.';

  return switch (e.type) {
    DioExceptionType.connectionTimeout => FailureException(
      error:
          'Connection Timeout. '
          'Please check your internet connection and try again.',
      hint: timeoutHint,
    ),
    DioExceptionType.sendTimeout => FailureException(
      error:
          'Send Timeout. '
          'Please check your internet connection and try again.',
      hint: timeoutHint,
    ),
    DioExceptionType.receiveTimeout => FailureException(
      error:
          'Receive Timeout. '
          'Please check your internet connection and try again.',
      hint: timeoutHint,
    ),
    DioExceptionType.connectionError => FailureException(
      error:
          'Connection Error. '
          'Please check your internet connection and try again.',
      hint: timeoutHint,
    ),
    _ => FailureException(error: 'Failed to $action.', nestedException: e),
  };
}

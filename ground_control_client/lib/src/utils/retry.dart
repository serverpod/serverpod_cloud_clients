/// Executes a function [fn] recursively with retry logic.
///
/// If [shouldRetryOnException] is provided, it will be called with the exception
/// and if it returns true, the function will be retried. If not provided, it will
/// retry on all exceptions.
///
/// If [retryCount] is provided, it will be used as the initial retry count.
/// If not provided, it will start at 0.
///
/// If [maxRetries] is provided, it will be used as the maximum number of retries.
/// If not provided, it will default to 2.
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  int retryCount = 0,
  int maxRetries = 2,
  bool Function(Object e)? shouldRetryOnException,
}) async {
  retryCount++;
  try {
    return await fn();
  } catch (e) {
    if (retryCount > maxRetries) {
      rethrow;
    }
    if (shouldRetryOnException?.call(e) ?? true) {
      return await withRetry(
        fn,
        retryCount: retryCount,
        maxRetries: maxRetries,
      );
    }
    rethrow;
  }
}

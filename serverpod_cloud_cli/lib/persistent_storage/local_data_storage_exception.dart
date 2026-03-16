/// Exception thrown when a local data storage operation fails.
class LocalDataStorageException implements Exception {
  final String message;
  final Object? error;

  LocalDataStorageException(this.message, [this.error]);

  @override
  String toString() =>
      'LocalDataStorageException: $message${error != null ? '\nError: $error' : ''}';
}

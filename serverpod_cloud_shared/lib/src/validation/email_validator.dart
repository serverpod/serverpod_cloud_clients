/// Validation of email addresses for Serverpod Cloud clients and APIs.
abstract final class EmailValidator {
  static final RegExp _whitespace = RegExp(r'\s');

  /// Whether [value] looks like an email after trimming surrounding whitespace.
  static bool looksValid(String value) {
    final trimmed = value.trim();
    final at = trimmed.indexOf('@');

    return at > 0 &&
        at == trimmed.lastIndexOf('@') &&
        at < trimmed.length - 1 &&
        !trimmed.contains(_whitespace);
  }
}

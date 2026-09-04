/// Validation of user-provided storage ids.
///
/// The server accepts any string as a storage id, so this is client-side
/// only. The function does not trim [value]: a caller that submits the
/// value verbatim (the CLI) rejects surrounding whitespace, and a caller
/// that submits a trimmed value (the console) passes that trimmed value in.
abstract final class StorageIdValidator {
  static const int maxLength = 63;

  static final RegExp _pattern = RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$');

  /// Returns null when [value] is a valid, unused storage id,
  /// otherwise the reason why it is not.
  static String? validate(String value, {Set<String> taken = const {}}) {
    if (value.trim().isEmpty) {
      return 'Enter a storage id.';
    }
    if (value.length > maxLength) {
      return 'A storage id can be at most $maxLength characters.';
    }
    if (!_pattern.hasMatch(value)) {
      return 'Use lowercase letters, digits and dashes, starting and ending '
          'with a letter or digit.';
    }
    if (taken.contains(value)) {
      return 'This project already has that storage id.';
    }

    return null;
  }

  /// Whether [value] is a valid, unused storage id.
  static bool isValid(String value, {Set<String> taken = const {}}) {
    return validate(value, taken: taken) == null;
  }
}

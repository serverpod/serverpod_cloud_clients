import 'dart:convert';

/// Reads `x-goog-meta-dart-version` from a Ground Control direct-upload JSON description.
String? resolvedDartImageTagFromUploadDescription(
  final String uploadDescription,
) {
  try {
    final decoded = jsonDecode(uploadDescription);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final headers = decoded['headers'];
    if (headers is! Map) {
      return null;
    }
    final value = headers['x-goog-meta-dart-version'];
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  } on FormatException {
    return null;
  }
}

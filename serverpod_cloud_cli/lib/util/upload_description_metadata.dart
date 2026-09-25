import 'dart:convert';

import 'package:uuid/uuid_value.dart';

/// Reads the object metadata [key] from a Ground Control upload JSON
/// description: the `metadata` map of a resumable description, or the
/// `x-goog-meta-` header of a binary one.
/// Returns null if the value is not found or not a non-empty string.
String? resolveMetadataFromUploadDescription(
  String uploadDescription,
  String key,
) {
  try {
    final decoded = jsonDecode(uploadDescription);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final metadata = decoded['metadata'];
    final headers = decoded['headers'];
    final value = metadata is Map
        ? metadata[key]
        : headers is Map
        ? headers['x-goog-meta-$key']
        : null;
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

/// Reads the `dart-version` metadata from a Ground Control upload JSON
/// description.
/// Returns null if the Dart image is not found.
String? resolveDartImageTagFromUploadDescription(String uploadDescription) {
  return resolveMetadataFromUploadDescription(
    uploadDescription,
    'dart-version',
  );
}

/// Reads the `upload-id` metadata from a Ground Control upload JSON
/// description and converts it to the proper UuidValue.
/// Returns null if the upload ID is not found or in an invalid format.
UuidValue? resolveUploadIdFromUploadDescription(String uploadDescription) {
  final uploadIdString = resolveMetadataFromUploadDescription(
    uploadDescription,
    'upload-id',
  );
  if (uploadIdString == null) {
    return null;
  }
  const uploadIdPrefix = 'upload-';
  if (!uploadIdString.startsWith(uploadIdPrefix)) {
    return null;
  }
  try {
    return UuidValue.withValidation(
      uploadIdString.substring(uploadIdPrefix.length),
    );
  } on FormatException {
    return null;
  }
}

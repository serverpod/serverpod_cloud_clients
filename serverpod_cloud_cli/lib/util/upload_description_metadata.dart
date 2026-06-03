import 'dart:convert';

import 'package:uuid/uuid_value.dart';

/// Reads a header value from a Ground Control direct-upload JSON description.
/// Returns null if the header is not found or in an invalid format.
String? resolveHeaderValueFromUploadDescription(
  final String uploadDescription,
  final String headerName,
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
    final value = headers[headerName];
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

/// Reads `x-goog-meta-dart-version` from a Ground Control direct-upload JSON
/// description.
/// Returns null if the Dart image is not found.
String? resolveDartImageTagFromUploadDescription(
  final String uploadDescription,
) {
  return resolveHeaderValueFromUploadDescription(
    uploadDescription,
    'x-goog-meta-dart-version',
  );
}

/// Reads `x-goog-meta-upload-id` from a Ground Control direct-upload JSON
/// description and converts it to the proper UuidValue.
/// Returns null if the upload ID is not found or in an invalid format.
UuidValue? resolveUploadIdFromUploadDescription(
  final String uploadDescription,
) {
  final uploadIdString = resolveHeaderValueFromUploadDescription(
    uploadDescription,
    'x-goog-meta-upload-id',
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

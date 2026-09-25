import 'dart:convert';

/// A Google Cloud Storage resumable upload session that a client sends a
/// file to, and the [metadata] the stored object gets. Encodes like a
/// Serverpod upload description with `type: resumable`.
final class ResumableUploadDescription {
  static const String type = 'resumable';

  final Uri url;
  final Map<String, String> metadata;

  const ResumableUploadDescription({
    required this.url,
    this.metadata = const {},
  });

  /// Whether [description] is a resumable upload description.
  static bool isResumable(String description) {
    try {
      final data = jsonDecode(description);
      return data is Map<String, dynamic> && data['type'] == type;
    } on FormatException {
      return false;
    }
  }

  /// Throws [FormatException] if [description] is not a resumable upload
  /// description with an absolute session url.
  factory ResumableUploadDescription.parse(String description) {
    final data = jsonDecode(description);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Upload description must be a JSON object');
    }
    if (data['type'] != type) {
      throw FormatException(
        'Upload description type must be $type, was ${data['type']}',
      );
    }
    final url = data['url'];
    final parsed = url is String ? Uri.tryParse(url) : null;
    if (parsed == null || !parsed.isAbsolute) {
      throw const FormatException(
        'Upload description must have an absolute session url',
      );
    }
    final rawMetadata = data['metadata'];
    return ResumableUploadDescription(
      url: parsed,
      metadata: {
        if (rawMetadata is Map)
          for (final MapEntry(:key, :value) in rawMetadata.entries)
            if (key is String && value is String) key: value,
      },
    );
  }

  Map<String, Object?> toJson() => {
    'url': url.toString(),
    'type': type,
    'metadata': metadata,
  };

  String encode() => jsonEncode(toJson());
}

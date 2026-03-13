import 'dart:io';

import 'package:path/path.dart' as p;

abstract final class ToolVersionsReader {
  static const _fileName = '.tool-versions';

  /// Reads the Dart SDK version from the `.tool-versions` file in [directory].
  ///
  /// The file uses the asdf format where each line is:
  /// `<tool-name> <version>`
  ///
  /// Returns the version string for `dart`, or `null` if the file does not
  /// exist, has no `dart` entry, or cannot be parsed.
  static String? readDartVersion(final Directory directory) {
    final file = File(p.join(directory.path, _fileName));
    if (!file.existsSync()) {
      return null;
    }

    final String content;
    try {
      content = file.readAsStringSync();
    } catch (_) {
      return null;
    }

    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#') || trimmed.isEmpty) continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[0] == 'dart') {
        final version = parts[1].trim();
        return version.isEmpty ? null : version;
      }
    }

    return null;
  }
}

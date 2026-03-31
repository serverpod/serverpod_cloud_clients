import 'dart:io';

import 'package:path/path.dart' as p;

abstract final class ToolVersionsIO {
  static const _fileName = '.tool-versions';

  /// Reads the Dart SDK version from the `.tool-versions` file in [directory].
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

  /// Updates the `dart` entry in the `.tool-versions` file in [directory] to
  /// [version], preserving all other tool entries.
  ///
  /// Does nothing if the file does not exist.
  static void writeDartVersion(
    final Directory directory,
    final String version,
  ) {
    final file = File(p.join(directory.path, _fileName));
    if (!file.existsSync()) return;

    final String content;
    try {
      content = file.readAsStringSync();
    } catch (_) {
      return;
    }

    final lines = content.split('\n');
    var found = false;
    final updated = lines.map((final line) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#') || trimmed.isEmpty) return line;
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[0] == 'dart') {
        found = true;
        return 'dart $version';
      }
      return line;
    }).toList();

    if (!found) {
      final insertAt = updated.isNotEmpty && updated.last.isEmpty
          ? updated.length - 1
          : updated.length;
      updated.insert(insertAt, 'dart $version');
    }

    file.writeAsStringSync(updated.join('\n'));
  }
}

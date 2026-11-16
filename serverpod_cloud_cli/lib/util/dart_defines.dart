import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// Reads the dart defines a Flutter app is built with: the compilation
/// declarations of `--dart-define` and `--dart-define-from-file`, read the
/// way Flutter reads them. The `.env` patterns are those of `DotEnvRegex`
/// in Flutter's `flutter_tools`.
abstract final class DartDefines {
  /// The dart define that Serverpod Cloud sets on every app build to the
  /// URL of the project's API server.
  static const serverUrlKey = 'SERVER_URL';

  /// Parses [define], a `KEY=VALUE` pair split at its first `=`.
  ///
  /// Throws [FormatException] if [define] has no `=` or an empty key.
  static MapEntry<String, String> parseDefine(String define) {
    final separator = define.indexOf('=');
    if (separator <= 0) {
      throw FormatException(
        'Invalid dart define "$define". Use the format KEY=VALUE.',
      );
    }
    return MapEntry(
      define.substring(0, separator),
      define.substring(separator + 1),
    );
  }

  /// Reads the dart defines in [file]. As in Flutter, the content decides
  /// the format, whatever the file is named: content that starts with `{`
  /// is a JSON object whose values are strings, numbers, or booleans. Any
  /// other content holds `.env` lines, `KEY=VALUE`, read as Flutter reads
  /// them; blank lines and lines that start with `#` are skipped.
  ///
  /// Throws [FailureException] if [file] cannot be read or is not in its
  /// format.
  static Map<String, String> readFile(File file) {
    final String content;
    try {
      content = file.readAsStringSync();
    } on FileSystemException catch (e) {
      throw FailureException(
        error:
            'Failed to read the dart defines file ${file.path}: '
            '${e.osError?.message ?? e.message}',
      );
    }
    return content.trim().startsWith('{')
        ? _parseJson(content, path: file.path)
        : _parseEnv(content, path: file.path);
  }

  /// The dart defines of [files], read in order, followed by [defines],
  /// each a `KEY=VALUE` pair. A later value of a key replaces an earlier
  /// one.
  ///
  /// Throws [FailureException] if a file cannot be read or is not in its
  /// format, or if a define is not a `KEY=VALUE` pair.
  static Map<String, String> collect({
    required List<File> files,
    required List<String> defines,
  }) {
    final dartDefines = <String, String>{
      for (final file in files) ...readFile(file),
    };
    for (final define in defines) {
      try {
        final MapEntry(:key, :value) = parseDefine(define);
        dartDefines[key] = value;
      } on FormatException catch (e) {
        throw FailureException(error: e.message);
      }
    }
    return dartDefines;
  }

  static Map<String, String> _parseJson(
    String content, {
    required String path,
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (e) {
      throw FailureException(
        error: 'The dart defines file $path is not valid JSON: ${e.message}',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw FailureException(
        error: 'The dart defines file $path must hold a JSON object.',
      );
    }
    return {
      for (final MapEntry(:key, :value) in decoded.entries)
        key: switch (value) {
          final String text => text,
          num() || bool() => value.toString(),
          _ => throw FailureException(
            error:
                'The dart define "$key" in $path must be a string, '
                'a number, or a boolean.',
          ),
        },
    };
  }

  /// A line that opens a multi-line value, which Flutter does not support.
  static final _multiLineBlock = RegExp(
    r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*"""\s*(.*)$',
  );

  /// A `KEY=VALUE` line, with the key and the raw value.
  static final _keyValue = RegExp(
    r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*(.*)?$',
  );

  /// Values wrapped in double, single, or back quotes, with an optional
  /// trailing comment.
  static final _quotedValues = [
    RegExp(r'^"(.*)"\s*(\#\s*.*)?$'),
    RegExp(r"^'(.*)'\s*(\#\s*.*)?$"),
    RegExp(r'^`(.*)`\s*(\#\s*.*)?$'),
  ];

  /// An unquoted value, which ends at the first whitespace or `#`, with an
  /// optional trailing comment.
  static final _unquotedValue = RegExp(r'^([^#\n\s]*)\s*(?:\s*#\s*(.*))?$');

  static Map<String, String> _parseEnv(String content, {required String path}) {
    final dartDefines = <String, String>{};
    for (final (index, rawLine) in content.split('\n').indexed) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      if (_multiLineBlock.hasMatch(line)) {
        throw FailureException(
          error:
              'Line ${index + 1} in the dart defines file $path opens a '
              'multi-line value, which is not supported.',
        );
      }
      final match = _keyValue.firstMatch(line);
      final key = match?.group(1);
      if (match == null || key == null) {
        throw FailureException(
          error:
              'Invalid line ${index + 1} in the dart defines file $path. '
              'Use the format KEY=VALUE, with a key of letters, digits and '
              'underscores that does not start with a digit.',
        );
      }
      dartDefines[key] = _envValue(match.group(2) ?? '');
    }
    return dartDefines;
  }

  /// The value of [rawValue], without its quotes and trailing comment.
  static String _envValue(String rawValue) {
    for (final pattern in [..._quotedValues, _unquotedValue]) {
      final value = pattern.firstMatch(rawValue)?.group(1);
      if (value != null) {
        return value;
      }
    }
    return rawValue;
  }
}

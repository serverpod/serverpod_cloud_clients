import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

/// Starts the `flutter` tool with [arguments] in [workingDirectory].
typedef FlutterProcessStarter =
    Future<Process> Function(List<String> arguments, String workingDirectory);

/// Reads the version of the Flutter SDK installed on this machine, as run
/// in [appDirectory], or returns null if it cannot be read. The reason is
/// logged to [logger].
typedef LocalFlutterVersionReader =
    Future<String?> Function(Directory appDirectory, CommandLogger logger);

/// Reads the version of the Flutter SDK installed on this machine.
abstract final class LocalFlutterSdk {
  /// How long `flutter --version --machine` may run before it is given up.
  static const _defaultTimeout = Duration(seconds: 30);

  /// What happens when the version cannot be read, and how to choose one.
  static const _fallbackHint =
      'The builds use the latest stable release. Request a version with '
      '--flutter-version, or pin one in environment.flutter of the '
      "app's pubspec.yaml.";

  /// How long the output may stay open after the tool has exited, as when
  /// a process the tool started still holds it.
  static const _outputCloseTimeout = Duration(seconds: 1);

  /// Runs `flutter --version --machine` in [workingDirectory] and returns
  /// the `frameworkVersion` it reports, such as `3.38.4`.
  ///
  /// Running it in [workingDirectory] makes version managers that put a
  /// `flutter` shim on the path, such as asdf, mise or puro, report the SDK
  /// they pick for that directory. Notices that the tool or such a wrapper
  /// prints around the JSON output are ignored.
  ///
  /// Returns null when the `flutter` executable is not found, when it exits
  /// with an error, when its output reports no `frameworkVersion`, or when
  /// it does not exit within [timeout], as when another Flutter command
  /// holds the tool's startup lock. A tool that does not exit in time is
  /// stopped. The reason is logged to [logger]: as a debug message when the
  /// executable is not found, else as a warning.
  static Future<String?> readFrameworkVersion(
    Directory workingDirectory, {
    required CommandLogger logger,
    Duration timeout = _defaultTimeout,
    FlutterProcessStarter startProcess = _startFlutter,
  }) async {
    final Process process;
    try {
      process = await startProcess(const [
        '--version',
        '--machine',
      ], workingDirectory.path);
    } on ProcessException {
      logger.debug(
        'Skipping the local Flutter version: '
        'the `flutter` executable was not found.',
      );
      return null;
    }

    final output = StringBuffer();
    final outputClosed = Completer<void>();
    final stdoutSubscription = process.stdout
        .transform(systemEncoding.decoder)
        .listen(
          output.write,
          onError: (Object _) {},
          onDone: outputClosed.complete,
        );
    final stderrSubscription = process.stderr.listen(
      (_) {},
      onError: (Object _) {},
    );

    final int exitCode;
    try {
      exitCode = await process.exitCode.timeout(timeout);
      await outputClosed.future.timeout(_outputCloseTimeout, onTimeout: () {});
    } on TimeoutException {
      process.kill();
      logger.warning(
        'Could not read the version of the local Flutter SDK: '
        '"flutter --version" timed out after ${timeout.inSeconds}s. '
        'Another Flutter command may be running.',
        hint: _fallbackHint,
      );
      return null;
    } finally {
      await stdoutSubscription.cancel();
      await stderrSubscription.cancel();
    }

    if (exitCode != 0) {
      logger.warning(
        'Could not read the version of the local Flutter SDK: '
        '"flutter --version" exited with code $exitCode.',
        hint: _fallbackHint,
      );
      return null;
    }

    final version = _frameworkVersionIn(output.toString());
    if (version == null) {
      logger.warning(
        'Could not read the version of the local Flutter SDK: '
        '"flutter --version" reported no framework version.',
        hint: _fallbackHint,
      );
    }
    return version;
  }

  /// The `frameworkVersion` reported in [output], the output of
  /// `--version --machine`, or null if it reports none.
  ///
  /// A notice printed around the JSON can be JSON itself, so every run of
  /// whole lines that could be a JSON object is decoded, and the first one
  /// that reports a `frameworkVersion` wins.
  static String? _frameworkVersionIn(String output) {
    final lines = const LineSplitter().convert(output);
    for (var start = 0; start < lines.length; start++) {
      if (lines[start].trimLeft().startsWith('{')) {
        for (var end = start; end < lines.length; end++) {
          final version = _frameworkVersionInJson(
            lines.sublist(start, end + 1),
          );
          if (version != null) return version;
        }
      }
    }
    return null;
  }

  /// The non-empty `frameworkVersion` of [lines] when they are one JSON
  /// object that reports one, or else null.
  static String? _frameworkVersionInJson(List<String> lines) {
    if (!lines.last.trimRight().endsWith('}')) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(lines.join('\n'));
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    final frameworkVersion = decoded['frameworkVersion'];
    if (frameworkVersion is! String) return null;
    final trimmed = frameworkVersion.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

Future<Process> _startFlutter(List<String> arguments, String workingDirectory) {
  return Process.start(
    'flutter',
    arguments,
    workingDirectory: workingDirectory,
    runInShell: Platform.isWindows,
  );
}

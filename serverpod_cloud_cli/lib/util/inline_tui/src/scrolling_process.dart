import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'inline_terminal.dart';
import 'scrolling_section.dart';

/// The outcome of running a process inside a [ScrollingSection].
///
/// After awaiting the run, decide what to do with the section based on the
/// [exitCode] (or any other criteria): call [keep] to leave the last output
/// lines visible, or [clear] to remove the section and overwrite the area.
class ScrollingProcessResult {
  /// The exit code of the process.
  final int exitCode;

  /// The section the output was rendered in.
  final ScrollingSection section;

  /// Creates a result for the given [exitCode] and [section].
  ScrollingProcessResult({required this.exitCode, required this.section});

  /// Whether the process exited successfully (exit code 0).
  bool get succeeded => exitCode == 0;

  /// Keeps the last visible output lines in place.
  ///
  /// When [full] is true (and the section was created with capture enabled), the
  /// complete output is rendered instead of only the last visible lines.
  void keep({final bool full = false}) => section.keep(full: full);

  /// Clears the scrolling section so the area can be overwritten.
  void clear() => section.clear();
}

/// Runs a subprocess and tails its combined stdout/stderr inside a
/// [ScrollingSection] at the bottom of the terminal.
abstract final class ScrollingProcess {
  /// Starts [executable] with [arguments] and renders its output in a scrolling
  /// section of [rows] visual rows until the process completes.
  ///
  /// Returns once the process has exited and all of its output has been
  /// rendered. The caller then decides whether to [ScrollingProcessResult.keep]
  /// or [ScrollingProcessResult.clear] the section.
  ///
  /// [terminal] is supplied and owned by the caller; this method does not
  /// dispose it.
  static Future<ScrollingProcessResult> run(
    final String executable,
    final List<String> arguments, {
    required final InlineTerminal terminal,
    final String? workingDirectory,
    final Map<String, String>? environment,
    final bool includeParentEnvironment = true,
    final bool runInShell = false,
    final int rows = 5,
    final bool dim = true,
    final String? heading,
    final String? successMessage,
    final String? failedMessage,
    final bool captureOutput = false,
  }) async {
    final section = ScrollingSection(
      terminal: terminal,
      rows: rows,
      dim: dim,
      heading: heading,
      successMessage: successMessage,
      failedMessage: failedMessage,
      captureOutput: captureOutput,
    );

    try {
      final process = await Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
      );

      final stdoutDone = _tail(process.stdout, section);
      final stderrDone = _tail(process.stderr, section);

      final exitCode = await process.exitCode;
      // Ensure all buffered output has been rendered before returning.
      await stdoutDone;
      await stderrDone;

      return ScrollingProcessResult(exitCode: exitCode, section: section);
    } on Object {
      // Restore the cursor and keep whatever was rendered so far.
      section.keep();
      rethrow;
    }
  }

  static Future<void> _tail(
    final Stream<List<int>> stream,
    final ScrollingSection section,
  ) {
    return stream
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .forEach(section.appendLine);
  }
}

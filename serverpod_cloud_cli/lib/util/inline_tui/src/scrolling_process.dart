import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'inline_terminal.dart';
import 'scrolling_section.dart';

/// The outcome of running a process inside a [ScrollingSection].
///
/// After awaiting the run, decide what to do with the section based on the
/// [exitCode] (or any other criteria) by calling [finish].
class ScrollingProcessResult {
  /// The exit code of the process.
  final int exitCode;

  /// The section the output was rendered in.
  final ScrollingSection section;

  /// Creates a result for the given [exitCode] and [section].
  ScrollingProcessResult({required this.exitCode, required this.section});

  /// Whether the process exited successfully (exit code 0).
  bool get succeeded => exitCode == 0;

  /// Finishes the section with [success], optionally overriding retention.
  void finish({required bool success, RetainSection? overrideRetention}) =>
      section.finish(success: success, overrideRetention: overrideRetention);
}

/// Runs a subprocess and tails its combined stdout/stderr inside a
/// [ScrollingSection] at the bottom of the terminal.
abstract final class ScrollingProcess {
  /// Starts [executable] with [arguments] and renders its output in a scrolling
  /// section of [rows] visual rows until the process completes.
  ///
  /// Returns once the process has exited and all of its output has been
  /// rendered. The caller then decides how to [ScrollingProcessResult.finish]
  /// the section.
  ///
  /// [terminal] is supplied and owned by the caller; this method does not
  /// dispose it.
  static Future<ScrollingProcessResult> run(
    String executable,
    List<String> arguments, {
    required InlineTerminal terminal,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    int rows = 5,
    bool dim = true,
    String? heading,
    String? successMessage,
    String? failedMessage,
    RetainSection? successRetention,
    RetainSection? failureRetention,
    bool captureOutput = false,
  }) async {
    final section = ScrollingSection(
      terminal: terminal,
      rows: rows,
      dim: dim,
      heading: heading,
      successMessage: successMessage,
      failedMessage: failedMessage,
      successRetention: successRetention,
      failureRetention: failureRetention,
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
      section.finish(success: false);
      rethrow;
    }
  }

  static Future<void> _tail(
    Stream<List<int>> stream,
    ScrollingSection section,
  ) {
    return stream
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .forEach(section.appendLine);
  }
}

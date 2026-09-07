import 'dart:io' show stdout, stderr, Directory, IOSink;

import 'package:cli_tools/execute.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

abstract class ScrollingCommandOutput {
  /// The number of visual rows the scrolling output section occupies.
  static const int defaultScrollRows = 5;

  /// Runs a single [command], returning its exit code.
  ///
  /// The output is rendered in a scrolling section only when it is destined for
  /// the interactive terminal: when the caller redirects output to its own
  /// [stdoutOverride]/[stderrOverride] sinks (e.g. the launch TUI routes it into a log view) or
  /// output is not connected to a terminal (e.g. CI or piped output), the
  /// output is streamed directly instead, since the section's cursor movement
  /// would otherwise corrupt it.
  static Future<int> runCommand(
    String command, {
    required CommandLogger logger,
    String? heading,
    String? successMessage,
    String? failedMessage,
    int? scrollRows,
    String? workingDirectory,
    IOSink? stdoutOverride,
    IOSink? stderrOverride,
  }) async {
    final workingDir = workingDirectory != null
        ? Directory(workingDirectory)
        : null;

    final redirected = stdoutOverride != null || stderrOverride != null;
    if (!redirected) {
      // Resolve the terminal only when output is destined for it, so the
      // redirected path (e.g. the launch TUI) never creates the shared terminal.
      final term = logger.inlineTerminal;
      if (term.hasTerminal) {
        return _runInScrollingSection(
          command,
          term,
          heading: heading,
          successMessage: successMessage,
          failedMessage: failedMessage,
          scrollRows: scrollRows,
          workingDirectory: workingDir,
        );
      }
    }

    if (heading != null) {
      if (redirected) {
        (stdoutOverride ?? stdout).writeln(heading);
      } else {
        logger.info(heading);
      }
    }
    return execute(
      command,
      stdout: stdoutOverride ?? stdout,
      stderr: stderrOverride ?? stderr,
      workingDirectory: workingDir,
    );
  }

  /// Runs [command], rendering its combined output in a scrolling section.
  ///
  /// On success the section is cleared so successful scripts leave only their
  /// header behind; on failure the last output lines are kept so the user can
  /// see what went wrong.
  static Future<int> _runInScrollingSection(
    String command,
    InlineTerminal terminal, {
    String? heading,
    String? successMessage,
    String? failedMessage,
    int? scrollRows,
    Directory? workingDirectory,
  }) async {
    final section = ScrollingSection(
      terminal: terminal,
      rows: scrollRows ?? defaultScrollRows,
      heading: heading,
      successMessage: successMessage,
      failedMessage: failedMessage,
      captureOutput: true,
    );
    final outSink = ScrollingSink(section);
    final errSink = ScrollingSink(section);
    try {
      final exitCode = await execute(
        command,
        stdout: outSink.sink,
        stderr: errSink.sink,
        workingDirectory: workingDirectory,
      );
      await outSink.close();
      await errSink.close();

      section.finish(success: exitCode == 0);
      return exitCode;
    } on Object {
      section.finish(success: false);
      rethrow;
    }
  }
}

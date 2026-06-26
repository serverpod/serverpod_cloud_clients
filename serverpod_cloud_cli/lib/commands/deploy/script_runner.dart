import 'dart:io';
import 'dart:io' as io;

import 'package:cli_tools/execute.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

abstract class ScriptRunner {
  /// The number of visual rows the scrolling output section occupies.
  static const int scrollRows = 5;

  static Future<void> runScripts(
    final List<String> commands,
    final String workingDirectory,
    final CommandLogger logger, {
    required final String scriptType,
    final int padHeadingRight = 0,
    final IOSink? stdout,
    final IOSink? stderr,
  }) async {
    if (commands.isEmpty) {
      return;
    }

    logger.info('Running $scriptType scripts:', newParagraph: true);
    for (var i = 0; i < commands.length; i++) {
      final command = commands[i];

      int exitCode;
      try {
        exitCode = await _runScript(
          command,
          heading: '(${i + 1}/${commands.length}) $command'.padRight(
            padHeadingRight,
          ),
          workingDirectory: workingDirectory,
          logger: logger,
          stdout: stdout,
          stderr: stderr,
        );
      } on Exception catch (e, stackTrace) {
        throw ErrorExitException(
          '$scriptType script failed: "$command"',
          e,
          stackTrace,
        );
      }
      if (exitCode != 0) {
        throw ErrorExitException(
          '$scriptType script failed with exit code $exitCode: "$command"',
        );
      }
    }
  }

  /// Runs a single [command], returning its exit code.
  ///
  /// The output is rendered in a scrolling section only when it is destined for
  /// the interactive terminal: when the caller redirects output to its own
  /// [stdout]/[stderr] sinks (e.g. the launch TUI routes it into a log view) or
  /// output is not connected to a terminal (e.g. CI or piped output), the
  /// output is streamed directly instead, since the section's cursor movement
  /// would otherwise corrupt it.
  static Future<int> _runScript(
    final String command, {
    final String? heading,
    required final String workingDirectory,
    required final CommandLogger logger,
    final IOSink? stdout,
    final IOSink? stderr,
  }) async {
    final redirected = stdout != null || stderr != null;
    if (!redirected) {
      // Resolve the terminal only when output is destined for it, so the
      // redirected path (e.g. the launch TUI) never creates the shared terminal.
      final term = logger.inlineTerminal;
      if (term.hasTerminal) {
        return _runInScrollingSection(
          command,
          workingDirectory,
          term,
          heading: heading,
        );
      }
    }

    if (heading != null) {
      if (redirected) {
        (stdout ?? io.stdout).writeln(heading);
      } else {
        logger.info(heading);
      }
    }
    return execute(
      command,
      stdout: stdout ?? io.stdout,
      stderr: stderr ?? io.stderr,
      workingDirectory: Directory(workingDirectory),
    );
  }

  /// Runs [command], rendering its combined output in a scrolling section.
  ///
  /// On success the section is cleared so successful scripts leave only their
  /// header behind; on failure the last output lines are kept so the user can
  /// see what went wrong.
  static Future<int> _runInScrollingSection(
    final String command,
    final String workingDirectory,
    final InlineTerminal terminal, {
    final String? heading,
  }) async {
    final section = ScrollingSection(
      terminal: terminal,
      rows: scrollRows,
      heading: heading,
      captureOutput: true,
    );
    final outSink = ScrollingSink(section);
    final errSink = ScrollingSink(section);
    try {
      final exitCode = await execute(
        command,
        stdout: outSink.sink,
        stderr: errSink.sink,
        workingDirectory: Directory(workingDirectory),
      );
      await outSink.close();
      await errSink.close();

      if (exitCode == 0) {
        section.clear();
      } else {
        section.keep(full: true);
      }
      return exitCode;
    } on Object {
      section.keep(full: true);
      rethrow;
    }
  }
}

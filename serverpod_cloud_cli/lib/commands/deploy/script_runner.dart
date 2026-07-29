import 'dart:io' show IOSink;

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/scrolling_command_output.dart';

abstract class ScriptRunner {
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
        exitCode = await ScrollingCommandOutput.runCommand(
          command,
          heading: '(${i + 1}/${commands.length}) $command'.padRight(
            padHeadingRight,
          ),
          workingDirectory: workingDirectory,
          logger: logger,
          stdoutOverride: stdout,
          stderrOverride: stderr,
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
}

import 'dart:io' show IOSink;

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/scrolling_command_output.dart';

abstract class ScriptRunner {
  /// Runs [commands] in order and stops at the first one that fails.
  ///
  /// The [environment] is added to the environment of every command.
  static Future<void> runScripts(
    List<String> commands,
    String workingDirectory,
    CommandLogger logger, {
    required String scriptType,
    int padHeadingRight = 0,
    Map<String, String>? environment,
    IOSink? stdout,
    IOSink? stderr,
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
          environment: environment,
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

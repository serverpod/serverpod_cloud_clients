import 'dart:io';

import 'package:cli_tools/execute.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class ScriptRunner {
  static Future<void> runScripts(
    final List<String> commands,
    final String workingDirectory,
    final CommandLogger logger, {
    required final String scriptType,
  }) async {
    if (commands.isEmpty) {
      return;
    }

    logger.info('Running $scriptType scripts', newParagraph: true);
    for (var i = 0; i < commands.length; i++) {
      final command = commands[i];

      logger.info(
        '(${i + 1}/${commands.length}) $command',
        newParagraph: i == 0,
      );

      int exitCode;
      try {
        exitCode = await execute(
          command,
          stderr: stderr,
          stdout: stdout,
          workingDirectory: Directory(workingDirectory),
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

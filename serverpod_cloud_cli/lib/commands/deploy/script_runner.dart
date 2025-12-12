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

      try {
        await execute(
          command,
          stderr: stderr,
          stdout: stdout,
          workingDirectory: Directory(workingDirectory),
        );
      } on ScriptExecutionException catch (e) {
        throw ErrorExitException('$scriptType script failed: ${e.message}', e);
      }
    }
  }
}

class ScriptExecutionException implements Exception {
  final String message;
  ScriptExecutionException(this.message);

  @override
  String toString() => message;
}

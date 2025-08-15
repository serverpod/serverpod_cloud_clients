import 'dart:async';
import 'dart:io';

import 'package:cli_tools/better_command_runner.dart' show ExitException;
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

void main(final List<String> args) async {
  final logger = CommandLogger.create();

  await runZonedGuarded(
    () async {
      try {
        await _main(args, logger);
        await _preExit(logger);
      } on ExitException catch (e) {
        await _preExit(logger);
        exit(e.exitCode);
      } catch (error, stackTrace) {
        // Last resort error handling.
        logger.error(
          _formatInternalError(error),
          stackTrace: stackTrace,
          forcePrintStackTrace: true,
        );
        await _preExit(logger);
        exit(ExitException.codeError);
      }
    },
    (final error, final stackTrace) async {
      logger.error(
        _formatInternalError(error, zonedError: true),
        stackTrace: stackTrace,
        forcePrintStackTrace: true,
      );
      await _preExit(logger);
      exit(ExitException.codeError);
    },
  );
}

Future<void> _main(final List<String> args, final CommandLogger logger) async {
  final runner = CloudCliCommandRunner.create(
    logger: logger,
    version: cliVersion,
  );
  try {
    await runner.run(args);
  } on UsageException catch (e, stackTrace) {
    logger.error(e.toString());
    throw ErrorExitException(e.message, e, stackTrace);
  }
}

Future<void> _preExit(final CommandLogger logger) async {
  await logger.flush();
}

String _formatInternalError(
  final dynamic error, {
  final bool zonedError = false,
}) {
  return 'Yikes! It is possible that this error is caused by an'
      ' internal issue with the Serverpod tooling. We would appreciate if you '
      'filed an issue over at Github. Please include the stack trace below and '
      'describe any steps you did to trigger the error.'
      '''

https://github.com/serverpod/serverpod/issues
${zonedError ? 'Zoned error' : ''}
${error.runtimeType} $error''';
}

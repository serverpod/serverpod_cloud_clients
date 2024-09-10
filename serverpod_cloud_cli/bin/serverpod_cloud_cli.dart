import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';

/// The version of the Serverpod Cloud CLI.
/// This should be updated when a new version is released.
const String cliVersion = '0.0.1';

void main(final List<String> args) async {
  final logger = _buildLogger();

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
        );
        await _preExit(logger);
        exit(ExitCodeType.general.exitCode);
      }
    },
    (final error, final stackTrace) async {
      logger.error(
        _formatInternalError(error),
        stackTrace: stackTrace,
      );
      await _preExit(logger);
      exit(ExitCodeType.general.exitCode);
    },
  );
}

Future<void> _main(final List<String> args, final Logger logger) async {
  final runner = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse(cliVersion),
  );
  await runner.run(args);
}

Future<void> _preExit(final Logger logger) async {
  await logger.flush();
}

String _formatInternalError(final dynamic error) {
  return 'Yikes! It is possible that this error is caused by an'
      ' internal issue with the Serverpod tooling. We would appreciate if you '
      'filed an issue over at Github. Please include the stack trace below and '
      'describe any steps you did to trigger the error.'
      '''

https://github.com/serverpod/serverpod/issues

$error
''';
}

Logger _buildLogger() {
  const Map<String, String> windowsReplacements = {
    '🚀': '',
  };
  return Platform.isWindows
      ? StdOutLogger(LogLevel.info, replacements: windowsReplacements)
      : StdOutLogger(LogLevel.info);
}

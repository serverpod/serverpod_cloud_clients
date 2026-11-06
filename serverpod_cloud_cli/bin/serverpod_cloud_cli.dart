import 'dart:async';
import 'dart:io';

import 'package:cli_tools/analytics.dart';
import 'package:cli_tools/cli_tools.dart' show ExitException;
import 'package:config/config.dart' show UsageException;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/analytics/analytics_reporter.dart';
import 'package:serverpod_cloud_cli/shared/error_reporting/sentry_error_reporter.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show ErrorExitException;
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

void main(List<String> args) async {
  final logger = CommandLogger.create();
  final errorReporter = SentryErrorReporter.forCli();

  await runZonedGuarded(
    () async {
      try {
        await _main(args, logger, errorReporter);
        await _preExit(logger);
      } on ExitException catch (e, stackTrace) {
        await _preExit(logger);
        await errorReporter.report(e, stackTrace);
        exit(e.exitCode);
      } catch (error, stackTrace) {
        // Last resort error handling.
        logger.error(
          _formatInternalError(error),
          stackTrace: stackTrace,
          forcePrintStackTrace: true,
        );
        await _preExit(logger);
        await errorReporter.report(error, stackTrace);
        exit(ExitException.codeError);
      }
    },
    (error, stackTrace) async {
      logger.error(
        _formatInternalError(error, zonedError: true),
        stackTrace: stackTrace,
        forcePrintStackTrace: true,
      );
      await _preExit(logger);
      await errorReporter.report(error, stackTrace);
      exit(ExitException.codeError);
    },
  );
}

Future<void> _main(
  List<String> args,
  CommandLogger logger,
  SentryErrorReporter errorReporter,
) async {
  final runner = CloudCliCommandRunner.create(
    logger: logger,
    version: cliVersion,
    onAnalyticsEvent: (event, properties, {userAuthId}) =>
        _reportAnalyticsEvent(event, properties, userAuthId, logger),
    onRunContextResolved: (context) {
      errorReporter.analyticsConsent = context.analyticsConsent;
      errorReporter.command = context.command;
      errorReporter.flags = context.flags;
      errorReporter.apiServerUrl = context.apiServerUrl;
      errorReporter.cloudUserId = context.cloudUserId;
      errorReporter.baseCommand = context.baseCommand;
    },
    onErrorReport: errorReporter.report,
  );

  try {
    await runner.run(args);
  } on UsageException catch (e, stackTrace) {
    logger.error(e.toString());
    throw ErrorExitException(e.message, e, stackTrace);
  }
}

Future<void> _preExit(CommandLogger logger) async {
  await logger.disposeInlineTerminal();
  await logger.flush();
}

String _formatInternalError(dynamic error, {bool zonedError = false}) {
  return 'Yikes! It is possible that this error is caused by an'
      ' internal issue with the Serverpod tooling. We would appreciate if you '
      'filed an issue over at Github. Please include the stack trace below and '
      'describe any steps you did to trigger the error.'
      '''

https://github.com/serverpod/serverpod/issues
${zonedError ? 'Zoned error' : ''}
${error.runtimeType} $error''';
}

void _reportAnalyticsEvent(
  String event,
  Map<String, dynamic> properties,
  String? userAuthId,
  CommandLogger logger,
) {
  try {
    _analyticsReporter.track(event, properties, userAuthId: userAuthId);
  } catch (e, stackTrace) {
    logger.debug('Analytics event failed: $e\n$stackTrace');
  }
}

const _postHogApiKey = 'phc_xGBPHgcrTrDuWGtyNX3UJODXgnR684rzRPZjWRlqVxf';
final AnalyticsReporter _analyticsReporter = AnalyticsReporter(
  serverpodCliId: ResourceManager.uniqueUserId,
  createPostHogAnalytics: (distinctId) => PostHogAnalytics(
    uniqueUserId: distinctId,
    projectApiKey: _postHogApiKey,
    version: cliVersion.canonicalizedVersion,
    libName: 'serverpod_cloud_cli',
  ),
);

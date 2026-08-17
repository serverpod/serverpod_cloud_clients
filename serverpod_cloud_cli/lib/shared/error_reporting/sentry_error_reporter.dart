import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart' show UsageException;
import 'package:cli_tools/better_command_runner.dart' show ExitException;
import 'package:sentry/sentry.dart';

import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

typedef SentryCapture =
    Future<void> Function(Object error, StackTrace stackTrace);

/// Reports unexpected CLI errors to Sentry.
///
/// Reporting is gated on the user's analytics consent, see [analyticsConsent].
/// Until consent is resolved to true, nothing is sent.
///
/// The reporter never throws and never delays process exit for longer
/// than [flushTimeout], so error reporting cannot break the CLI
/// or hang an offline machine.
class SentryErrorReporter {
  /// The Sentry DSN for the Serverpod Cloud CLI.
  ///
  /// An empty string disables error reporting entirely.
  static const String cliDsn =
      'https://f26d7e853d043429c07d6bf65b8f90a3@o4508681651421184.ingest.de.sentry.io/4511926523396176';

  final String dsn;
  final String release;
  final Duration flushTimeout;
  final SentryCapture? _captureOverride;

  bool _analyticsConsent = false;

  String _environment = 'dev';

  String? _command;

  SentryErrorReporter({
    required this.dsn,
    required this.release,
    this.flushTimeout = const Duration(seconds: 3),
    final SentryCapture? captureOverride,
  }) : _captureOverride = captureOverride;

  /// Creates the reporter for the running CLI, using [cliDsn]
  /// and the current CLI version as release.
  SentryErrorReporter.forCli()
    : this(
        dsn: cliDsn,
        release: 'serverpod_cloud_cli@${cliVersion.canonicalizedVersion}',
      );

  /// The environment reported events belong to, resolved from the
  /// API server URL the CLI talks to, see [apiServerUrl].
  ///
  /// Defaults to `dev` until the URL is resolved.
  String get environment => _environment;

  /// Sets the API server URL the CLI talks to,
  /// which determines the reported [environment].
  set apiServerUrl(final String url) {
    _environment = environmentFromApiServerUrl(url);
  }

  /// Returns the Sentry environment name for [apiServerUrl]
  /// (same environment names as the console uses):
  /// `prod` for the production API server, `preview` for PR preview
  /// environments (host name starting with `preview-`),
  /// and `dev` for everything else.
  static String environmentFromApiServerUrl(final String apiServerUrl) {
    final host = Uri.tryParse(apiServerUrl)?.host ?? '';
    final prodHost = Uri.parse(HostConstants.serverpodCloudApi).host;
    if (host == prodHost) {
      return 'prod';
    }
    if (host.startsWith('preview-')) {
      return 'preview';
    }
    return 'dev';
  }

  /// Sets whether the user has consented to sending telemetry.
  ///
  /// Defaults to false, so no reports are sent until consent is
  /// affirmatively resolved.
  set analyticsConsent(final bool consented) {
    _analyticsConsent = consented;
  }

  /// Sets the command being run, as the space-separated command name path
  /// followed by the flags used (e.g. `variable set --project`).
  ///
  /// Must contain command and flag names only - no option values or
  /// positional arguments, since those can hold project ids and other
  /// user data.
  /// Attached to reported events as the transaction and a `command` tag.
  set command(final String? command) {
    _command = command;
  }

  /// Returns true if [error] represents an unexpected internal failure
  /// that shall be reported, as opposed to a failure the user can correct.
  ///
  /// An [UnexpectedErrorExitException] is reportable, unless its nested
  /// causing exception indicates an environment problem (I/O failures,
  /// timeouts, malformed user input).
  /// All other [ExitException] and [UsageException] errors are expected
  /// command outcomes and are not reportable.
  /// Any other error has escaped normal command error handling and is
  /// reportable, with the same environment-problem exemption.
  static bool isReportable(final Object error) {
    if (error is UnexpectedErrorExitException) {
      final nested = error.nestedException;
      if (nested == null) {
        return true;
      }
      return _isUnexpectedCause(nested);
    }
    if (error is ExitException) {
      return false;
    }
    if (error is UsageException) {
      return false;
    }
    return _isUnexpectedCause(error);
  }

  static bool _isUnexpectedCause(final Object error) {
    if (error is IOException) {
      return false;
    }
    if (error is TimeoutException) {
      return false;
    }
    if (error is FormatException) {
      return false;
    }
    return true;
  }

  /// Reports [error] to Sentry if the user has consented to telemetry,
  /// the [dsn] is set, and the error [isReportable].
  ///
  /// For an [UnexpectedErrorExitException] the nested causing exception
  /// is reported when available.
  ///
  /// Completes within [flushTimeout] and never throws.
  Future<void> reportError(
    final Object error,
    final StackTrace stackTrace,
  ) async {
    if (!_analyticsConsent || dsn.isEmpty || !isReportable(error)) {
      return;
    }

    final (reportedError, reportedStackTrace) = _selectReported(
      error,
      stackTrace,
    );

    try {
      final capture = _captureOverride ?? _captureToSentry;
      await capture(reportedError, reportedStackTrace).timeout(flushTimeout);
    } on Object catch (_) {
      return;
    }
  }

  (Object, StackTrace) _selectReported(
    final Object error,
    final StackTrace stackTrace,
  ) {
    if (error is UnexpectedErrorExitException) {
      final nested = error.nestedException;
      if (nested != null) {
        return (nested, error.nestedStackTrace ?? stackTrace);
      }
    }
    return (error, stackTrace);
  }

  Future<void> _captureToSentry(
    final Object error,
    final StackTrace stackTrace,
  ) async {
    await Sentry.init((final options) {
      options.dsn = dsn;
      options.environment = environment;
      options.release = release;
      options.sendDefaultPii = false;
      final isolateIntegrations = options.integrations
          .whereType<IsolateErrorIntegration>()
          .toList();
      for (final integration in isolateIntegrations) {
        options.removeIntegration(integration);
      }
    });
    final command = _command;
    try {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (final scope) async {
          if (command != null) {
            scope.transaction = command;
            await scope.setTag('command', command);
          }
        },
      );
    } finally {
      await Sentry.close();
    }
  }
}

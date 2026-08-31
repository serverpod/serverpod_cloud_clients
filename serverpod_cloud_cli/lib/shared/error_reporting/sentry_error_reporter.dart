import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart' show UsageException;
import 'package:ci/ci.dart' as ci;
import 'package:cli_tools/better_command_runner.dart' show ExitException;
import 'package:ground_control_client/ground_control_client.dart'
    show SerializableException;
import 'package:sentry/sentry.dart';

import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

/// Captures an error with its stack trace, used to replace the Sentry
/// capture in tests.
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

  List<String> _flags = const [];

  String? _cloudUserId;

  BaseCommandInvocation? _baseCommand;

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

  /// Sets whether the user has consented to sending telemetry.
  ///
  /// Defaults to false, so no reports are sent until consent is
  /// affirmatively resolved.
  set analyticsConsent(final bool consented) {
    _analyticsConsent = consented;
  }

  /// Sets the command being run, as the space-separated command name path
  /// including subcommands (e.g. `variable set`).
  ///
  /// Must contain command names only - no option values or positional
  /// arguments, since those can hold project ids and other user data.
  /// Attached to reported events as the transaction and a `command` tag.
  set command(final String? command) {
    _command = command;
  }

  /// Sets the flags and options passed on the command line, as their names
  /// only (e.g. `['--project', '--verbose']`).
  ///
  /// Must contain flag and option names only - no values, since those can
  /// hold project ids and other user data.
  /// Attached to reported events as a space-separated `flags` tag.
  set flags(final List<String> flags) {
    _flags = flags;
  }

  /// Sets the API server URL the CLI talks to,
  /// which determines the reported [environment].
  set apiServerUrl(final String url) {
    _environment = environmentFromApiServerUrl(url);
  }

  /// Sets the invocation path the CLI was run through.
  ///
  /// Attached to reported events as a `base_command` tag.
  set baseCommand(final BaseCommandInvocation baseCommand) {
    _baseCommand = baseCommand;
  }

  /// Sets the id of the logged in cloud user, or null if not logged in.
  ///
  /// Attached to reported events as the Sentry user id when set.
  /// The anonymous analytics id is never sent to Sentry.
  set cloudUserId(final String? cloudUserId) {
    _cloudUserId = cloudUserId;
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

  /// Returns true if [error] represents an unexpected internal failure
  /// that shall be reported, as opposed to a failure the user can correct.
  ///
  /// An [UnexpectedErrorExitException] is reportable, unless its nested
  /// causing exception indicates an environment problem (I/O failures,
  /// timeouts, malformed user input) or is a [SerializableException] that
  /// the server declared and can carry user data in its message.
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
    if (error is SerializableException) {
      return false;
    }
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
  Future<void> report(final Object error, final StackTrace stackTrace) async {
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
    await Sentry.init(_configureOptions);
    try {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: _configureScope,
      );
    } finally {
      await Sentry.close();
    }
  }

  /// Applies the reporting options to [options]:
  /// the [dsn], the [environment], the [release], no default PII,
  /// no SDK debug output, and no isolate error integration since the
  /// CLI reports its own errors.
  void _configureOptions(final SentryOptions options) {
    options.dsn = dsn;
    options.environment = _environment;
    options.release = release;
    options.sendDefaultPii = false;
    options.debug = false;
    final isolateIntegrations = options.integrations
        .whereType<IsolateErrorIntegration>()
        .toList();
    for (final integration in isolateIntegrations) {
      options.removeIntegration(integration);
    }
  }

  /// Applies the event data to [scope]: the command as the transaction and
  /// a `command` tag, the flags as a `flags` tag, the invocation path as a
  /// `base_command` tag, an `is_ci` tag, and the cloud user id as the user
  /// when the user is logged in.
  Future<void> _configureScope(final Scope scope) async {
    final command = _command;
    if (command != null) {
      scope.transaction = command;
      await scope.setTag('command', command);
    }
    final flags = _flags;
    if (flags.isNotEmpty) {
      await scope.setTag('flags', flags.join(' '));
    }
    final baseCommand = _baseCommand;
    if (baseCommand != null) {
      await scope.setTag('base_command', baseCommand.reportedName);
    }
    await scope.setTag('is_ci', ci.isCI.toString());
    final cloudUserId = _cloudUserId;
    if (cloudUserId != null) {
      await scope.setUser(SentryUser(id: cloudUserId));
    }
  }
}

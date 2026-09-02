import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

/// The name of the pub package holding the CLI.
const _cliPackageName = 'serverpod_cloud_cli';

/// The Dart SDK executable, resolved from the path.
///
/// The running executable cannot be used: `dart install` compiles the CLI to a
/// native executable, so the running process is `scloud` itself, not the SDK.
const _dartExecutable = 'dart';

/// The environment variable naming the version a preceding process already
/// attempted to install.
///
/// The value is the attempted version, so that the guard only
/// suppresses a repeat attempt at that same version.
const cliUpdateAttemptedEnvName = 'SERVERPOD_CLOUD_UPDATE_ATTEMPTED';

/// The version a preceding process already attempted to install, if any.
///
/// Returns null when the variable is unset, empty, or not a valid version,
/// which lets the update proceed.
///
/// Defaults to the environment of the current process.
Version? attemptedCliUpdateVersion([Map<String, String>? environment]) {
  final env = environment ?? Platform.environment;
  final value = env[cliUpdateAttemptedEnvName];
  if (value == null || value.isEmpty) {
    return null;
  }

  try {
    return Version.parse(value);
  } on FormatException {
    return null;
  }
}

/// The directory `dart pub global activate` keeps its packages in.
const _pubGlobalPackagesDir = 'global_packages';

/// How the running CLI was installed, which decides how it is updated and
/// how it is invoked again.
enum CliInstallation {
  /// Installed with `dart install`, running as a native executable.
  native,

  /// Activated with `dart pub global activate`, running from a snapshot.
  pubGlobal,

  /// Run from a source checkout, which is never updated.
  source,
}

/// The installation the running CLI belongs to.
///
/// Only the Dart VM runs the CLI from a script, so any other executable is a
/// native build. A `dart pub global activate` snapshot lives under
/// [_pubGlobalPackagesDir]; any other script is a source checkout.
CliInstallation resolveCliInstallation({
  required String resolvedExecutable,
  required String scriptPath,
}) {
  if (p.basenameWithoutExtension(resolvedExecutable) != _dartExecutable) {
    return CliInstallation.native;
  }

  if (p.split(scriptPath).contains(_pubGlobalPackagesDir)) {
    return CliInstallation.pubGlobal;
  }

  return CliInstallation.source;
}

/// The `dart` arguments that install [version] for [installation].
///
/// Throws a [StateError] for [CliInstallation.source], which cannot be updated.
List<String> installArguments(
  CliInstallation installation, {
  required Version version,
}) {
  switch (installation) {
    case CliInstallation.native:
      return ['install', '$_cliPackageName@$version'];
    case CliInstallation.pubGlobal:
      return ['pub', 'global', 'activate', _cliPackageName, '$version'];
    case CliInstallation.source:
      throw StateError('A source checkout cannot be updated.');
  }
}

/// The executable and arguments that rerun this CLI with [args].
///
/// A native build reruns [invokedExecutable], which follows the path to the
/// version installed now. Every other installation runs [scriptPath] on the
/// Dart VM.
({String executable, List<String> args}) rerunInvocation(
  List<String> args, {
  required CliInstallation installation,
  required String invokedExecutable,
  required String resolvedExecutable,
  required String scriptPath,
}) {
  if (installation == CliInstallation.native) {
    return (executable: invokedExecutable, args: args);
  }

  return (executable: resolvedExecutable, args: [scriptPath, ...args]);
}

/// Thrown when installing a new version of the CLI failed.
class CliUpdateFailedException implements Exception {
  /// The version that failed to install.
  final Version version;

  /// The technical reason the install failed.
  final String reason;

  CliUpdateFailedException({required this.version, required this.reason});

  @override
  String toString() =>
      'CliUpdateFailedException: failed to install '
      '$_cliPackageName $version: $reason';
}

/// Installs a newer version of the CLI and reruns the current command with it.
abstract interface class CliUpdater {
  /// Whether this installation can update itself.
  ///
  /// False for a source checkout, which must not be replaced by a pub release.
  bool get canSelfUpdate;

  /// Installs exactly [version] of the CLI.
  ///
  /// Throws a [CliUpdateFailedException] if the install could not be run or
  /// did not succeed.
  Future<void> install(Version version, {required CommandLogger logger});

  /// Reruns the current command with [args] in a new process.
  ///
  /// Returns the exit code of the new process.
  /// Throws a [ProcessException] if the new process could not be started.
  Future<int> rerun(
    List<String> args, {
    required Version installedVersion,
    required CommandLogger logger,
  });
}

/// A [CliUpdater] that installs the CLI from pub with the Dart SDK.
///
/// Installs with the `dart` executable from the path, since the running
/// executable is the CLI itself when it was installed with `dart install`.
/// Reruns with the executable that [rerunInvocation] resolves.
class DartCliUpdater implements CliUpdater {
  const DartCliUpdater();

  /// The installation the running CLI belongs to.
  CliInstallation get installation => resolveCliInstallation(
    resolvedExecutable: Platform.resolvedExecutable,
    scriptPath: Platform.script.toFilePath(),
  );

  @override
  bool get canSelfUpdate => installation != CliInstallation.source;

  @override
  Future<void> install(Version version, {required CommandLogger logger}) async {
    final arguments = installArguments(installation, version: version);
    logger.debug('Installing $_cliPackageName $version: $arguments');

    final ProcessResult result;
    try {
      result = await Process.run(_dartExecutable, arguments);
    } on ProcessException catch (e, stackTrace) {
      logger.debug('Failed to run the install command: $e\n$stackTrace');
      throw CliUpdateFailedException(
        version: version,
        reason: 'the install command could not be run: ${e.message}',
      );
    }

    if (result.exitCode != 0) {
      logger.debug(
        'The install command exited with ${result.exitCode}.\n'
        '${result.stdout}\n${result.stderr}',
      );
      throw CliUpdateFailedException(
        version: version,
        reason: 'the install command exited with ${result.exitCode}',
      );
    }
  }

  @override
  Future<int> rerun(
    List<String> args, {
    required Version installedVersion,
    required CommandLogger logger,
  }) async {
    final invocation = rerunInvocation(
      args,
      installation: installation,
      invokedExecutable: Platform.executable,
      resolvedExecutable: Platform.resolvedExecutable,
      scriptPath: Platform.script.toFilePath(),
    );
    logger.debug(
      'Rerunning the command: '
      '${invocation.executable} ${invocation.args.join(' ')}',
    );

    await logger.disposeInlineTerminal();
    await logger.flush();

    final process = await Process.start(
      invocation.executable,
      invocation.args,
      mode: ProcessStartMode.inheritStdio,
      environment: {
        cliUpdateAttemptedEnvName: installedVersion.canonicalizedVersion,
      },
    );

    return await process.exitCode;
  }
}

import 'dart:io';

import 'package:config/command.dart' show CommandContext, OriginalCommandLine;
import 'package:config/config.dart' show OptionDefinition;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart'
    show GlobalConfiguration, GlobalConfigurationOptions;
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_updater.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_version_checker.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// Updates this CLI installation when a newer version is available, then
/// reruns the current command with the updated CLI.
class CliAutoUpdate {
  /// Writes progress and alerts for the update.
  final CommandLogger logger;

  /// The version of the CLI running in this process.
  final Version currentVersion;

  /// Installs a CLI version and reruns the command.
  final CliUpdater updater;

  /// The version this process was already updated to, if any,
  /// which must not be installed again.
  final Version? attemptedVersion;

  /// Reports an error that the update handled but that shall still be
  /// reported for diagnostics. Never required.
  final Future<void> Function(Object error, StackTrace stackTrace)?
  onErrorReport;

  /// Creates an update attempt for the running CLI.
  const CliAutoUpdate({
    required this.logger,
    required this.currentVersion,
    required this.updater,
    required this.attemptedVersion,
    this.onErrorReport,
  });

  /// Updates the CLI when a newer version is available and reruns the command.
  ///
  /// [context] supplies the global configuration and the original command
  /// line. The global configuration must already be stored on
  /// [context.provider].
  ///
  /// Returns true when the command was rerun with the updated CLI and must
  /// not run in this process. Returns false when no update was needed, or the
  /// update failed and the command shall run on the current version.
  ///
  /// Throws [ErrorExitException] when a breaking update is required and was
  /// not installed, or when the updated CLI must be run again by the caller.
  /// Throws [UnexpectedErrorExitException] if the rerun could not be started.
  Future<bool> attempt<O extends OptionDefinition>(
    CommandContext<O, void> context,
  ) async {
    final globalConfiguration = context.provider.fetch<GlobalConfiguration>();
    final arguments = context.provider.fetch<OriginalCommandLine>().args;
    final latestVersion = await _fetchLatestCliVersion(
      globalConfiguration.scloudDir.path,
    );

    if (latestVersion != null && currentVersion < latestVersion) {
      if (globalConfiguration.autoCliUpgrade &&
          attemptedVersion != latestVersion) {
        return _updateAndRerunCommand(
          latestVersion: latestVersion,
          breakingVersionCheck: globalConfiguration.breakingVersionCheck,
          exitOnUpdated: globalConfiguration.exitOnUpdated,
          arguments: arguments,
        );
      } else {
        _alertUpdateNotInstalled(
          latestVersion,
          breakingVersionCheck: globalConfiguration.breakingVersionCheck,
        );
      }
    }
    return false;
  }

  /// The latest published CLI version, or null when the lookup fails.
  ///
  /// [localStoragePath] is the directory of the cached version record.
  Future<Version?> _fetchLatestCliVersion(String localStoragePath) async {
    try {
      return await CLIVersionChecker.fetchLatestCLIVersion(
        logger: logger,
        localStoragePath: localStoragePath,
      );
    } catch (e) {
      logger.debug('Failed to fetch latest CLI version: $e');
      return null;
    }
  }

  /// Whether [latestVersion] is a breaking update that the user must install
  /// to continue.
  bool _isRequiredUpdate(
    Version latestVersion, {
    required bool breakingVersionCheck,
  }) =>
      CLIVersionChecker.isBreakingUpdate(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
      ) &&
      breakingVersionCheck;

  /// Updates the CLI to [latestVersion] and reruns the command with it.
  ///
  /// Returns true if the command was rerun, and so must not be run again in
  /// this process. Returns false if the update failed and the command shall
  /// run on the current version.
  ///
  /// Throws [ErrorExitException] with [ExitCodeConstants.scloudUpdatedRerunRequired]
  /// if the rerun is turned off, with the rerun's exit code if the rerun
  /// failed, and with [ExitCodeConstants.scloudUpdateRequired] if a breaking
  /// update could not be installed.
  /// Throws [UnexpectedErrorExitException] if the rerun could not be started.
  Future<bool> _updateAndRerunCommand({
    required Version latestVersion,
    required bool breakingVersionCheck,
    required bool exitOnUpdated,
    required List<String> arguments,
  }) async {
    if (!updater.canSelfUpdate) {
      logger.debug('This CLI installation cannot update itself.');
      _alertUpdateNotInstalled(
        latestVersion,
        breakingVersionCheck: breakingVersionCheck,
      );
      return false;
    }

    final updated = await logger.progress(
      'Updating Serverpod Cloud CLI to $latestVersion',
      () async {
        try {
          await updater.install(latestVersion, logger: logger);
          return true;
        } on CliUpdateFailedException catch (e, stackTrace) {
          logger.debug('Failed to update the CLI: $e\n$stackTrace');
          await _reportError(e, stackTrace);
          return false;
        }
      },
      successMessage: 'Updated Serverpod Cloud CLI to $latestVersion',
    );

    if (!updated) {
      _alertUpdateNotInstalled(
        latestVersion,
        breakingVersionCheck: breakingVersionCheck,
      );
      return false;
    }

    if (exitOnUpdated) {
      throw ErrorExitException.code(
        ExitCodeConstants.scloudUpdatedRerunRequired,
        'Updated to $latestVersion, the command must be run again.',
      );
    }

    final int rerunExitCode;
    try {
      rerunExitCode = await updater.rerun(
        arguments,
        installedVersion: latestVersion,
        logger: logger,
      );
    } on ProcessException catch (e, stackTrace) {
      await _reportError(e, stackTrace);
      logger.error(
        'The CLI was updated to $latestVersion,'
        ' but the command could not be run again.',
        hint: 'Run the command again.',
      );
      throw UnexpectedErrorExitException(e.message, e, stackTrace);
    }

    if (rerunExitCode != 0) {
      throw ErrorExitException.code(
        rerunExitCode,
        'The rerun of the command exited with $rerunExitCode.',
      );
    }

    return true;
  }

  /// Alerts that [latestVersion] is available but was not installed.
  ///
  /// Throws [ErrorExitException] with [ExitCodeConstants.scloudUpdateRequired]
  /// if the update is breaking and the breaking version check is enabled.
  void _alertUpdateNotInstalled(
    Version latestVersion, {
    required bool breakingVersionCheck,
  }) {
    final isRequiredUpdate = _isRequiredUpdate(
      latestVersion,
      breakingVersionCheck: breakingVersionCheck,
    );

    _printUpdateCLIAlert(
      latestVersion: latestVersion,
      isRequiredUpdate: isRequiredUpdate,
    );

    if (isRequiredUpdate) {
      throw ErrorExitException.code(
        ExitCodeConstants.scloudUpdateRequired,
        'You need to update the CLI to continue.',
      );
    }
  }

  /// Reports [error] for diagnostics, if a reporter is configured.
  ///
  /// Never throws, so reporting cannot break the command being run.
  Future<void> _reportError(Object error, StackTrace stackTrace) async {
    try {
      await onErrorReport?.call(error, stackTrace);
    } catch (e, s) {
      logger.debug('Failed to report the error: $e\n$s');
    }
  }

  /// Prints the alert that [latestVersion] is available.
  ///
  /// [isRequiredUpdate] adds the notice that the CLI must be updated to
  /// continue.
  void _printUpdateCLIAlert({
    required Version latestVersion,
    required bool isRequiredUpdate,
  }) {
    var infoMessage =
        '''A new version $latestVersion of Serverpod Cloud CLI is available!

  To update to the latest version, run "dart install serverpod_cloud_cli".''';

    if (isRequiredUpdate) {
      infoMessage = '$infoMessage You need to update the CLI to continue.';
    }

    logger.box(infoMessage);
  }
}

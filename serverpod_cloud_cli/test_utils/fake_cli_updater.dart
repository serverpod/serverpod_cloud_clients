import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_updater.dart';

/// A [CliUpdater] that records its calls instead of touching the system.
class FakeCliUpdater implements CliUpdater {
  /// Whether the fake installation can update itself.
  @override
  final bool canSelfUpdate;

  /// Whether [install] succeeds or throws a [CliUpdateFailedException].
  final bool installSucceeds;

  /// Whether [rerun] starts the new process or throws a [ProcessException].
  final bool rerunSucceeds;

  /// The exit code [rerun] reports.
  final int rerunExitCode;

  final List<Version> installCalls = [];

  final List<({List<String> args, Version installedVersion})> rerunCalls = [];

  FakeCliUpdater({
    this.canSelfUpdate = true,
    this.installSucceeds = true,
    this.rerunSucceeds = true,
    this.rerunExitCode = 0,
  });

  @override
  Future<void> install(
    final Version version, {
    required final CommandLogger logger,
  }) async {
    installCalls.add(version);

    if (!installSucceeds) {
      throw CliUpdateFailedException(
        version: version,
        reason: 'the fake updater was configured to fail',
      );
    }
  }

  @override
  Future<int> rerun(
    final List<String> args, {
    required final Version installedVersion,
    required final CommandLogger logger,
  }) async {
    rerunCalls.add((args: args, installedVersion: installedVersion));

    if (!rerunSucceeds) {
      throw ProcessException(
        'scloud',
        args,
        'the fake updater was configured to fail',
        2,
      );
    }

    return rerunExitCode;
  }
}

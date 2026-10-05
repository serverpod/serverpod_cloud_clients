import 'dart:io';

import 'package:path/path.dart' as p;

/// A `serverpod` command that runs the Serverpod CLI version the project
/// depends on, instead of the globally activated one.
///
/// The command is a wrapper script around [command] in a temporary directory.
/// Processes started with [environment] find the wrapper first on the `PATH`,
/// whatever shell syntax they invoke `serverpod` with.
class ProjectServerpodCli {
  /// The package that provides the Serverpod CLI.
  static const packageName = 'serverpod_cli';

  /// The command that runs the project's Serverpod CLI.
  static const command = 'dart run $packageName';

  /// The prefix of the temporary directory that holds the wrapper script.
  static const directoryPrefix = 'scloud_project_serverpod_cli_';

  /// The temporary directory that holds the wrapper script.
  final Directory directory;

  ProjectServerpodCli._(this.directory);

  /// Writes the wrapper script to a new temporary directory.
  ///
  /// Call [delete] to remove it when the scripts have run.
  static Future<ProjectServerpodCli> create() async {
    final directory = await Directory.systemTemp.createTemp(directoryPrefix);
    if (Platform.isWindows) {
      await File(
        p.join(directory.path, 'serverpod.bat'),
      ).writeAsString('@echo off\r\n$command %*\r\n');
    } else {
      final script = File(p.join(directory.path, 'serverpod'));
      await script.writeAsString('#!/bin/sh\nexec $command "\$@"\n');
      final result = await Process.run('chmod', ['+x', script.path]);
      if (result.exitCode != 0) {
        await directory.delete(recursive: true);
        throw ProcessException(
          'chmod',
          ['+x', script.path],
          '${result.stderr}',
          result.exitCode,
        );
      }
    }
    return ProjectServerpodCli._(directory);
  }

  /// The environment variables that put the wrapper script first on the
  /// `PATH`.
  Map<String, String> get environment {
    final parentEnvironment = Platform.environment;
    final pathKey = parentEnvironment.keys.firstWhere(
      (key) => key.toUpperCase() == 'PATH',
      orElse: () => 'PATH',
    );
    final parentPath = parentEnvironment[pathKey];
    if (parentPath == null || parentPath.isEmpty) {
      return {pathKey: directory.path};
    }
    final separator = Platform.isWindows ? ';' : ':';
    return {pathKey: '${directory.path}$separator$parentPath'};
  }

  /// Deletes the temporary directory with the wrapper script.
  Future<void> delete() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

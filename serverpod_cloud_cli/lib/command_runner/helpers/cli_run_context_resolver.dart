import 'package:args/args.dart';

import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

/// Resolves the parts of the context of a CLI run that are reported
/// as telemetry.
abstract final class CliRunContextResolver {
  /// Returns the space-separated command name path of the command to run,
  /// including its subcommands (e.g. `variable set`).
  ///
  /// Contains command names only - never option values or positional
  /// arguments, since those can hold project ids and other user data.
  /// Returns null if no command was resolved.
  static String? commandPath(ArgResults topLevelResults) {
    final names = <String>[];
    ArgResults? commandResults = topLevelResults.command;
    while (commandResults != null) {
      final name = commandResults.name;
      if (name != null) {
        names.add(name);
      }
      commandResults = commandResults.command;
    }
    if (names.isEmpty) {
      return null;
    }
    return names.join(' ');
  }

  /// Returns the sorted long names of the flags and options that were passed
  /// on the command line, on the top level command and its subcommands
  /// (e.g. `['--config-dir', '--project']`).
  ///
  /// Contains flag and option names only - never their values, since those
  /// can hold project ids and other user data.
  static List<String> commandFlags(ArgResults topLevelResults) {
    final flags = <String>[];
    ArgResults? commandResults = topLevelResults;
    while (commandResults != null) {
      final results = commandResults;
      flags.addAll(
        results.options.where(results.wasParsed).map((option) => '--$option'),
      );
      commandResults = results.command;
    }
    flags.sort();
    return flags;
  }

  /// Returns the id of the cloud user logged in on [localStoragePath],
  /// or null if the user is not logged in.
  static String? fetchCloudUserId(String localStoragePath) {
    final cloudUser = ResourceManager.tryFetchServerpodCloudUserDataSync(
      localStoragePath: localStoragePath,
    );
    return cloudUser?.id;
  }
}

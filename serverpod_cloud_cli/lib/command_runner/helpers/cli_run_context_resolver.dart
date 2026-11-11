import 'package:config/command.dart';
import 'package:config/config.dart';

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
  static String? commandPath<O extends OptionDefinition, T>(
    final CommandContext<O, T> context,
  ) {
    final names = <String>[];
    CommandContext<OptionDefinition, T>? commandContext = context.root().next;
    while (commandContext != null) {
      names.add(commandContext.command.name);
      commandContext = commandContext.next;
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
  static List<String> commandFlags<O extends OptionDefinition, T>(
    final CommandContext<O, T> context,
  ) {
    final flags = <String>[];
    CommandContext<OptionDefinition, T>? commandContext = context.root();
    while (commandContext != null) {
      flags.addAll(_argFlags(commandContext.config));
      flags.addAll(_argFlags(commandContext.builtinConfig));
      commandContext = commandContext.next;
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

  /// Returns the auth id of the cloud user logged in on [localStoragePath],
  /// or null if the user is not logged in or the id is not stored.
  static String? fetchUserAuthId(String localStoragePath) {
    final cloudUser = ResourceManager.tryFetchServerpodCloudUserDataSync(
      localStoragePath: localStoragePath,
    );
    return cloudUser?.userAuthId;
  }

  static Iterable<String> _argFlags<O extends OptionDefinition>(
    final Configuration<O> config,
  ) {
    return config
        .optionsWhereSource((final source) => source == ValueSourceType.arg)
        .map((final option) => option.option.argName)
        .whereType<String>()
        .map((final name) => '--$name');
  }
}

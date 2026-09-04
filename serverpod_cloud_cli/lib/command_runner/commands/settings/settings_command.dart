import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

class CloudSettingsCommand extends CloudCliCommand {
  @override
  final name = 'settings';

  @override
  final description = 'Manage local CLI user settings.';

  CloudSettingsCommand({required super.logger}) {
    addSubcommand(CloudSettingsListCommand(logger: logger));
    addSubcommand(CloudSettingsSetCommand(logger: logger));
    addSubcommand(CloudSettingsUnsetCommand(logger: logger));
  }
}

abstract final class SettingsCommandConfig {
  static const name = NameOption(
    argPos: 0,
    helpText: 'The name of the setting. Can be passed as the first argument.',
  );

  static const value = ValueOption(
    argPos: 1,
    helpText: 'The value of the setting. Can be passed as the second argument.',
  );
}

class CloudSettingsListCommand extends CloudCliCommand {
  @override
  bool get requireLogin => false;

  @override
  final name = 'list';

  @override
  final description = 'List local CLI user settings.';

  @override
  final bool takesArguments = false;

  CloudSettingsListCommand({required super.logger});

  @override
  Future<void> runWithOutput(
    final Configuration commandConfig,
    final CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => SettingsOperations.listSettingsOperation(
        runner.serviceProvider.scloudSettings,
      ),
      textOutputUi: const SettingsListUi(),
    );
  }
}

enum SettingsSetOption<V> implements OptionDefinition<V> {
  name(SettingsCommandConfig.name),
  value(SettingsCommandConfig.value);

  const SettingsSetOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudSettingsSetCommand extends CloudCliCommand<SettingsSetOption> {
  @override
  bool get requireLogin => false;

  @override
  final name = 'set';

  @override
  final description = 'Set a local CLI user setting.';

  @override
  String? get usageExamples =>
      '''\n
Examples

  Enable analytics.

    \$ $baseCommand settings set analytics true

  Disable analytics.

    \$ $baseCommand settings set analytics false
''';

  CloudSettingsSetCommand({required super.logger})
    : super(options: SettingsSetOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<SettingsSetOption> commandConfig,
    final CommandOutput output,
  ) async {
    final name = commandConfig.value(SettingsSetOption.name);
    final value = commandConfig.optionalValue(SettingsSetOption.value);
    if (value == null) {
      throw StateError('Expected the value option to be set.');
    }

    await renderCommand(
      output,
      operation: () => SettingsOperations.setSetting(
        runner.serviceProvider.scloudSettings,
        name: name,
        value: value,
      ),
      textOutputUi: const SettingsSetTextUi(),
    );
  }
}

enum SettingsUnsetOption<V> implements OptionDefinition<V> {
  name(SettingsCommandConfig.name);

  const SettingsUnsetOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudSettingsUnsetCommand extends CloudCliCommand<SettingsUnsetOption> {
  @override
  bool get requireLogin => false;

  @override
  final name = 'unset';

  @override
  final description = 'Unset a local CLI user setting.';

  @override
  String? get usageExamples =>
      '''\n
Examples

  Unset analytics.

    \$ $baseCommand settings unset analytics
''';

  CloudSettingsUnsetCommand({required super.logger})
    : super(options: SettingsUnsetOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<SettingsUnsetOption> commandConfig,
    final CommandOutput output,
  ) async {
    final name = commandConfig.value(SettingsUnsetOption.name);

    await renderCommand(
      output,
      operation: () => SettingsOperations.unsetSetting(
        runner.serviceProvider.scloudSettings,
        name: name,
      ),
      textOutputUi: const SettingsUnsetTextUi(),
    );
  }
}

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_ui.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

enum CliUserSettingsOption<V> implements OptionDefinition<V> {
  analytics(
    FlagOption(
      argName: 'analytics',
      negatable: true,
      helpText: 'Toggles if analytics data is sent.',
    ),
  );

  const CliUserSettingsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CliUserSettingsCommand extends CloudCliCommand<CliUserSettingsOption> {
  @override
  bool get requireLogin => false;

  @override
  final name = 'settings';

  @override
  final description = 'Manage local CLI user settings.';

  CliUserSettingsCommand({required super.logger})
    : super(options: CliUserSettingsOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<CliUserSettingsOption> commandConfig,
    final CommandOutput output,
  ) async {
    final settings = runner.serviceProvider.scloudSettings;
    final analytics = commandConfig.optionalValue(
      CliUserSettingsOption.analytics,
    );

    if (analytics != null) {
      await renderCommand(
        output,
        operation: () =>
            SettingsOperations.setAnalytics(settings, analytics: analytics),
        textOutputUi: const SettingsSetTextUi(),
      );
      return;
    }

    await renderCommand(
      output,
      operation: () => SettingsOperations.getSettings(settings),
      textOutputUi: const SettingsShowTextUi(),
    );
  }
}

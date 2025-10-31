import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';

enum CliUserSettingsOption<V> implements OptionDefinition<V> {
  analytics(FlagOption(
    argName: 'analytics',
    negatable: true,
    helpText: 'Toggles if analytics data is sent.',
  ));

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
  Future<void> runWithConfig(
    final Configuration<CliUserSettingsOption> commandConfig,
  ) async {
    var settingSpecified = false;

    if (commandConfig.optionalValue(CliUserSettingsOption.analytics)
        case final bool analytics) {
      final settings = runner.serviceProvider.scloudSettings;
      await settings.setEnableAnalytics(analytics);
      settingSpecified = true;
      logger.info('Analytics set to "$analytics".');
    }

    if (!settingSpecified) {
      // show current settings
      final settings = runner.serviceProvider.scloudSettings;
      final analytics = await settings.enableAnalytics;
      logger.list(
        title: 'Local settings',
        ['Analytics = ${analytics ?? 'not set'}'],
      );
    }
  }
}

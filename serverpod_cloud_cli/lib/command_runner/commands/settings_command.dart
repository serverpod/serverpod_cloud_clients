import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output_format.dart';

enum CliUserSettingsOption<V> implements OptionDefinition<V> {
  analytics(
    FlagOption(
      argName: 'analytics',
      negatable: true,
      helpText: 'Toggles if analytics data is sent.',
    ),
  ),
  output(
    EnumOption<OutputFormat>(
      argName: 'output',
      helpText: 'Sets the default output format.',
      enumParser: EnumParser(OutputFormat.values),
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

    if (commandConfig.optionalValue(CliUserSettingsOption.output)
        case final OutputFormat output) {
      final settings = runner.serviceProvider.scloudSettings;
      await settings.setOutputFormat(output.name);
      settingSpecified = true;
      logger.info('Output format set to "${output.name}".');
    }

    if (!settingSpecified) {
      final settings = runner.serviceProvider.scloudSettings;
      final analytics = await settings.enableAnalytics;
      final outputFormat = await settings.outputFormat;
      logger.list(title: 'Local settings', [
        'Analytics = ${analytics ?? 'not set'}',
        'Output format = ${outputFormat ?? 'not set'}',
      ]);
    }
  }
}

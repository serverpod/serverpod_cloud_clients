import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show FormatOption;
import 'package:serverpod_cloud_cli/commands/me/me.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

import 'categories.dart';

enum MeCommandOption<V> implements OptionDefinition<V> {
  format(FormatOption());

  const MeCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudMeCommand extends CloudCliCommand<MeCommandOption> {
  @override
  final name = 'me';

  @override
  final description = 'Show information about the current user.';

  @override
  String get category => CommandCategories.manage;

  CloudMeCommand({required super.logger})
    : super(options: MeCommandOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<MeCommandOption> commandConfig,
  ) async {
    final format = commandConfig.value(MeCommandOption.format);

    await MeCommands.showCurrentUser(
      runner.serviceProvider.cloudApiClient,
      output: CommandOutput.forFormat(format, logger),
    );
  }
}

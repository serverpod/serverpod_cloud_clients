import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

enum StatusOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  utc(UtcOption());

  const StatusOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStatusCommand extends CloudCliCommand<StatusOption> {
  @override
  final name = 'status';

  @override
  final description = "Show the live status of the project's podlets.";

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples =>
      '''\n
Examples

  Show the live status of the project's podlets.

    \$ $baseCommand status


  Show the live status of a specific project's podlets.

    \$ $baseCommand status --project my-project

''';

  CloudStatusCommand({required super.logger})
    : super(options: StatusOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StatusOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(StatusOption.projectId);
    final inUtc = commandConfig.value(StatusOption.utc);

    await renderCommand(
      output,
      operation: () => StatusCommands.fetchRuntimeStatus(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: RuntimeStatusTextUi(baseCommand: baseCommand, utc: inUtc),
    );
  }
}

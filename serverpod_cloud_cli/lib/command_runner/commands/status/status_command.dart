import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

class CloudStatusCommand extends CloudCliCommand {
  @override
  final name = 'status';

  @override
  final description = 'Show project and deployment status.';

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples =>
      '''\n
Examples

  Show the live status of the project's podlets.

    \$ $baseCommand status live


  Show the status of the latest deployment.

    \$ $baseCommand status deployment show

''';

  CloudStatusCommand({required super.logger}) {
    addSubcommand(CloudStatusLiveCommand(logger: logger));
    addSubcommand(CloudDeploymentsCommand(logger: logger));
  }
}

enum StatusLiveOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  utc(UtcOption()),
  watch(
    FlagOption(
      argName: 'watch',
      helpText: 'Refresh the status until Ctrl+C is pressed.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  interval(
    DurationOption(
      argName: 'interval',
      helpText: 'How often --watch refreshes the status.',
      defaultsTo: Duration(seconds: 5),
      min: Duration(seconds: 1),
    ),
  );

  const StatusLiveOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStatusLiveCommand extends CloudCliCommand<StatusLiveOption> {
  @override
  final name = 'live';

  @override
  final description = "Show the live status of the project's podlets.";

  @override
  String get usageExamples =>
      '''\n
Examples

  Show the live status of the project's podlets.

    \$ $baseCommand status live


  Show the live status of a specific project's podlets.

    \$ $baseCommand status live --project my-project


  Refresh the live status every 5 seconds until Ctrl+C is pressed.

    \$ $baseCommand status live --watch


  Refresh the live status every 30 seconds.

    \$ $baseCommand status live --watch --interval 30s

''';

  CloudStatusLiveCommand({required super.logger})
    : super(options: StatusLiveOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StatusLiveOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(StatusLiveOption.projectId);
    final inUtc = commandConfig.value(StatusLiveOption.utc);
    final watch = commandConfig.value(StatusLiveOption.watch);
    final interval = commandConfig.value(StatusLiveOption.interval);
    final client = runner.serviceProvider.cloudApiClient;

    if (watch) {
      await renderCommand(
        output,
        operation: () async => StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: interval,
          stop: logger.inlineTerminal.interruptSignals,
        ),
        textOutputUi: RuntimeStatusWatchTextUi(
          baseCommand: baseCommand,
          utc: inUtc,
          interval: interval,
        ),
      );
      return;
    }

    if (commandConfig.valueSourceType(StatusLiveOption.interval) ==
        ValueSourceType.arg) {
      logger.warning('The --interval option has no effect without --watch.');
    }

    await renderCommand(
      output,
      operation: () =>
          StatusCommands.fetchRuntimeStatus(client, projectId: projectId),
      textOutputUi: RuntimeStatusTextUi(baseCommand: baseCommand, utc: inUtc),
    );
  }
}

import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show CapsuleStatusUnavailableException, NotFoundException;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/runtime_status.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

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
  utc(UtcOption());

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

    try {
      await RuntimeStatusCommands.showRuntimeStatus(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        baseCommand: baseCommand,
        projectId: projectId,
        inUtc: inUtc,
      );
    } on CapsuleStatusUnavailableException {
      throw FailureException(
        error: 'Could not retrieve the podlet status for project "$projectId".',
        hint:
            'The status service is temporarily unavailable — '
            'try again shortly.',
      );
    } on NotFoundException {
      throw FailureException(error: 'Project "$projectId" was not found.');
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get the podlet status');
    }
  }
}

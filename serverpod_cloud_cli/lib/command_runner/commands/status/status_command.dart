import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show CapsuleStatusUnavailableException;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/command_runner/commands/status/runtime_status.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

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
  String get usageExamples => '''\n
Examples

  Show the live status of the project's podlets.

    \$ scloud status


  Show the live status of a specific project's podlets.

    \$ scloud status --project my-project

''';

  CloudStatusCommand({required super.logger})
    : super(options: StatusOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<StatusOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(StatusOption.projectId);
    final inUtc = commandConfig.value(StatusOption.utc);

    try {
      await RuntimeStatusCommands.showRuntimeStatus(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
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
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get the podlet status');
    }
  }
}

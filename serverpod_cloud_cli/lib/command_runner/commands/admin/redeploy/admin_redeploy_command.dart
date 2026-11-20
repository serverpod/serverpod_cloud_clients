import 'package:config/command.dart' show CommandContext;
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/redeploy/redeploy_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/redeploy/redeploy_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

enum AdminRedeployOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const AdminRedeployOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminRedeployCommand extends CloudCliCommand<AdminRedeployOption> {
  @override
  final name = 'redeploy';

  @override
  final description =
      'Trigger redeployment of a project using its current image.';

  AdminRedeployCommand({required super.logger})
    : super(options: AdminRedeployOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminRedeployOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(AdminRedeployOption.projectId);

    await renderCommand(
      output,
      operation: () => RedeployOperations.redeployProject(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const RedeployTextUi(),
    );
  }
}

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/admin/project_admin.dart';

enum AdminRedeployOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true));

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
  Future<void> runWithConfig(
    final Configuration<AdminRedeployOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(AdminRedeployOption.projectId);

    await ProjectAdminCommands.redeployProject(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
    );
  }
}

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/database_scaling/database_scaling_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/database_scaling/database_scaling_ui.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

enum AdminReconcileDatabaseScalingOption<V> implements OptionDefinition<V> {
  apply(
    FlagOption(
      argName: 'apply',
      helpText:
          'Push the recorded scaling to the database provider. '
          'Without this the pass only reports the drift it finds.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  projectId(
    MultiStringOption(
      argName: 'project-id',
      helpText:
          'Restrict the pass to these projects. '
          'Repeat or comma-separate. Defaults to every database.',
      valueHelp: 'project id',
      defaultsTo: [],
    ),
  );

  const AdminReconcileDatabaseScalingOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminReconcileDatabaseScalingCommand
    extends CloudCliCommand<AdminReconcileDatabaseScalingOption> {
  @override
  final name = 'reconcile-database-scaling';

  @override
  final description =
      'Reset the compute scaling of databases the provider reports '
      'differently from Serverpod Cloud.';

  AdminReconcileDatabaseScalingCommand({required super.logger})
    : super(options: AdminReconcileDatabaseScalingOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminReconcileDatabaseScalingOption> commandConfig,
    final CommandOutput output,
  ) async {
    final apply = commandConfig.value(
      AdminReconcileDatabaseScalingOption.apply,
    );
    final projectIds = commandConfig.value(
      AdminReconcileDatabaseScalingOption.projectId,
    );

    if (apply) {
      await confirmToContinue(
        output,
        message:
            'Reset the compute scaling of '
            '${projectIds.isEmpty ? 'every drifted database' : '${projectIds.length} project(s)'}? '
            'Each reset restarts the database compute endpoint.',
        defaultValue: false,
      );
    }

    await renderCommand(
      output,
      operation: () => DatabaseScalingOperations.reconcileComputeScaling(
        runner.serviceProvider.cloudApiClient,
        apply: apply,
        projectIds: projectIds,
      ),
      textOutputUi: ReconcileDatabaseScalingTextUi(
        apply: apply,
        projectCount: projectIds.length,
      ),
    );
  }
}

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show FormatOption;
import 'package:serverpod_cloud_cli/command_runner/commands/admin/plan/plan_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminPlanCommand extends CloudCliCommand {
  @override
  final name = 'plan';

  @override
  final description = 'Orb plan maintenance.';

  AdminPlanCommand({required super.logger}) {
    addSubcommand(AdminListOrbPlansCommand(logger: logger));
    addSubcommand(AdminUpdatePlanCommand(logger: logger));
  }
}

enum AdminListOrbPlansOption<V> implements OptionDefinition<V> {
  format(FormatOption());

  const AdminListOrbPlansOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListOrbPlansCommand
    extends CloudCliCommand<AdminListOrbPlansOption> {
  @override
  final name = 'list';

  @override
  final description = 'List maintainable Orb plans.';

  AdminListOrbPlansCommand({required super.logger})
    : super(options: AdminListOrbPlansOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminListOrbPlansOption> commandConfig,
  ) async {
    final format = commandConfig.value(AdminListOrbPlansOption.format);

    final output = CommandOutput(format: format, logger: logger);
    await renderCommand(
      output,
      operation: () => PlanAdminCommands.listOrbPlansOperation(
        runner.serviceProvider.cloudApiClient,
      ),
      textOutputUi: const StringColumnListWidget(heading: 'External Plan ID'),
    );
  }
}

enum AdminUpdatePlanOption<V> implements OptionDefinition<V> {
  externalPlanId(
    StringOption(
      argName: 'plan',
      argPos: 0,
      mandatory: true,
      helpText:
          'The external plan id. '
          'Can be passed as the first argument.',
    ),
  );

  const AdminUpdatePlanOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminUpdatePlanCommand extends CloudCliCommand<AdminUpdatePlanOption> {
  @override
  final name = 'update';

  @override
  final description = 'Trigger update of an Orb plan.';

  AdminUpdatePlanCommand({required super.logger})
    : super(options: AdminUpdatePlanOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminUpdatePlanOption> commandConfig,
  ) async {
    final externalPlanId = commandConfig.value(
      AdminUpdatePlanOption.externalPlanId,
    );

    await PlanAdminCommands.updateOrbPlan(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      externalPlanId: externalPlanId,
    );
  }
}

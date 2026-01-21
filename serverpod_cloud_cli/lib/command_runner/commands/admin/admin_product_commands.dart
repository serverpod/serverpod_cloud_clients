import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/commands/admin/product_admin.dart';

import '../../helpers/command_options.dart';

class AdminProductCommand extends CloudCliCommand {
  @override
  final name = 'product';

  @override
  final description = 'Product procurement administration.';

  AdminProductCommand({required super.logger}) {
    addSubcommand(AdminListProcuredCommand(logger: logger));
    addSubcommand(AdminProcurePlanCommand(logger: logger));
    addSubcommand(AdminCancelPlanCommand(logger: logger));
  }
}

enum AdminListProcuredOption<V> implements OptionDefinition<V> {
  user(UserEmailOption(argPos: 0, mandatory: true));

  const AdminListProcuredOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListProcuredCommand
    extends CloudCliCommand<AdminListProcuredOption> {
  @override
  final name = 'list-procured';

  @override
  final description = "List an owner's procured products.";

  AdminListProcuredCommand({required super.logger})
    : super(options: AdminListProcuredOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminListProcuredOption> commandConfig,
  ) async {
    final userEmail = commandConfig.value(AdminListProcuredOption.user);

    await ProductAdminCommands.listProcuredProducts(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      userEmail: userEmail,
    );
  }
}

enum AdminProcurePlanOption<V> implements OptionDefinition<V> {
  user(UserEmailOption(argPos: 0, mandatory: true)),
  productName(
    StringOption(
      argName: 'name',
      argAbbrev: 'n',
      argPos: 1,
      helpText:
          'The name of the plan to procure.'
          ' Can be passed as the second argument.',
      mandatory: true,
    ),
  ),
  productVersion(
    IntOption(
      argName: 'version',
      argAbbrev: 'v',
      argPos: 2,
      helpText:
          'The plan version (latest if unspecified).'
          ' Can be passed as the third argument.',
      min: 0,
    ),
  ),
  trialPeriod(
    IntOption(
      argName: 'trial-period',
      helpText:
          'Override the default trial period of the plan, in number of days.',
      min: 0,
    ),
  ),
  overrideChecks(
    FlagOption(
      argName: 'override',
      helpText: 'Override the product availability checks.',
      negatable: false,
      defaultsTo: false,
    ),
  );

  const AdminProcurePlanOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProcurePlanCommand extends CloudCliCommand<AdminProcurePlanOption> {
  @override
  final name = 'procure-plan';

  @override
  final description =
      'Procure a plan for a user.\n'
      'By specifying the override flag, the plan is procured '
      'even if locked or the owner lacks allowance.';

  AdminProcurePlanCommand({required super.logger})
    : super(options: AdminProcurePlanOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminProcurePlanOption> commandConfig,
  ) async {
    final userEmail = commandConfig.value(AdminProcurePlanOption.user);
    final productName = commandConfig.value(AdminProcurePlanOption.productName);
    final ver = commandConfig.optionalValue(
      AdminProcurePlanOption.productVersion,
    );
    final trialPeriod = commandConfig.optionalValue(
      AdminProcurePlanOption.trialPeriod,
    );
    final override = commandConfig.value(AdminProcurePlanOption.overrideChecks);

    await ProductAdminCommands.procurePlan(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      userEmail: userEmail,
      planName: productName,
      planVersion: ver,
      trialPeriodOverride: trialPeriod,
      overrideChecks: override,
    );
  }
}

enum AdminCancelPlanOption<V> implements OptionDefinition<V> {
  user(UserEmailOption(argPos: 0, mandatory: true)),
  terminateImmediately(
    FlagOption(
      argName: 'immediately',
      helpText: 'Terminate the subscription immediately.',
      negatable: false,
      defaultsTo: false,
    ),
  );

  const AdminCancelPlanOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminCancelPlanCommand extends CloudCliCommand<AdminCancelPlanOption> {
  @override
  final name = 'cancel-plan';

  @override
  final description = "Cancels a user's subscription.\n";

  AdminCancelPlanCommand({required super.logger})
    : super(options: AdminCancelPlanOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminCancelPlanOption> commandConfig,
  ) async {
    final userEmail = commandConfig.value(AdminCancelPlanOption.user);
    final terminateImmediately = commandConfig.value(
      AdminCancelPlanOption.terminateImmediately,
    );

    await ProductAdminCommands.cancelPlan(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      userEmail: userEmail,
      terminateImmediately: terminateImmediately,
    );
  }
}

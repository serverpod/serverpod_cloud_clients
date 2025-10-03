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
    addSubcommand(AdminProcureCommand(logger: logger));
  }
}

enum AdminListProcuredOption<V> implements OptionDefinition<V> {
  user(
    UserEmailOption(argPos: 0, mandatory: true),
  );

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

enum AdminProcureOption<V> implements OptionDefinition<V> {
  user(
    UserEmailOption(argPos: 0, mandatory: true),
  ),
  productName(
    StringOption(
      argName: 'name',
      argAbbrev: 'n',
      argPos: 1,
      helpText: 'The name of the product to procure.'
          ' Can be passed as the second argument.',
      mandatory: true,
    ),
  ),
  productVersion(
    IntOption(
      argName: 'version',
      argAbbrev: 'v',
      argPos: 2,
      helpText: 'The product version (latest if unspecified).'
          ' Can be passed as the third argument.',
      min: 0,
    ),
  ),
  overrideChecks(
    FlagOption(
      argName: 'override',
      helpText: 'Override product availability checks.',
      negatable: false,
      defaultsTo: false,
    ),
  );

  const AdminProcureOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProcureCommand extends CloudCliCommand<AdminProcureOption> {
  @override
  final name = 'procure';

  @override
  final description = 'Procure a product for an owner.\n'
      'By specifying the override flag, the product is procured '
      'even if locked or the owner lacks allowance.';

  AdminProcureCommand({required super.logger})
      : super(options: AdminProcureOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminProcureOption> commandConfig,
  ) async {
    final userEmail = commandConfig.value(AdminProcureOption.user);
    final productName = commandConfig.value(AdminProcureOption.productName);
    final ver = commandConfig.optionalValue(AdminProcureOption.productVersion);
    final override = commandConfig.value(AdminProcureOption.overrideChecks);

    await ProductAdminCommands.procureProduct(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      userEmail: userEmail,
      productName: productName,
      productVersion: ver,
      overrideChecks: override,
    );
  }
}

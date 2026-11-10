import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/billing_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/billing_admin_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminBillingCommand extends CloudCliCommand {
  @override
  final name = 'billing';

  @override
  final description = 'Billing administration.';

  AdminBillingCommand({required super.logger}) {
    addSubcommand(AdminReissueInvoiceCommand(logger: logger));
  }
}

enum AdminReissueInvoiceOption<V> implements OptionDefinition<V> {
  invoiceId(
    StringOption(
      argName: 'invoice-id',
      mandatory: true,
      helpText: 'The invoice id in the billing system.',
    ),
  );

  const AdminReissueInvoiceOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminReissueInvoiceCommand
    extends CloudCliCommand<AdminReissueInvoiceOption> {
  @override
  final name = 'reissue';

  @override
  final description =
      'Issue an invoice again. An incomplete customer address is recorded as an issue failure.';

  AdminReissueInvoiceCommand({required super.logger})
    : super(options: AdminReissueInvoiceOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminReissueInvoiceOption> commandConfig,
    final CommandOutput output,
  ) async {
    final invoiceId = commandConfig.value(AdminReissueInvoiceOption.invoiceId);

    await renderCommand(
      output,
      operation: () => BillingAdminOperations.reissueInvoice(
        runner.serviceProvider.cloudApiClient,
        invoiceId: invoiceId,
      ),
      textOutputUi: const ReissueInvoiceTextUi(),
    );
  }
}

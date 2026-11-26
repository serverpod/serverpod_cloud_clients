import 'package:config/command.dart' show CommandContext;
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
    addSubcommand(AdminRecordPaymentFailedCommand(logger: logger));
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
    final CommandContext<AdminReissueInvoiceOption, void> context,
    final CommandOutput output,
  ) async {
    final invoiceId = context.config.value(AdminReissueInvoiceOption.invoiceId);

    await renderCommand(
      output,
      operation: () => BillingAdminOperations.reissueInvoice(
        context.serviceProvider.cloudApiClient,
        invoiceId: invoiceId,
      ),
      textOutputUi: const ReissueInvoiceTextUi(),
    );
  }
}

enum AdminRecordPaymentFailedOption<V> implements OptionDefinition<V> {
  invoiceId(
    StringOption(
      argName: 'invoice-id',
      mandatory: true,
      helpText: 'The invoice id in the billing system.',
    ),
  );

  const AdminRecordPaymentFailedOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminRecordPaymentFailedCommand
    extends CloudCliCommand<AdminRecordPaymentFailedOption> {
  @override
  final name = 'record-payment-failed';

  @override
  final description =
      'Record a missed payment failure and run the payment-failed flow.';

  AdminRecordPaymentFailedCommand({required super.logger})
    : super(options: AdminRecordPaymentFailedOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminRecordPaymentFailedOption, void> context,
    final CommandOutput output,
  ) async {
    final invoiceId = context.config.value(
      AdminRecordPaymentFailedOption.invoiceId,
    );

    await renderCommand(
      output,
      operation: () => BillingAdminOperations.recordPaymentFailed(
        context.serviceProvider.cloudApiClient,
        invoiceId: invoiceId,
      ),
      textOutputUi: const RecordPaymentFailedTextUi(),
    );
  }
}

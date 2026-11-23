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
    addSubcommand(AdminRecordTrialEndedCommand(logger: logger));
    addSubcommand(AdminRecordTrialsEndedCommand(logger: logger));
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
    final Configuration<AdminRecordPaymentFailedOption> commandConfig,
    final CommandOutput output,
  ) async {
    final invoiceId = commandConfig.value(
      AdminRecordPaymentFailedOption.invoiceId,
    );

    await renderCommand(
      output,
      operation: () => BillingAdminOperations.recordPaymentFailed(
        runner.serviceProvider.cloudApiClient,
        invoiceId: invoiceId,
      ),
      textOutputUi: const RecordPaymentFailedTextUi(),
    );
  }
}

enum AdminRecordTrialEndedOption<V> implements OptionDefinition<V> {
  subscriptionId(
    StringOption(
      argName: 'subscription-id',
      mandatory: true,
      helpText: 'The subscription id in the billing system.',
    ),
  );

  const AdminRecordTrialEndedOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminRecordTrialEndedCommand
    extends CloudCliCommand<AdminRecordTrialEndedOption> {
  @override
  final name = 'record-trial-ended';

  @override
  final description = 'Record a missed trial end and run the trial-ended flow.';

  AdminRecordTrialEndedCommand({required super.logger})
    : super(options: AdminRecordTrialEndedOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminRecordTrialEndedOption> commandConfig,
    final CommandOutput output,
  ) async {
    final subscriptionId = commandConfig.value(
      AdminRecordTrialEndedOption.subscriptionId,
    );

    await confirmToContinue(
      output,
      message:
          'Are you sure you want to record the trial end of the subscription '
          '"$subscriptionId"? Its projects are suspended and its owner is '
          'emailed.',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => BillingAdminOperations.recordTrialEnded(
        runner.serviceProvider.cloudApiClient,
        subscriptionId: subscriptionId,
      ),
      textOutputUi: const RecordTrialEndedTextUi(),
    );
  }
}

enum AdminRecordTrialsEndedOption<V> implements OptionDefinition<V> {
  since(
    DateTimeOption(
      argName: 'since',
      mandatory: true,
      helpText:
          'The first trial end to include, such as 2026-11-05T00:00:00Z. '
          'A value without a time zone is read in the local time zone.',
    ),
  ),
  dryRun(
    FlagOption(
      argName: 'dry-run',
      helpText: 'List what would be recorded without recording it.',
      defaultsTo: false,
      negatable: false,
    ),
  );

  const AdminRecordTrialsEndedOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminRecordTrialsEndedCommand
    extends CloudCliCommand<AdminRecordTrialsEndedOption> {
  @override
  final name = 'record-trials-ended';

  @override
  final description =
      'Record the missed trial end of every subscription whose trial ended '
      'since a date, and run the trial-ended flow for each.';

  AdminRecordTrialsEndedCommand({required super.logger})
    : super(options: AdminRecordTrialsEndedOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminRecordTrialsEndedOption> commandConfig,
    final CommandOutput output,
  ) async {
    final since = commandConfig.value(AdminRecordTrialsEndedOption.since);
    final dryRun = commandConfig.value(AdminRecordTrialsEndedOption.dryRun);

    if (!dryRun) {
      await confirmToContinue(
        output,
        message:
            'Are you sure you want to record the trial end of every '
            'subscription whose trial ended since '
            '${since.toUtc().toIso8601String()}? '
            'Their projects are suspended and their owners are emailed.',
        defaultValue: false,
      );
    }

    await renderCommand(
      output,
      operation: () => BillingAdminOperations.recordTrialsEnded(
        runner.serviceProvider.cloudApiClient,
        since: since,
        dryRun: dryRun,
      ),
      textOutputUi: const RecordTrialsEndedTextUi(),
    );
  }
}

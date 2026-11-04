import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/billing_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/billing_admin_ui.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

class AdminBackfillSubscriptionStatesCommand
    extends CloudCliCommand<OptionDefinition> {
  @override
  final name = 'backfill-subscription-states';

  @override
  final description =
      'Start recording the first paid invoice of every active plan'
      ' subscription from the billing system.';

  AdminBackfillSubscriptionStatesCommand({required super.logger})
    : super(options: const []);

  @override
  Future<void> runWithOutput(
    final Configuration<OptionDefinition> commandConfig,
    final CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => BillingAdminOperations.backfillSubscriptionStates(
        runner.serviceProvider.cloudApiClient,
      ),
      textOutputUi: const BackfillSubscriptionStatesTextUi(),
    );
  }
}

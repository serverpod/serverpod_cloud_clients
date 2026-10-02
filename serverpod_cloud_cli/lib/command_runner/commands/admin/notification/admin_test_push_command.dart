import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/notification/notification_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/notification/notification_admin_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

enum AdminTestPushOption<V> implements OptionDefinition<V> {
  notificationType(
    StringOption(
      argName: 'type',
      argPos: 0,
      mandatory: true,
      helpText:
          'The push notification type to send an example of. '
          'Currently test or invoice-failed. '
          'Can be passed as the first argument.',
    ),
  );

  const AdminTestPushOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminTestPushCommand extends CloudCliCommand<AdminTestPushOption> {
  @override
  final name = 'test-push';

  @override
  final description = 'Push an example notification of a given type.';

  AdminTestPushCommand({required super.logger})
    : super(options: AdminTestPushOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminTestPushOption> commandConfig,
    final CommandOutput output,
  ) async {
    final notificationType = commandConfig.value(
      AdminTestPushOption.notificationType,
    );

    await renderCommand(
      output,
      operation: () => NotificationAdminOperations.pushNotification(
        runner.serviceProvider.cloudApiClient,
        notificationType: notificationType,
      ),
      textOutputUi: const PushNotificationTextUi(),
    );
  }
}

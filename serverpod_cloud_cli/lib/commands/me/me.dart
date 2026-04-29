import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class MeCommands {
  static Future<void> showCurrentUser(
    final Client cloudApiClient, {
    required final CommandLogger logger,
  }) async {
    final user = await cloudApiClient.users.readUser();

    final display = user.email ?? user.userAuthId ?? '';

    final table = TablePrinter(
      headers: ['User'],
      rows: [
        [display],
      ],
    );
    table.writeLines(logger.line);
  }
}

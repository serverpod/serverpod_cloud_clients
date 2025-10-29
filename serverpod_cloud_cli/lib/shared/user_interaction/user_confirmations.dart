import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import '../exceptions/exit_exceptions.dart';

/// User interactions that may be reused across commands.
abstract class UserConfirmations {
  /// Asks the user for confirmation to continue with a new project setup
  /// that may incur additional costs.
  ///
  /// Throws [UserAbortException] if the user does not confirm.
  static Future<void> confirmNewProjectCostAcceptance(
    final CommandLogger logger,
  ) async {
    final confirm = await logger.confirm(
      'Depending on your subscription, a new project may incur additional costs. Continue?',
      defaultValue: true,
    );

    if (!confirm) {
      logger.info('Setup cancelled.');
      throw UserAbortException();
    }
  }
}

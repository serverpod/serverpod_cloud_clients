import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DbCommands {
  static Future<void> wipeDatabase(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final bool skipConfirmation,
  }) async {
    if (!skipConfirmation) {
      final confirmed = await logger.confirm('''
WARNING: Deletes all tables and data in the database for project "$projectId".
This is a NON-REVERSIBLE action.
The server will error until a redeploy is performed.

Do you want to proceed?''', defaultValue: false);

      if (!confirmed) {
        logger.info('Database wipe cancelled.');
        return;
      }
    }

    final apiCloudClient = cloudApiClient;

    try {
      await logger.progress(
        'Wiping database for project "$projectId"...',
        newParagraph: true,
        () async {
          await apiCloudClient.database.wipeDatabase(cloudCapsuleId: projectId);
          return true;
        },
      );

      logger.success('Database wiped successfully.');
      logger.info('Redeploy is needed, run: scloud deploy');
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(e, stackTrace, 'Failed to wipe database');
    }
  }
}

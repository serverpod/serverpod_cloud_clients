import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DbCommands {
  static Future<void> wipeDatabase(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String baseCommand,
    required String projectId,
    required bool skipConfirmation,
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
      logger.info('Redeploy is needed, run: $baseCommand deploy');
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(e, stackTrace, 'Failed to wipe database');
    }
  }
}

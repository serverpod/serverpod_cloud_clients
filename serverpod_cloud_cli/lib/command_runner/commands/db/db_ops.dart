import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DbOperations {
  static Future<DatabaseConnection> getConnectionDetails(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      return await cloudApiClient.database.getConnectionDetails(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to get connection details',
      );
    }
  }

  static Future<String> createSuperUser(
    final Client cloudApiClient, {
    required final String projectId,
    required final String username,
  }) async {
    try {
      return await cloudApiClient.database.createSuperUser(
        cloudCapsuleId: projectId,
        username: username,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to create superuser',
      );
    }
  }

  static Future<String> resetPassword(
    final Client cloudApiClient, {
    required final String projectId,
    required final String username,
  }) async {
    try {
      return await cloudApiClient.database.resetDatabasePassword(
        cloudCapsuleId: projectId,
        username: username,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(e, stackTrace, 'Failed to reset password');
    }
  }

  static Future<Map<String, Object?>> wipeDatabase(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      await cloudApiClient.database.wipeDatabase(cloudCapsuleId: projectId);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(e, stackTrace, 'Failed to wipe database');
    }

    return {'projectId': projectId};
  }
}

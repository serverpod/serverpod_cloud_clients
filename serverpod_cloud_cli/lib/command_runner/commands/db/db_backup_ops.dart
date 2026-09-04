import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DbBackupOperations {
  static Future<DatabaseSnapshot> createSnapshot(
    final Client cloudApiClient, {
    required final String projectId,
    final String? name,
    final Duration? expireIn,
  }) async {
    final expiresAt = expireIn == null
        ? null
        : DateTime.now().toUtc().add(expireIn);

    try {
      return await cloudApiClient.database.createSnapshot(
        cloudCapsuleId: projectId,
        name: name,
        expiresAt: expiresAt,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create snapshot');
    }
  }

  static Future<List<DatabaseSnapshot>> listSnapshots(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      return await cloudApiClient.database.listSnapshots(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list snapshots');
    }
  }

  static Future<Map<String, Object?>> deleteSnapshot(
    final Client cloudApiClient, {
    required final String projectId,
    required final String snapshotId,
  }) async {
    try {
      await cloudApiClient.database.deleteSnapshot(
        cloudCapsuleId: projectId,
        snapshotId: snapshotId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to delete snapshot');
    }

    return {'snapshotId': snapshotId};
  }

  static Future<Map<String, Object?>> restoreSnapshot(
    final Client cloudApiClient, {
    required final String projectId,
    required final String snapshotId,
  }) async {
    try {
      await cloudApiClient.database.restoreFromSnapshot(
        cloudCapsuleId: projectId,
        snapshotId: snapshotId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to restore snapshot');
    }

    return {'projectId': projectId, 'snapshotId': snapshotId};
  }

  static Future<Map<String, Object?>> setSchedule(
    final Client cloudApiClient, {
    required final String projectId,
    required final BackupFrequency frequency,
    final int? day,
    final int? hour,
    final Duration? retention,
  }) async {
    final effectiveHour = hour ?? 0;
    final effectiveDay = switch (frequency) {
      BackupFrequency.daily => null,
      BackupFrequency.weekly || BackupFrequency.monthly => day ?? 1,
    };

    try {
      await cloudApiClient.database.setBackupSchedule(
        cloudCapsuleId: projectId,
        frequency: frequency,
        day: effectiveDay,
        hour: effectiveHour,
        retention: retention,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set backup schedule');
    }

    return {
      'projectId': projectId,
      'frequency': frequency,
      'day': effectiveDay,
      'hour': effectiveHour,
      'retention': retention,
      if (frequency == BackupFrequency.daily && day != null)
        'warning':
            'A day is not applicable to a daily schedule and is ignored.',
    };
  }

  static Future<Map<String, Object?>> getSchedule(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      final schedule = await cloudApiClient.database.getBackupSchedule(
        cloudCapsuleId: projectId,
      );
      return {'projectId': projectId, 'schedule': schedule};
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get backup schedule');
    }
  }

  static Future<Map<String, Object?>> disableSchedule(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      await cloudApiClient.database.setBackupSchedule(
        cloudCapsuleId: projectId,
        frequency: null,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to disable backup schedule');
    }

    return {'projectId': projectId};
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_ops.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';

/// The snapshots of a project, and the project's plan type when the listing is
/// empty and the plan therefore explains why.
typedef BackupSnapshotListing = ({
  List<DatabaseSnapshot> snapshots,
  PlanType? planType,
});

/// The backup schedule of a project, and the project's plan type when no
/// schedule is set and the plan therefore explains why.
typedef BackupScheduleView = ({
  String projectId,
  BackupSchedule? schedule,
  PlanType? planType,
});

abstract class DbBackupOperations {
  /// Creates a manual snapshot of the project's database.
  ///
  /// Throws [FailureException] if the project's plan does not include database
  /// backups, or if the request fails.
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
    } on ProcurementDeniedException catch (e, s) {
      throw _backupProcurementFailure(e, s, projectId: projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create snapshot');
    }
  }

  /// Lists the snapshots of the project's database.
  ///
  /// When there are no snapshots, the project's plan type is read as well, so
  /// that the caller can tell an empty listing apart from a plan without
  /// backups. It is null if the plan could not be determined.
  static Future<BackupSnapshotListing> listSnapshots(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    late final List<DatabaseSnapshot> snapshots;
    try {
      snapshots = await cloudApiClient.database.listSnapshots(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list snapshots');
    }

    return (
      snapshots: snapshots,
      planType: snapshots.isEmpty
          ? await _readPlanType(cloudApiClient, projectId: projectId)
          : null,
    );
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

  /// Restores the project's database from a snapshot.
  ///
  /// Throws [FailureException] if the project's plan does not include database
  /// backups, or if the request fails.
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
    } on ProcurementDeniedException catch (e, s) {
      throw _backupProcurementFailure(e, s, projectId: projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to restore snapshot');
    }

    return {'projectId': projectId, 'snapshotId': snapshotId};
  }

  /// Sets the automated backup schedule of the project's database.
  ///
  /// Throws [FailureException] if the project's plan does not include database
  /// backups, or if the request fails.
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
    } on ProcurementDeniedException catch (e, s) {
      throw _backupProcurementFailure(e, s, projectId: projectId);
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

  /// Reads the automated backup schedule of the project's database.
  ///
  /// When no schedule is set, the project's plan type is read as well, so that
  /// the caller can tell an unset schedule apart from a plan without backups.
  /// It is null if the plan could not be determined.
  static Future<BackupScheduleView> getSchedule(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    late final BackupSchedule? schedule;
    try {
      schedule = await cloudApiClient.database.getBackupSchedule(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get backup schedule');
    }

    return (
      projectId: projectId,
      schedule: schedule,
      planType: schedule == null
          ? await _readPlanType(cloudApiClient, projectId: projectId)
          : null,
    );
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

  /// The plan type of [projectId], or null if it could not be determined.
  ///
  /// The plan only refines a hint, so a failed lookup is not an error.
  static Future<PlanType?> _readPlanType(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      final subscription = await ProjectCommands.readSubscription(
        cloudApiClient,
        projectId: projectId,
      );
      return subscription?.planType;
    } on Exception {
      return null;
    }
  }

  static FailureException _backupProcurementFailure(
    final ProcurementDeniedException e,
    final StackTrace s, {
    required final String projectId,
  }) {
    if (e.reason != ProcurementDeniedReason.productNotAvailable) {
      return FailureException.nested(e, s, 'Database backup request denied');
    }

    return FailureException(
      error: e.message,
      hint:
          'Database backups are available on the Growth plan.\n'
          'To upgrade, visit: ${getProjectPlanUrl(projectId)}',
    );
  }
}

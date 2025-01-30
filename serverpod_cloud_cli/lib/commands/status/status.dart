import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'status_feature.dart';

/// Status subcommand implementations
abstract class StatusCommands {
  /// Subcommand to list the most recent deploy attempts.
  static Future<void> listDeployAttempts(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String cloudCapsuleId,
    required final int limit,
    final bool inUtc = false,
  }) async {
    final statuses = await StatusFeature.getDeployAttemptList(
      cloudApiClient,
      cloudCapsuleId: cloudCapsuleId,
      limit: limit,
    );

    final table = DeployStatusTable(inUtc: inUtc)..addRows(statuses);
    table.writeLines(logger.line);
  }

  /// Subcommand to show the status of a deployment attempt.
  /// If [outputOverallStatus] is true, only the overall status word
  /// is shown (e.g. "success").
  static Future<void> showDeploymentStatus(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String cloudCapsuleId,
    required final String attemptId,
    final bool inUtc = false,
    final bool outputOverallStatus = false,
  }) async {
    final stages = await StatusFeature.getDeployAttemptStatus(
      cloudApiClient,
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
    );

    if (outputOverallStatus) {
      final overallStatus = stages.last.stageStatus;
      logger.line(overallStatus.name);
      return;
    }

    final List<String> rows = [
      'Status of $cloudCapsuleId deploy $attemptId'
          ', started at ${stages.first.startedAt?.toTzString(inUtc, _numTimeStampChars)}:',
      ...stages.map(_generateStatusLine),
    ];

    for (final line in rows) {
      logger.line(line);
      logger.line('');
    }
  }

  static String _generateStatusLine(final DeployAttemptStage stage) {
    final mark = _getStatusMark(stage.stageStatus);
    final phrase = '${_getRocketStagePhrase(stage.stageType)}:';
    final status = _getStatusPhrase(stage);

    final rocket = stage.stageType == DeployStageType.service &&
            stage.stageStatus == DeployProgressStatus.success
        ? ' 🚀'
        : '';

    return '$mark  ${phrase.padRight(20)} $status$rocket';
  }

  static String _getStatusMark(final DeployProgressStatus status) {
    return switch (status) {
      DeployProgressStatus.unknown => '⬛',
      DeployProgressStatus.awaiting => '⬛',
      DeployProgressStatus.running => '…',
      DeployProgressStatus.success => '✅',
      DeployProgressStatus.failure => '❌',
      DeployProgressStatus.cancelled => '❌',
    };
  }

  static String _getRocketStagePhrase(final DeployStageType type) {
    return switch (type) {
      DeployStageType.upload => 'Booster liftoff',
      DeployStageType.build => 'Orbit acceleration',
      DeployStageType.deploy => 'Orbital insertion',
      DeployStageType.service => 'Pod commissioning',
    };
  }

  static String _getStatusPhrase(final DeployAttemptStage stage) {
    final stageName = _capitalize(stage.stageType.name);
    final verb = switch (stage.stageStatus) {
      DeployProgressStatus.unknown => '<unknown>',
      DeployProgressStatus.awaiting => 'awaiting...',
      DeployProgressStatus.running => 'running...',
      DeployProgressStatus.success => 'successful!',
      DeployProgressStatus.failure => 'failed! 💥',
      DeployProgressStatus.cancelled => 'cancelled.',
    };
    return '$stageName $verb${stage.statusInfo != null ? ' ${stage.statusInfo}' : ''}';
  }

  static _capitalize(final String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

const _numTimeStampChars = 19;

class DeployStatusTable extends TablePrinter {
  final bool inUtc;

  DeployStatusTable({this.inUtc = false})
      : super(headers: [
          '#',
          'Project',
          'Deploy Id',
          'Status',
          'Started',
          'Finished',
          'Info',
        ]);

  void addRows(final Iterable<DeployAttempt> attempts) {
    attempts.mapIndexed(_tableRowFromDeployAttempt).forEach(addRow);
  }

  List<String?> _tableRowFromDeployAttempt(
      final int index, final DeployAttempt attempt) {
    return [
      index.toString(),
      attempt.cloudCapsuleId,
      attempt.attemptId,
      attempt.status.name.toUpperCase(),
      attempt.startedAt?.toTzString(inUtc, _numTimeStampChars),
      attempt.endedAt?.toTzString(inUtc, _numTimeStampChars),
      attempt.statusInfo,
    ];
  }
}

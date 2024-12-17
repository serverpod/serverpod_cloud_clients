import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

abstract class StatusFeature {
  static Future<TablePrinter> getDeployAttemptsList(
    final Client cloudApiClient, {
    required final String environmentId,
    required final int limit,
    final bool inUtc = false,
  }) async {
    final statuses = await cloudApiClient.status.getDeployAttempts(
      cloudEnvironmentId: environmentId,
      limit: limit,
    );

    return DeployStatusTable(inUtc: inUtc)..addRows(statuses);
  }

  static Future<String> getDeploymentStatus(
    final Client cloudApiClient, {
    required final String environmentId,
    required final String attemptId,
    final bool inUtc = false,
  }) async {
    final stages = await cloudApiClient.status.getDeployAttemptStatus(
      cloudEnvironmentId: environmentId,
      attemptId: attemptId,
    );

    final List<String> rows = [
      'Status of $environmentId deploy $attemptId'
          ', started at ${stages.first.startTime?.toTzString(inUtc, _numTimeStampChars)}:',
      ...stages.map(_getStatusLine),
    ];

    return rows.expand((final r) => ['$r\n', '\n']).join();
  }

  static Future<String> getDeployAttemptId(
    final Client cloudApiClient, {
    required final String environmentId,
    required final int attemptNumber,
  }) async {
    return await cloudApiClient.status.getDeployAttemptId(
      cloudEnvironmentId: environmentId,
      attemptNumber: attemptNumber,
    );
  }

  static String _getStatusLine(final DeployAttemptStage stage) {
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
      DeployProgressStatus.pending => '⬛',
      DeployProgressStatus.created => '…',
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
      DeployProgressStatus.pending => 'pending...',
      DeployProgressStatus.created => 'pending...',
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
      attempt.cloudEnvironmentId,
      attempt.attemptId,
      attempt.status.name.toUpperCase(),
      attempt.startTime?.toTzString(inUtc, _numTimeStampChars),
      attempt.endTime?.toTzString(inUtc, _numTimeStampChars),
      attempt.statusInfo,
    ];
  }
}

import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/util/stream_util.dart';

/// Status subcommand implementations
abstract class StatusCommands {
  static const progressMessagePadLength = 40;

  /// Subcommand to list the most recent deploy attempts.
  static Future<void> listDeployAttempts(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String cloudCapsuleId,
    required final int limit,
    final bool inUtc = false,
  }) async {
    final statuses = await cloudApiClient.status.getDeployAttempts(
      cloudCapsuleId: cloudCapsuleId,
      limit: limit,
    );

    if (statuses.isEmpty) {
      logger.terminalCommand(
        message: 'No deployment status found. Run this command to deploy:',
        'scloud deploy',
      );
      return;
    }

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
    required final UuidValue attemptId,
    final bool inUtc = false,
    final bool outputOverallStatus = false,
  }) async {
    final stages = await cloudApiClient.status.getDeployAttemptStatus(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
    );

    if (outputOverallStatus) {
      final overallStatus = stages.last.stageStatus;
      logger.line(overallStatus.name);
      return;
    }

    final List<String> rows = [
      'Status of $cloudCapsuleId deployment $attemptId'
          ', started at ${stages.first.startedAt?.toTzString(inUtc, _numTimeStampChars)}:',
      '',
      ...stages.map(_generateStatusLine),
    ];

    for (final line in rows) {
      logger.line(line);
    }
  }

  static Future<void> tailDeploymentStatus(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String cloudCapsuleId,
    required final UuidValue attemptId,
    final bool inUtc = false,
    final bool skipUploadStage = false,
  }) async {
    final stageStream = cloudApiClient.status.tailDeployAttemptStatus(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
    );

    final stageStreams = SplitStreams<DeployStageType, DeployAttemptStage>(
      stageStream,
      DeployStageType.values,
      (final stage) => stage.stageType,
      (final stage) => stage.stageStatus.isFinal,
    );

    if (!skipUploadStage) {
      logger.line('Tracking $cloudCapsuleId deployment $attemptId');
      logger.line('(Press Ctrl+C to exit)');
      logger.line('');
    }

    final stageStatusTailer = _StageStatusTailer(
      logger: logger,
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
      stageStreams: stageStreams,
    );
    for (final stageType in DeployStageType.values) {
      if (skipUploadStage && stageType == DeployStageType.upload) {
        continue;
      }

      final stage = await stageStatusTailer.showStageProgress(stageType);
      if (stage.stageStatus == DeployProgressStatus.cancelled ||
          stage.stageStatus == DeployProgressStatus.failure) {
        break;
      }
    }
  }

  static String _generateStatusLine(final DeployAttemptStage stage) {
    final status = _getStatusPhrase(stage);

    final rocket =
        stage.stageType == DeployStageType.service &&
            stage.stageStatus == DeployProgressStatus.success
        ? ' 🚀'
        : '';

    return '$status$rocket';
  }

  static String _getStatusPhrase(final DeployAttemptStage stage) {
    final stageName = switch (stage.stageType) {
      DeployStageType.upload => 'Upload',
      DeployStageType.build => 'Cloud build',
      DeployStageType.deploy => 'Infra deploy',
      DeployStageType.service => 'Service rollout',
    };

    final verb = switch (stage.stageStatus) {
      DeployProgressStatus.unknown => '<unknown>',
      DeployProgressStatus.awaiting => 'awaiting...',
      DeployProgressStatus.running => 'running...',
      DeployProgressStatus.success => 'successful.',
      DeployProgressStatus.failure => 'failed. 💥',
      DeployProgressStatus.cancelled => 'cancelled.',
    };
    return '$stageName $verb';
  }
}

const _numTimeStampChars = 19;

class DeployStatusTable extends TablePrinter {
  final bool inUtc;

  DeployStatusTable({this.inUtc = false})
    : super(
        headers: [
          '#',
          'Project',
          'Deploy Id',
          'Status',
          'Started',
          'Finished',
          'Info',
        ],
      );

  void addRows(final Iterable<DeployAttempt> attempts) {
    attempts.mapIndexed(_tableRowFromDeployAttempt).forEach(addRow);
  }

  List<String?> _tableRowFromDeployAttempt(
    final int index,
    final DeployAttempt attempt,
  ) {
    return [
      index.toString(),
      attempt.cloudCapsuleId,
      attempt.attemptId,
      attempt.status?.name.toUpperCase(),
      attempt.startedAt?.toTzString(inUtc, _numTimeStampChars),
      attempt.endedAt?.toTzString(inUtc, _numTimeStampChars),
      attempt.statusInfo,
    ];
  }
}

extension FinalDeployProgressStatus on DeployProgressStatus {
  /// Returns true if this stage status is final, i.e. will not change anymore.
  bool get isFinal => switch (this) {
    DeployProgressStatus.cancelled ||
    DeployProgressStatus.failure ||
    DeployProgressStatus.success => true,
    DeployProgressStatus.unknown ||
    DeployProgressStatus.awaiting ||
    DeployProgressStatus.running => false,
  };
}

class _StageStatusTailer {
  final CommandLogger logger;
  final String cloudCapsuleId;
  final UuidValue attemptId;
  final SplitStreams<DeployStageType, DeployAttemptStage> stageStreams;

  _StageStatusTailer({
    required this.logger,
    required this.cloudCapsuleId,
    required this.attemptId,
    required this.stageStreams,
  });

  /// Shows the progress of a stage and returns the final stage status.
  /// If the input stream closes but was empty, the spinner is completed with a
  /// filler stage with unknown status, which is then returned.
  Future<DeployAttemptStage> showStageProgress(
    final DeployStageType stageType,
  ) async {
    final fallbackStream = withFallback(
      stageStreams.getStream(stageType),
      _fillerStage(stageType, DeployProgressStatus.unknown),
    );
    return await logger.progressStream(
      StatusCommands._generateStatusLine(
        _fillerStage(stageType, DeployProgressStatus.awaiting),
      ),
      fallbackStream,
      toMessage: StatusCommands._generateStatusLine,
      padRight: StatusCommands.progressMessagePadLength,
      isSuccess: (final stage) =>
          stage.stageStatus == DeployProgressStatus.success,
    );
  }

  DeployAttemptStage _fillerStage(
    final DeployStageType stageType,
    final DeployProgressStatus status,
  ) {
    return DeployAttemptStage(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
      stageType: stageType,
      stageStatus: status,
    );
  }
}

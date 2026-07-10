import 'package:async/async.dart' show StreamGroup;
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

    final displayStages = _combineRolloutStages(stages);

    if (outputOverallStatus) {
      final overallStatus = displayStages.last.stageStatus;
      logger.line(overallStatus.name);
      return;
    }

    final List<String> rows = [
      'Status of $cloudCapsuleId deployment $attemptId'
          ', started at ${stages.first.startedAt?.toTzString(inUtc, _numTimeStampChars)}:',
      '',
      ...displayStages.map(_generateStatusLine),
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
    for (final stageType in [DeployStageType.upload, DeployStageType.build]) {
      if (skipUploadStage && stageType == DeployStageType.upload) {
        continue;
      }

      final stage = await stageStatusTailer.showStageProgress(stageType);
      if (stage.stageStatus == DeployProgressStatus.cancelled ||
          stage.stageStatus == DeployProgressStatus.failure) {
        return;
      }
    }

    await stageStatusTailer._showRolloutProgress();
  }

  /// Combines the deploy and service stages into a single rollout stage,
  /// keeping other stages as-is.
  ///
  /// The rollout is successful only when both stages have succeeded;
  /// if either fails or is cancelled, so has the rollout.
  static List<DeployAttemptStage> _combineRolloutStages(
    final List<DeployAttemptStage> stages,
  ) {
    final rolloutStages = stages
        .where(
          (final stage) =>
              stage.stageType == DeployStageType.deploy ||
              stage.stageType == DeployStageType.service,
        )
        .toList();
    final otherStages = stages
        .where((final stage) => !rolloutStages.contains(stage))
        .toList();

    if (rolloutStages.isEmpty) {
      return otherStages;
    }

    final deployStatus = rolloutStages
        .lastWhereOrNull(
          (final stage) => stage.stageType == DeployStageType.deploy,
        )
        ?.stageStatus;
    final serviceStatus = rolloutStages
        .lastWhereOrNull(
          (final stage) => stage.stageType == DeployStageType.service,
        )
        ?.stageStatus;

    final combinedStage = rolloutStages.last.copyWith(
      stageType: DeployStageType.service,
      stageStatus: _combinedRolloutStatus(
        deployStatus ?? DeployProgressStatus.awaiting,
        serviceStatus ?? DeployProgressStatus.awaiting,
      ),
    );
    return [...otherStages, combinedStage];
  }

  /// Combines the statuses of the deploy and service stages into a single
  /// rollout status. The rollout is successful only when both stages have
  /// succeeded, and failed or cancelled if either stage is.
  static DeployProgressStatus _combinedRolloutStatus(
    final DeployProgressStatus deployStatus,
    final DeployProgressStatus serviceStatus,
  ) {
    const statusPriority = [
      DeployProgressStatus.failure,
      DeployProgressStatus.cancelled,
    ];
    for (final status in statusPriority) {
      if (deployStatus == status || serviceStatus == status) {
        return status;
      }
    }
    if (deployStatus == serviceStatus) {
      return deployStatus;
    }
    if (deployStatus == DeployProgressStatus.success ||
        serviceStatus == DeployProgressStatus.success ||
        deployStatus == DeployProgressStatus.running ||
        serviceStatus == DeployProgressStatus.running) {
      return DeployProgressStatus.running;
    }
    return DeployProgressStatus.awaiting;
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
      DeployStageType.deploy || DeployStageType.service => 'Rollout',
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

  /// Shows the progress of the combined rollout (deploy + service) stages
  /// as a single spinner and returns the final combined stage.
  ///
  /// The rollout succeeds only when both stages have succeeded; if either
  /// fails or is cancelled the rollout spinner completes as failed.
  Future<DeployAttemptStage> _showRolloutProgress() async {
    final fallbackStream = withFallback(
      _combinedRolloutStream(),
      _fillerStage(DeployStageType.service, DeployProgressStatus.unknown),
    );
    return await logger.progressStream(
      StatusCommands._generateStatusLine(
        _fillerStage(DeployStageType.service, DeployProgressStatus.awaiting),
      ),
      fallbackStream,
      toMessage: StatusCommands._generateStatusLine,
      padRight: StatusCommands.progressMessagePadLength,
      isSuccess: (final stage) =>
          stage.stageStatus == DeployProgressStatus.success,
    );
  }

  /// Merges the deploy and service stage streams into a single stream of
  /// synthetic stages carrying the combined rollout status. The stream ends
  /// when the combined status is final or both source streams have closed.
  Stream<DeployAttemptStage> _combinedRolloutStream() async* {
    var deployStatus = DeployProgressStatus.awaiting;
    var serviceStatus = DeployProgressStatus.awaiting;

    final merged = StreamGroup.merge([
      stageStreams.getStream(DeployStageType.deploy),
      stageStreams.getStream(DeployStageType.service),
    ]);

    await for (final stage in merged) {
      if (stage.stageType == DeployStageType.deploy) {
        deployStatus = stage.stageStatus;
      } else if (stage.stageType == DeployStageType.service) {
        serviceStatus = stage.stageStatus;
      }

      final combinedStatus = StatusCommands._combinedRolloutStatus(
        deployStatus,
        serviceStatus,
      );
      yield _fillerStage(DeployStageType.service, combinedStatus);
      if (combinedStatus.isFinal) {
        break;
      }
    }
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

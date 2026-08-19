import 'dart:io';

import 'package:async/async.dart' show StreamGroup;
import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/constants.dart' show numTimeStampChars;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/util/stream_util.dart';

/// Status subcommand implementations
abstract class StatusCommands {
  static const progressMessagePadLength = 40;

  /// Subcommand to list the most recent deploy attempts.
  static Future<void> listDeployAttempts(
    final Client cloudApiClient, {
    required final CommandOutput output,
    required final String cloudCapsuleId,
    required final int limit,
    final bool inUtc = false,
  }) async {
    final statuses = await cloudApiClient.status.getDeployAttempts(
      cloudCapsuleId: cloudCapsuleId,
      limit: limit,
    );

    if (statuses.isEmpty) {
      output.logger.terminalCommand(
        message: 'No deployment status found. Run this command to deploy:',
        'scloud deploy',
      );
      return;
    }

    final items = statuses
        .mapIndexed(
          (final index, final attempt) => DeploymentListItem(
            index: index,
            projectId: attempt.cloudCapsuleId,
            deployId: attempt.attemptId.toString(),
            status: attempt.status?.name,
            startedAt: attempt.startedAt,
            finishedAt: attempt.endedAt,
            info: attempt.statusInfo,
          ),
        )
        .toList();

    output.outputList(items, deploymentListSchema);
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
          ', started at ${stages.first.startedAt?.toTzString(inUtc, numTimeStampChars)}:',
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
    final Stream<void>? processSignalStreamOverride,
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

    final processSignalStream =
        processSignalStreamOverride ??
        ProcessSignal.sigint.watch().map((final _) {});

    final stageStatusTailer = _StageStatusTailer(
      logger: logger,
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
      stageStreams: stageStreams,
      processSignalStream: processSignalStream,
    );
    try {
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
    } on StreamInterruptedException {
      _logDeployTailInterruptGuidance(logger);
      throw UserAbortException();
    } finally {
      await stageStreams.cancel();
    }
  }

  static void _logDeployTailInterruptGuidance(final CommandLogger logger) {
    logger.info(
      'The deployment continues in Serverpod Cloud.',
      newParagraph: true,
    );
    logger.terminalCommand(
      'scloud deployment show',
      message: 'To view the deployment status, run this command:',
    );
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

class DeploymentListItem {
  final int index;
  final String projectId;
  final String deployId;
  final String? status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? info;

  const DeploymentListItem({
    required this.index,
    required this.projectId,
    required this.deployId,
    this.status,
    this.startedAt,
    this.finishedAt,
    this.info,
  });
}

final deploymentListSchema = OutputSchemaObject<DeploymentListItem>([
  OutputSchemaField(
    name: 'index',
    label: '#',
    value: (final item) => item.index,
  ),
  OutputSchemaField(
    name: 'projectId',
    label: 'Project',
    value: (final item) => item.projectId,
  ),
  OutputSchemaField(
    name: 'deployId',
    label: 'Deploy Id',
    value: (final item) => item.deployId,
  ),
  OutputSchemaField(
    name: 'status',
    label: 'Status',
    value: (final item) => item.status?.toUpperCase(),
  ),
  OutputSchemaField(
    name: 'startedAt',
    label: 'Started',
    value: (final item) => item.startedAt,
  ),
  OutputSchemaField(
    name: 'finishedAt',
    label: 'Finished',
    value: (final item) => item.finishedAt,
  ),
  OutputSchemaField(
    name: 'info',
    label: 'Info',
    value: (final item) => item.info,
  ),
]);

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
  final Stream<void> processSignalStream;

  _StageStatusTailer({
    required this.logger,
    required this.cloudCapsuleId,
    required this.attemptId,
    required this.stageStreams,
    required this.processSignalStream,
  });

  /// Shows the progress of a stage and returns the final stage status.
  /// If the input stream closes but was empty, the spinner is completed with a
  /// filler stage with unknown status, which is then returned.
  Future<DeployAttemptStage> showStageProgress(
    final DeployStageType stageType,
  ) async {
    final fallbackStream = withFallback(
      cancelOnInterrupt(stageStreams.getStream(stageType), processSignalStream),
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
      cancelOnInterrupt(
        stageStreams.getStream(DeployStageType.deploy),
        processSignalStream,
      ),
      cancelOnInterrupt(
        stageStreams.getStream(DeployStageType.service),
        processSignalStream,
      ),
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

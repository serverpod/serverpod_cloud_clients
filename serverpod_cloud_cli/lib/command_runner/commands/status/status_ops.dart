import 'dart:async';
import 'dart:io';

import 'package:async/async.dart' show StreamGroup;
import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';
import 'package:serverpod_cloud_cli/util/stream_util.dart';

/// Status subcommand implementations
abstract class StatusCommands {
  static const progressMessagePadLength = 40;

  static Future<CapsuleRuntimeStatus> fetchRuntimeStatus(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      return await cloudApiClient.status.getCapsuleRuntimeStatus(
        cloudCapsuleId: projectId,
      );
    } on CapsuleStatusUnavailableException {
      throw FailureException(
        error: 'Could not retrieve the podlet status for project "$projectId".',
        hint:
            'The status service is temporarily unavailable — '
            'try again shortly.',
      );
    } on NotFoundException {
      throw FailureException(error: 'Project "$projectId" was not found.');
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get the podlet status');
    }
  }

  static Future<({DateTime? startedAt, List<DeployAttemptStage> stages})>
  fetchDeployAttemptStatus(
    final Client cloudApiClient, {
    required final String cloudCapsuleId,
    required final UuidValue attemptId,
  }) async {
    final stages = await cloudApiClient.status.getDeployAttemptStatus(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
    );

    return (
      startedAt: stages.first.startedAt,
      stages: _combineRolloutStages(stages),
    );
  }

  static String statusLine(final DeployAttemptStage stage) =>
      _generateStatusLine(stage);

  static Future<void> tailDeploymentStatus(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String baseCommand,
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
      cloudApiClient: cloudApiClient,
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

        final stage = stageType == DeployStageType.build
            ? await stageStatusTailer.showBuildStageProgress()
            : await stageStatusTailer.showStageProgress(stageType);
        if (stage.stageStatus == DeployProgressStatus.cancelled ||
            stage.stageStatus == DeployProgressStatus.failure) {
          _logStageFailureGuidance(logger, baseCommand, stage);
          throw FailureException(
            reason: '${stage.stageType.name} stage ${stage.stageStatus.name}',
          );
        }
      }

      await stageStatusTailer._showRolloutProgress();
    } on StreamInterruptedException {
      _logDeployTailInterruptGuidance(logger, baseCommand);
      throw UserAbortException();
    } finally {
      await stageStreams.cancel();
    }
  }

  static void _logDeployTailInterruptGuidance(
    final CommandLogger logger,
    final String baseCommand,
  ) {
    logger.info(
      'The deployment continues in Serverpod Cloud.',
      newParagraph: true,
    );
    logger.terminalCommand(
      '$baseCommand deployment show',
      message: 'To view the deployment status, run this command:',
    );
  }

  static void _logStageFailureGuidance(
    final CommandLogger logger,
    final String baseCommand,
    final DeployAttemptStage stage,
  ) {
    if (stage.stageType == DeployStageType.build &&
        stage.stageStatus == DeployProgressStatus.failure) {
      logger.terminalCommand(
        '$baseCommand deployment build-log',
        message: 'To view the build log again, run this command:',
        newParagraph: true,
      );
      return;
    }

    logger.terminalCommand(
      '$baseCommand deployment show',
      message: 'To view the deployment status, run this command:',
      newParagraph: true,
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
  final Client cloudApiClient;
  final String cloudCapsuleId;
  final UuidValue attemptId;
  final SplitStreams<DeployStageType, DeployAttemptStage> stageStreams;
  final Stream<void> processSignalStream;

  _StageStatusTailer({
    required this.logger,
    required this.cloudApiClient,
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
      ).padRight(StatusCommands.progressMessagePadLength),
      fallbackStream,
      toMessage: StatusCommands._generateStatusLine,
      padRight: StatusCommands.progressMessagePadLength,
      isSuccess: (final stage) =>
          stage.stageStatus == DeployProgressStatus.success,
    );
  }

  /// Shows the progress of the build stage and returns the final stage status.
  ///
  /// On an interactive terminal, the build log is streamed live into a
  /// scrolling section below the heading while the stage is running: cleared
  /// on success, kept in full on failure or cancellation. On a non-interactive
  /// terminal (CI, piped output) this falls back to [showStageProgress]
  /// unchanged, since cursor-movement output would corrupt non-TTY logs.
  Future<DeployAttemptStage> showBuildStageProgress() async {
    if (!logger.inlineTerminal.hasTerminal) {
      return showStageProgress(DeployStageType.build);
    }

    final fallbackStream = withFallback(
      cancelOnInterrupt(
        stageStreams.getStream(DeployStageType.build),
        processSignalStream,
      ),
      _fillerStage(DeployStageType.build, DeployProgressStatus.unknown),
    );

    final section = ScrollingSection(
      terminal: logger.inlineTerminal,
      heading: StatusCommands._generateStatusLine(
        _fillerStage(DeployStageType.build, DeployProgressStatus.awaiting),
      ).padRight(StatusCommands.progressMessagePadLength),
      successMessage: StatusCommands._generateStatusLine(
        _fillerStage(DeployStageType.build, DeployProgressStatus.success),
      ).padRight(StatusCommands.progressMessagePadLength),
      captureOutput: true,
    );

    StreamSubscription<LogRecord>? logSubscription;
    var lastStage = _fillerStage(
      DeployStageType.build,
      DeployProgressStatus.unknown,
    );
    try {
      await for (final stage in fallbackStream) {
        lastStage = stage;
        section.updateHeading(
          StatusCommands._generateStatusLine(
            stage,
          ).padRight(StatusCommands.progressMessagePadLength),
        );
        if (logSubscription == null &&
            stage.stageStatus == DeployProgressStatus.running) {
          logSubscription = cloudApiClient.logs
              .tailBuildLog(
                cloudCapsuleId: cloudCapsuleId,
                attemptId: attemptId,
              )
              .listen(
                (final record) => section.appendLine(record.content),
                // Best-effort: a failure to fetch build-log lines should not
                // derail the stage tailing that drives the heading and the
                // final failure/success outcome.
                onError: (final _, final _) {},
              );
        }
      }
    } finally {
      await logSubscription?.cancel();
      if (lastStage.stageStatus == DeployProgressStatus.success) {
        section.clear();
      } else {
        section.keep(full: true);
      }
    }
    return lastStage;
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
      ).padRight(StatusCommands.progressMessagePadLength),
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

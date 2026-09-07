import 'dart:async';
import 'dart:io';

import 'package:async/async.dart' show StreamGroup;
import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployment_command_names.dart';
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
      startedAt: stages.firstOrNull?.startedAt,
      stages: _combineRolloutStages(stages),
    );
  }

  static String statusLine(final DeployAttemptStage stage) =>
      _generateStatusLine(stage);

  static Future<void> tailDeploymentStatus(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String baseCommand,
    required String cloudCapsuleId,
    required UuidValue attemptId,
    DeploymentCommandNames commandNames = DeploymentCommandNames.public,
    bool inUtc = false,
    bool skipUploadStage = false,
    Stream<void>? processSignalStreamOverride,
    int maxReconnectRetries = 3,
    Duration reconnectDelay = const Duration(seconds: 2),
  }) async {
    final stageStatuses = <DeployStageType, DeployProgressStatus>{};
    final stageStream = reconnectStream<DeployAttemptStage>(
      (final _) => _tailDeploymentStatusFrom(
        cloudApiClient,
        cloudCapsuleId: cloudCapsuleId,
        attemptId: attemptId,
        stageStatuses: stageStatuses,
      ),
      shouldRetry: isRetryableMethodStreamDisconnect,
      maxRetries: maxReconnectRetries,
      retryDelay: reconnectDelay,
    );

    final stageStreams = SplitStreams<DeployStageType, DeployAttemptStage>(
      stageStream,
      DeployStageType.values,
      (stage) => stage.stageType,
      (stage) => stage.stageStatus.isFinal,
    );

    if (!skipUploadStage) {
      logger.line('Tracking $cloudCapsuleId deployment $attemptId');
      logger.line('(Press Ctrl+C to exit)');
      logger.line('');
    }

    final processSignalStream =
        processSignalStreamOverride ?? ProcessSignal.sigint.watch().map((_) {});

    final stageStatusTailer = _StageStatusTailer(
      logger: logger,
      cloudApiClient: cloudApiClient,
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
      stageStreams: stageStreams,
      processSignalStream: processSignalStream,
      maxReconnectRetries: maxReconnectRetries,
      reconnectDelay: reconnectDelay,
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
          _logStageFailureGuidance(logger, baseCommand, commandNames, stage);
          throw FailureException(
            reason: '${stage.stageType.name} stage ${stage.stageStatus.name}',
          );
        }
      }

      await stageStatusTailer._showRolloutProgress();
    } on MethodStreamException catch (error, stackTrace) {
      if (!isRetryableMethodStreamDisconnect(error)) {
        rethrow;
      }
      _logDeployTailInterruptGuidance(logger, baseCommand, commandNames);
      throw FailureException.nested(
        error,
        stackTrace,
        'Timed out while reconnecting to the deployment status stream.',
      );
    } on StreamInterruptedException {
      _logDeployTailInterruptGuidance(logger, baseCommand, commandNames);
      throw UserAbortException();
    } finally {
      await stageStreams.cancel();
    }
  }

  static Stream<DeployAttemptStage> _tailDeploymentStatusFrom(
    final Client cloudApiClient, {
    required final String cloudCapsuleId,
    required final UuidValue attemptId,
    required final Map<DeployStageType, DeployProgressStatus> stageStatuses,
  }) {
    final stream = cloudApiClient.status.tailDeployAttemptStatus(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
    );
    return stream.where((final stage) {
      final previousStatus = stageStatuses[stage.stageType];
      final isRegression =
          previousStatus == DeployProgressStatus.running &&
          (stage.stageStatus == DeployProgressStatus.awaiting ||
              stage.stageStatus == DeployProgressStatus.unknown);
      if (previousStatus == stage.stageStatus ||
          (previousStatus?.isFinal ?? false) ||
          isRegression) {
        return false;
      }
      stageStatuses[stage.stageType] = stage.stageStatus;
      return true;
    });
  }

  static void _logDeployTailInterruptGuidance(
    CommandLogger logger,
    String baseCommand,
    DeploymentCommandNames commandNames,
  ) {
    logger.info(
      'The deployment continues in Serverpod Cloud.',
      newParagraph: true,
    );
    logger.terminalCommand(
      '$baseCommand ${commandNames.show}',
      message: 'To view the deployment status, run this command:',
    );
  }

  static void _logStageFailureGuidance(
    CommandLogger logger,
    String baseCommand,
    DeploymentCommandNames commandNames,
    DeployAttemptStage stage,
  ) {
    if (stage.stageType == DeployStageType.build &&
        stage.stageStatus == DeployProgressStatus.failure) {
      logger.terminalCommand(
        '$baseCommand ${commandNames.log}',
        message: 'To view the build log again, run this command:',
        newParagraph: true,
      );
      return;
    }

    logger.terminalCommand(
      '$baseCommand ${commandNames.show}',
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
    List<DeployAttemptStage> stages,
  ) {
    final rolloutStages = stages
        .where(
          (stage) =>
              stage.stageType == DeployStageType.deploy ||
              stage.stageType == DeployStageType.service,
        )
        .toList();
    final otherStages = stages
        .where((stage) => !rolloutStages.contains(stage))
        .toList();

    if (rolloutStages.isEmpty) {
      return otherStages;
    }

    final deployStatus = rolloutStages
        .lastWhereOrNull((stage) => stage.stageType == DeployStageType.deploy)
        ?.stageStatus;
    final serviceStatus = rolloutStages
        .lastWhereOrNull((stage) => stage.stageType == DeployStageType.service)
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
    DeployProgressStatus deployStatus,
    DeployProgressStatus serviceStatus,
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

  static String _generateStatusLine(DeployAttemptStage stage) {
    final status = _getStatusPhrase(stage);

    final rocket =
        stage.stageType == DeployStageType.service &&
            stage.stageStatus == DeployProgressStatus.success
        ? ' 🚀'
        : '';

    return '$status$rocket';
  }

  static String _getStatusPhrase(DeployAttemptStage stage) {
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
  final int maxReconnectRetries;
  final Duration reconnectDelay;

  _StageStatusTailer({
    required this.logger,
    required this.cloudApiClient,
    required this.cloudCapsuleId,
    required this.attemptId,
    required this.stageStreams,
    required this.processSignalStream,
    required this.maxReconnectRetries,
    required this.reconnectDelay,
  });

  /// Shows the progress of a stage and returns the final stage status.
  /// If the input stream closes but was empty, the spinner is completed with a
  /// filler stage with unknown status, which is then returned.
  Future<DeployAttemptStage> showStageProgress(
    DeployStageType stageType,
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
      isSuccess: (stage) => stage.stageStatus == DeployProgressStatus.success,
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
          final emittedRecordIds = <String>{};
          logSubscription =
              reconnectStream<LogRecord>(
                (_) => cloudApiClient.logs
                    .tailBuildLog(
                      cloudCapsuleId: cloudCapsuleId,
                      attemptId: attemptId,
                    )
                    .where((record) => emittedRecordIds.add(record.recordId)),
                shouldRetry: isRetryableMethodStreamDisconnect,
                maxRetries: maxReconnectRetries,
                retryDelay: reconnectDelay,
              ).listen(
                (record) => section.appendLine(record.content),
                onError: (_, _) {},
              );
        }
      }
    } finally {
      await logSubscription?.cancel();
      section.finish(
        success: lastStage.stageStatus == DeployProgressStatus.success,
      );
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
      isSuccess: (stage) => stage.stageStatus == DeployProgressStatus.success,
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
    DeployStageType stageType,
    DeployProgressStatus status,
  ) {
    return DeployAttemptStage(
      cloudCapsuleId: cloudCapsuleId,
      attemptId: attemptId,
      stageType: stageType,
      stageStatus: status,
    );
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/command_names.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DeploymentCommands {
  static Future<void> tailDeployment(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String baseCommand,
    required final String projectId,
    required final bool inUtc,
    final CommandNames commandNames = CommandNames.public,
    final String? deploymentArg,
  }) async {
    try {
      final attemptId = await getDeployAttemptId(
        cloudApiClient,
        baseCommand: baseCommand,
        commandNames: commandNames,
        projectId: projectId,
        deploymentArg: deploymentArg,
      );

      await StatusCommands.tailDeploymentStatus(
        cloudApiClient,
        logger: logger,
        baseCommand: baseCommand,
        commandNames: commandNames,
        cloudCapsuleId: projectId,
        attemptId: attemptId,
        inUtc: inUtc,
      );
    } on UserAbortException {
      rethrow;
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get deployment status');
    }
  }

  static Future<Map<String, Object?>> fetchDeploymentStatus(
    final Client cloudApiClient, {
    required final String baseCommand,
    required final String projectId,
    final CommandNames commandNames = CommandNames.public,
    final String? deploymentArg,
  }) async {
    try {
      final attemptId = await getDeployAttemptId(
        cloudApiClient,
        baseCommand: baseCommand,
        commandNames: commandNames,
        projectId: projectId,
        deploymentArg: deploymentArg,
      );
      final snapshot = await StatusCommands.fetchDeployAttemptStatus(
        cloudApiClient,
        cloudCapsuleId: projectId,
        attemptId: attemptId,
      );
      return {
        'projectId': projectId,
        'attemptId': attemptId,
        'startedAt': snapshot.startedAt,
        'stages': snapshot.stages,
      };
    } on FailureException {
      rethrow;
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get deployment status');
    }
  }

  static Future<List<Map<String, Object?>>> listDeployAttemptsOperation(
    Client cloudApiClient, {
    required String cloudCapsuleId,
    required int limit,
  }) async {
    late List<DeployAttempt> statuses;
    try {
      statuses = await cloudApiClient.status.getDeployAttempts(
        cloudCapsuleId: cloudCapsuleId,
        limit: limit,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get deployments list');
    }

    return deploymentListRows(statuses);
  }

  /// Resolves [deploymentArg], a deployment uuid or sequence number where 0
  /// means the latest, to a deploy attempt id.
  ///
  /// Throws [FailureException] if no such deployment exists.
  static Future<UuidValue> getDeployAttemptId(
    final Client cloudApiClient, {
    required final String baseCommand,
    required final CommandNames commandNames,
    required final String projectId,
    final String? deploymentArg,
  }) async {
    final deployment = deploymentArg ?? '0';
    final attemptNumber = int.tryParse(deployment);
    if (attemptNumber == null) {
      try {
        return UuidValue.withValidation(deployment);
      } on FormatException catch (_) {
        throw FailureException(
          error: 'The requested resource did not exist.',
          hint: 'Validate the attempt id is correct.',
        );
      }
    }
    try {
      return await cloudApiClient.status.getDeployAttemptId(
        cloudCapsuleId: projectId,
        attemptNumber: attemptNumber,
      );
    } on NotFoundException catch (_) {
      if (deployment == '0') {
        throw FailureException(
          error: 'No deployment status found.',
          hint: 'Run this command to deploy: $baseCommand deploy',
        );
      }
      throw FailureException(
        error: 'No such deployment status found.',
        hint:
            'Run this command to see recent deployments: '
            '$baseCommand ${commandNames.deploymentList}',
      );
    }
  }
}

List<Map<String, Object?>> deploymentListRows(List<DeployAttempt> statuses) {
  return [
    for (final (index, attempt) in statuses.indexed)
      {
        'index': index,
        'projectId': attempt.cloudCapsuleId,
        'deployId': attempt.attemptId.toString(),
        'status': attempt.status?.name.toUpperCase(),
        'startedAt': attempt.startedAt,
        'finishedAt': attempt.endedAt,
        'info': attempt.statusInfo,
      },
  ];
}

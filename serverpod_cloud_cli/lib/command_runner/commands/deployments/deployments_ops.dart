import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployment_command_names.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/logs_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class DeploymentCommands {
  static Future<void> tailDeployment(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String baseCommand,
    required final String projectId,
    required final bool inUtc,
    final DeploymentCommandNames commandNames = DeploymentCommandNames.public,
    final String? deploymentArg,
  }) async {
    try {
      final attemptId = await _getDeployAttemptId(
        cloudApiClient,
        baseCommand,
        commandNames,
        projectId,
        deploymentArg,
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
    final DeploymentCommandNames commandNames = DeploymentCommandNames.public,
    final String? deploymentArg,
  }) async {
    try {
      final attemptId = await _getDeployAttemptId(
        cloudApiClient,
        baseCommand,
        commandNames,
        projectId,
        deploymentArg,
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

  static Future<List<LogRecord>> fetchBuildLog(
    final Client cloudApiClient, {
    required final String baseCommand,
    required final DeploymentCommandNames commandNames,
    required final String projectId,
    final String? deploymentArg,
  }) async {
    try {
      final attemptId = await _getDeployAttemptId(
        cloudApiClient,
        baseCommand,
        commandNames,
        projectId,
        deploymentArg,
      );

      return await LogsOperations.fetchBuildLog(
        cloudApiClient,
        projectId: projectId,
        attemptId: attemptId,
      );
    } on FailureException {
      rethrow;
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get build log');
    }
  }

  static Future<Map<String, Object?>> setBuildSecret(
    final Client cloudApiClient, {
    required final String projectId,
    required final String name,
    required final String value,
    required final BuildSecretType buildSecretType,
  }) async {
    try {
      await cloudApiClient.secrets.upsertBuildSecret(
        cloudCapsuleId: projectId,
        secretKey: name,
        secretValue: value,
        buildSecretType: buildSecretType,
      );
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set build secret');
    }

    return {'name': name};
  }

  static Future<List<String>> listBuildSecretsOperation(
    Client cloudApiClient, {
    required String projectId,
  }) async {
    try {
      return await cloudApiClient.secrets.listBuild(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list build secrets');
    }
  }

  static Future<Map<String, Object?>> unsetBuildSecret(
    final Client cloudApiClient, {
    required final String projectId,
    required final String name,
  }) async {
    try {
      await cloudApiClient.secrets.deleteBuild(
        cloudCapsuleId: projectId,
        key: name,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to remove the build secret');
    }

    return {'name': name};
  }

  static Future<UuidValue> _getDeployAttemptId(
    Client cloudApiClient,
    String baseCommand,
    DeploymentCommandNames commandNames,
    String projectId,
    String? deploymentArg,
  ) async {
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
            '$baseCommand ${commandNames.list}',
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

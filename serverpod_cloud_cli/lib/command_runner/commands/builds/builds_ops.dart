import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/logs_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/command_names.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class BuildsOperations {
  static Future<List<LogRecord>> fetchBuildLog(
    final Client cloudApiClient, {
    required final String baseCommand,
    required final CommandNames commandNames,
    required final String projectId,
    final String? deploymentArg,
  }) async {
    try {
      final attemptId = await DeploymentCommands.getDeployAttemptId(
        cloudApiClient,
        baseCommand: baseCommand,
        commandNames: commandNames,
        projectId: projectId,
        deploymentArg: deploymentArg,
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
    final Client cloudApiClient, {
    required final String projectId,
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
}

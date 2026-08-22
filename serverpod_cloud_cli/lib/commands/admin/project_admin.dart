import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class ProjectAdminCommands {
  static Future<List<ProjectInfo>> listProjectsOperation(
    final Client cloudApiClient, {
    final bool includeArchived = false,
  }) async {
    return cloudApiClient.adminProjects.listProjectsInfo(
      includeArchived: includeArchived,
      includeLatestDeployAttemptTime: true,
    );
  }

  static Future<void> redeployProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    try {
      await cloudApiClient.adminProjects.redeployCapsule(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to redeploy project');
    }

    logger.success(
      'Redeployment triggered for project: $projectId',
      newParagraph: true,
    );
  }

  static Future<void> deleteProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    try {
      await cloudApiClient.adminProjects.deleteProject(
        cloudProjectId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to delete the project failed',
      );
    }

    logger.success('Deleted the project "$projectId".', newParagraph: true);
  }
}

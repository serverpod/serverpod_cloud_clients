import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_list_row.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ops.dart'
    show deploymentListRows;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class ProjectAdminCommands {
  static Stream<AdminProjectListRow> listProjectsOperation(
    Client cloudApiClient, {
    bool includePaymentsStatus = false,
    bool includeArchived = false,
  }) {
    return cloudApiClient.adminProjects
        .listAdminProjectsInfo(
          includeArchived: includeArchived,
          includePaymentsStatus: includePaymentsStatus,
          includeLatestDeployAttemptTime: true,
        )
        .map(
          (final info) => AdminProjectListRow.fromAdminProjectInfo(
            info,
            includePaymentsStatus: includePaymentsStatus,
          ),
        )
        .handleError((final error, final stackTrace) {
          if (error is Exception) {
            throw FailureException.nested(
              error,
              stackTrace,
              'Request to list projects failed',
            );
          }
          Error.throwWithStackTrace(error, stackTrace);
        });
  }

  static Future<List<Map<String, Object?>>> listDeployAttemptsOperation(
    final Client cloudApiClient, {
    required final String projectId,
    required final int limit,
  }) async {
    final statuses = await cloudApiClient.adminProjects.getDeployAttempts(
      cloudCapsuleId: projectId,
      limit: limit,
    );
    return deploymentListRows(statuses);
  }

  static Future<Map<String, Object?>> redeployProject(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      await cloudApiClient.adminProjects.redeployCapsule(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to redeploy project');
    }

    return {'projectId': projectId};
  }

  static Future<Map<String, Object?>> deleteProject(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
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

    return {'projectId': projectId};
  }

  static Future<Map<String, Object?>> changeProjectOwner(
    final Client cloudApiClient, {
    required final String projectId,
    required final String ownerEmail,
  }) async {
    try {
      final user = await cloudApiClient.adminUsers.getUser(email: ownerEmail);
      final newOwnerId = user.ownerId;
      if (newOwnerId == null) {
        throw FailureException(
          error: 'User "$ownerEmail" has no owner (not fully registered).',
        );
      }

      await cloudApiClient.adminProjects.changeProjectOwner(
        cloudProjectId: projectId,
        newOwnerId: newOwnerId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to change the project owner');
    }

    return {'projectId': projectId, 'ownerEmail': ownerEmail};
  }

  static Future<Map<String, Object?>> updateProjectPlan(
    final Client cloudApiClient, {
    required final String projectId,
    required final PlanType planType,
  }) async {
    try {
      await cloudApiClient.adminProjects.updateProjectProfile(
        cloudProjectId: projectId,
        profile: ProjectProfileUpdate(planType: planType),
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to update the project plan');
    }

    return {'projectId': projectId, 'planType': planType.name};
  }
}

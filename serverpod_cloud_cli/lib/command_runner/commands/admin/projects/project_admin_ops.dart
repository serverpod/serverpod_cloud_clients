import 'package:ground_control_client/ground_control_client.dart'
    show
        AdminProjectInfo,
        Client,
        InvalidValueException,
        NotFoundException,
        PlanType,
        ProjectListFilter,
        ProjectProfileUpdate;
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_list_row.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class ProjectAdminCommands {
  static Stream<AdminProjectListRow> listProjectsOperation(
    Client cloudApiClient, {
    bool includePaymentsStatus = false,
    bool includeArchived = false,
    ProjectListFilter? filter,
  }) {
    return cloudApiClient.adminProjects
        .listAdminProjectsInfo(
          includeArchived: includeArchived,
          includePaymentsStatus: includePaymentsStatus,
          includeLatestDeployAttemptTime: true,
          filter: filter,
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

  static Future<AdminProjectInfo> getProjectStatusOperation(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      return await cloudApiClient.adminProjects.getProjectStatus(
        cloudProjectId: projectId,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to read project status');
    }
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

  static Future<Map<String, Object?>> suspendProject(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      final project = await cloudApiClient.adminProjects.suspendProject(
        cloudProjectId: projectId,
      );
      return {'projectId': projectId, 'status': project.status.name};
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to suspend the project failed',
      );
    }
  }

  static Future<Map<String, Object?>> reactivateProject(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      final project = await cloudApiClient.adminProjects.reactivateProject(
        cloudProjectId: projectId,
      );
      return {'projectId': projectId, 'status': project.status.name};
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to reactivate the project failed',
      );
    }
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

  /// Sets [grant] on [projectId] to [amount].
  ///
  /// The project id is used as the capsule id.
  static Future<Map<String, Object?>> setGrant(
    final Client cloudApiClient, {
    required final String projectId,
    required final String grant,
    required final int amount,
  }) async {
    try {
      await cloudApiClient.adminGrants.setCapsuleGrant(
        cloudCapsuleId: projectId,
        grant: grant,
        amount: amount,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set the project grant');
    }

    return {'projectId': projectId, 'grant': grant, 'amount': amount};
  }

  static Future<Map<String, Object?>> reprocureExistingProject(
    final Client cloudApiClient, {
    required final String projectId,
    required final PlanType planType,
  }) async {
    try {
      final subscriptionId = await cloudApiClient.adminProjects
          .reprocureExistingProject(
            cloudProjectId: projectId,
            profile: ProjectProfileUpdate(planType: planType),
          );
      return {
        'projectId': projectId,
        'planType': planType.name,
        'subscriptionId': subscriptionId.uuid,
      };
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to re-procure the project');
    }
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/plan_features.dart';

abstract class UserCommands {
  static Future<List<User>> listUsersOperation(
    Client cloudApiClient, {
    required String projectId,
  }) {
    return cloudApiClient.users.listUsersInProject(cloudProjectId: projectId);
  }

  /// Invites the user with [email] to the project with [assignRoleNames].
  ///
  /// Throws [FailureException] if the user is not found, the project's plan
  /// does not include inviting users, or the request fails.
  static Future<Map<String, Object?>> inviteUser(
    final Client cloudApiClient, {
    required final String projectId,
    required final String email,
    required final List<String> assignRoleNames,
  }) async {
    try {
      await cloudApiClient.projects.inviteUser(
        cloudProjectId: projectId,
        email: email,
        assignRoleNames: assignRoleNames,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on ProcurementDeniedException catch (e, s) {
      throw planFeatureDeniedFailure(
        e,
        s,
        feature: PlanFeature.userInvites,
        projectId: projectId,
        failureMessage: 'Failed to invite user to project',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to invite user to project');
    }

    return {'roles': assignRoleNames};
  }

  static Future<Map<String, Object?>> revokeUser(
    final Client cloudApiClient, {
    required final String projectId,
    required final String email,
    final List<String> unassignRoleNames = const [],
    final bool unassignAllRoles = false,
  }) async {
    final List<String> actuallyUnassigned;
    try {
      actuallyUnassigned = await cloudApiClient.projects.revokeUser(
        cloudProjectId: projectId,
        email: email,
        unassignRoleNames: unassignRoleNames,
        unassignAllRoles: unassignAllRoles,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to revoke user from project');
    }

    return {
      'unassigned': actuallyUnassigned,
      'unassignAllRoles': unassignAllRoles,
    };
  }
}

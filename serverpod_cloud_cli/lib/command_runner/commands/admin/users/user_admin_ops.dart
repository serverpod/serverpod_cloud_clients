import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class UserAdminCommands {
  static Future<List<Map<String, Object?>>> listUsersOperation(
    Client cloudApiClient, {
    String? projectId,
    UserAccountStatus? ofAccountStatus,
    bool includeArchived = false,
  }) async {
    final users = await cloudApiClient.adminUsers.listUsers(
      cloudProjectId: projectId,
      ofAccountStatus: ofAccountStatus,
      includeArchived: includeArchived,
    );

    final userPlanMap = <String, String>{};
    for (final user in users) {
      switch (user.accountStatus) {
        case UserAccountStatus.registered:
          final procuredProducts = await cloudApiClient.adminProcurement
              .listProcuredProducts(userEmail: user.email);
          final procuredPlans = procuredProducts
              .where((p) => p.$2 == 'PlanProduct')
              .map((p) => p.$1);
          userPlanMap[user.email] = procuredPlans.join(', ');
        case UserAccountStatus.invited:
          userPlanMap[user.email] = '';
      }
    }

    return [
      for (final user in users)
        {
          'email': user.email,
          'accountStatus': user.accountStatus,
          'createdAt': user.createdAt,
          'archivedAt': user.archivedAt,
          'subscribedPlans': [
            for (final plan in (userPlanMap[user.email] ?? '').split(', '))
              if (plan.isNotEmpty) plan,
          ],
        },
    ];
  }

  static Future<void> inviteUser(
    final Client cloudApiClient, {
    required final String email,
  }) async {
    try {
      await cloudApiClient.adminUsers.inviteUser(email: email);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to invite user');
    }
  }

  static Future<Map<String, Object?>> attachUserToProject(
    final Client cloudApiClient, {
    required final String projectId,
    required final String email,
    required final List<ProjectRole> assignRoles,
  }) async {
    try {
      await cloudApiClient.adminUsers.attachUser(
        cloudProjectId: projectId,
        email: email,
        assignRoles: assignRoles,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to attach user to project');
    }

    return {
      'roles': [for (final role in assignRoles) role.name],
    };
  }

  static Future<Map<String, Object?>> detachUserFromProject(
    final Client cloudApiClient, {
    required final String projectId,
    required final String email,
    final List<ProjectRole> unassignRoles = const [],
    final bool unassignAllRoles = false,
  }) async {
    final List<String> actuallyUnassigned;
    try {
      actuallyUnassigned = await cloudApiClient.adminUsers.detachUser(
        cloudProjectId: projectId,
        email: email,
        unassignRoles: unassignRoles,
        unassignAllRoles: unassignAllRoles,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to detach user from project');
    }

    return {'unassigned': actuallyUnassigned};
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class UserAdminCommands {
  static Future<List<Map<String, Object?>>> listUsersOperation(
    final Client cloudApiClient, {
    final String? projectId,
    final UserAccountStatus? ofAccountStatus,
    final bool includeArchived = false,
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
              .where((final p) => p.$2 == 'PlanProduct')
              .map((final p) => p.$1);
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
    required final CommandLogger logger,
    required final String email,
  }) async {
    try {
      await cloudApiClient.adminUsers.inviteUser(email: email);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to invite user');
    }

    logger.success('User invited to Serverpod Cloud.', newParagraph: true);
  }
}

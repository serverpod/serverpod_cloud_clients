import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

abstract class UserAdminCommands {
  static Future<void> listUsers(
    final Client cloudApiClient, {
    required final CommandOutput output,
    final bool inUtc = false,
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

    final timezoneName = inUtc ? 'UTC' : 'local';

    output.outputList(
      users,
      OutputSchemaObject<User>([
        OutputSchemaField(
          name: 'email',
          label: 'User',
          value: (final user) => user.email,
        ),
        OutputSchemaField(
          name: 'accountStatus',
          label: 'Account status',
          value: (final user) => user.accountStatus,
        ),
        OutputSchemaField(
          name: 'createdAt',
          label: 'Created at ($timezoneName)',
          value: (final user) => user.createdAt,
        ),
        OutputSchemaField(
          name: 'archivedAt',
          label: 'Archived at ($timezoneName)',
          value: (final user) => user.archivedAt,
        ),
        OutputSchemaField(
          name: 'subscribedPlans',
          label: 'Subscribed Plans',
          value: (final user) => [
            for (final plan in (userPlanMap[user.email] ?? '').split(', '))
              if (plan.isNotEmpty) plan,
          ],
        ),
      ]),
    );
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

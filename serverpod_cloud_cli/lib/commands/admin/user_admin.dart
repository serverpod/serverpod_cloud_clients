import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class UserAdminCommands {
  static Future<void> listUsers(
    final Client cloudApiClient, {
    required final CommandLogger logger,
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
      final rowKey = user.email ?? user.userAuthId ?? '';
      switch (user.accountStatus) {
        case UserAccountStatus.registered:
          final userEmail = user.email;
          final userAuthId = user.userAuthId;
          if (userEmail != null && userEmail.isNotEmpty) {
            final procuredProducts = await cloudApiClient.adminProcurement
                .listProcuredProducts(userEmail: userEmail);
            final procuredPlans = procuredProducts
                .where((final p) => p.$2 == 'PlanProduct')
                .map((final p) => p.$1);
            userPlanMap[rowKey] = procuredPlans.join(', ');
          } else if (userAuthId != null && userAuthId.isNotEmpty) {
            final procuredProducts = await cloudApiClient.adminProcurement
                .listProcuredProducts(userAuthId: userAuthId);
            final procuredPlans = procuredProducts
                .where((final p) => p.$2 == 'PlanProduct')
                .map((final p) => p.$1);
            userPlanMap[rowKey] = procuredPlans.join(', ');
          } else {
            userPlanMap[rowKey] = '';
          }
          break;
        case UserAccountStatus.invited:
          userPlanMap[rowKey] = '';
          break;
      }
    }

    final timezoneName = inUtc ? 'UTC' : 'local';

    final table = TablePrinter(
      headers: [
        'User',
        'Account status',
        'Created at ($timezoneName)',
        'Archived at ($timezoneName)',
        'Subscribed Plans',
      ],
      rows: users.map(
        (final user) => [
          user.email ?? user.userAuthId ?? '',
          user.accountStatus.toString(),
          user.createdAt.toTzString(inUtc, 19),
          user.archivedAt?.toTzString(inUtc, 19),
          userPlanMap[user.email ?? user.userAuthId ?? ''] ?? '',
        ],
      ),
    );
    table.writeLines(logger.line);
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

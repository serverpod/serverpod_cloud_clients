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
      switch (user.accountStatus) {
        case UserAccountStatus.registered:
          final procuredProducts = await cloudApiClient.adminProcurement
              .listProcuredProducts(userEmail: user.email);
          final procuredPlans = procuredProducts
              .where((final p) => p.$2 == 'PlanProduct')
              .map((final p) => p.$1);
          userPlanMap[user.email] = procuredPlans.join(', ');
          break;
        case UserAccountStatus.invited:
          userPlanMap[user.email] = '';
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
          user.email,
          user.accountStatus.toString(),
          user.createdAt.toTzString(inUtc, 19),
          user.archivedAt?.toTzString(inUtc, 19),
          userPlanMap[user.email] ?? '',
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

  static Future<void> inviteHackathonUser(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String email,
  }) async {
    try {
      await cloudApiClient.hackathon.inviteUser(email: email);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to invite hackathon user');
    }

    logger.success(
      'User invited to the 2025 Serverpod Hackathon.',
      newParagraph: true,
    );
  }

  static Future<void> listHackathonUsers(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final bool includeWithoutProjects,
    final bool inUtc = false,
  }) async {
    final users = await cloudApiClient.adminUsers.listHackathonUsers(
      includeWithoutProjects: includeWithoutProjects,
    );

    final timezoneName = inUtc ? 'UTC' : 'local';

    final table = TablePrinter(
      headers: [
        'User',
        'Account status',
        'Created at ($timezoneName)',
        'Archived at ($timezoneName)',
        'Projects',
      ],
      rows: users.entries.map(
        (final e) => [
          e.key.email,
          e.key.accountStatus.toString(),
          e.key.createdAt.toTzString(inUtc, 19),
          e.key.archivedAt?.toTzString(inUtc, 19),
          e.value.map((final p) => p.project.cloudProjectId).join(', '),
        ],
      ),
    );
    table.writeLines(logger.line);
  }

  static Future<void> sendSingleHackathonThankyou(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String email,
  }) async {
    await cloudApiClient.adminUsers.sendHackathonThankyouEmail(email: email);
    logger.success(
      'Hackathon thank-you email sent to $email.',
      newParagraph: true,
    );
  }

  static Future<void> sendHackathonThankyous(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final bool includeWithoutProjects,
  }) async {
    final users = await cloudApiClient.adminUsers.listHackathonUsers(
      includeWithoutProjects: includeWithoutProjects,
    );

    logger.init('Sending Hackathon thank-you emails to ${users.length} users.');
    for (final user in users.entries) {
      await cloudApiClient.adminUsers.sendHackathonThankyouEmail(
        email: user.key.email,
      );
      logger.line(user.key.email);
    }
    logger.success('Emails successfully sent!', newParagraph: true);
  }
}

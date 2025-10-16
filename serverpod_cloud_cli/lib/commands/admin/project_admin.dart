import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

abstract class ProjectAdminCommands {
  static Future<void> listProjects(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final bool inUtc = false,
    final bool includeArchived = false,
  }) async {
    final projects = await cloudApiClient.adminProjects.listProjects(
      includeArchived: includeArchived,
    );

    final timezoneName = inUtc ? 'UTC' : 'local';

    final table = TablePrinter(
      headers: [
        'Project Id',
        'Created at ($timezoneName)',
        'Archived at ($timezoneName)',
        'Owner',
        'Users',
      ],
      rows: projects.map((final p) => [
            p.cloudProjectId,
            p.createdAt.toTzString(inUtc, 19),
            p.archivedAt?.toTzString(inUtc, 19),
            p.owner?.user?.email ?? '',
            _formatProjectUsers(p),
          ]),
    );
    table.writeLines(logger.line);
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

  static String _formatProjectUsers(final Project project) {
    return project.roles?.map(
          (final r) {
            final memberships = r.memberships;
            if (memberships == null) return '';

            final users = memberships.map((final m) => m.user?.email).nonNulls;
            if (users.isEmpty) return '';

            return '${r.name}: ${users.join(', ')}';
          },
        ).join('; ') ??
        '';
  }
}

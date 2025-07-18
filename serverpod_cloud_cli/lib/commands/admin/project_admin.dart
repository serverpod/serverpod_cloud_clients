import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
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
        'Owners',
      ],
      rows: projects.map((final p) => [
            p.cloudProjectId,
            p.createdAt.toTzString(inUtc, 19),
            p.archivedAt?.toTzString(inUtc, 19),
            _formatProjectOwners(p),
          ]),
    );
    table.writeLines(logger.line);
  }

  static String _formatProjectOwners(final Project project) {
    return project.roles
            ?.map(
              (final r) => '${r.name}: ${(r.memberships ?? []).map(
                    (final m) => m.user?.email,
                  ).join(', ')}',
            )
            .join('; ') ??
        '';
  }
}

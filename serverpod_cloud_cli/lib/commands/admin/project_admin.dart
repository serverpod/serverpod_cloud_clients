import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
abstract class ProjectAdminCommands {
  static Future<void> listProjects(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final bool inUtc = false,
    final bool includeArchived = false,
  }) async {
    final projects = await cloudApiClient.adminProjects.listProjectsInfo(
      includeArchived: includeArchived,
      includeLatestDeployAttemptTime: true,
    );

    final timezoneName = inUtc ? 'UTC' : 'local';

    logger.outputTable(
      headers: [
        'Project Id',
        'Created At ($timezoneName)',
        'Archived At ($timezoneName)',
        'Last Deploy Attempt',
        'Owner',
        'Users',
      ],
      rows: [
        for (final p in projects)
          [
            p.project.cloudProjectId,
            p.project.createdAt.toTzString(inUtc, 19),
            p.project.archivedAt?.toTzString(inUtc, 19),
            p.latestDeployAttemptTime?.timestamp?.toTzString(inUtc, 19),
            p.project.owner?.user?.email ?? '',
            _formatProjectUsers(p.project),
          ],
      ],
    );
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

  static Future<void> deleteProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

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

    logger.success('Deleted the project "$projectId".', newParagraph: true);
  }

  static String _formatProjectUsers(final Project project) {
    return project.roles
            ?.map((final r) {
              final memberships = r.memberships;
              if (memberships == null) return '';

              final users = memberships
                  .map((final m) => m.user?.email)
                  .nonNulls;
              if (users.isEmpty) return '';

              return '${r.name}: ${users.join(', ')}';
            })
            .join('; ') ??
        '';
  }
}

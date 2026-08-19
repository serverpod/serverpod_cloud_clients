import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

abstract class ProjectAdminCommands {
  static Future<void> listProjects(
    final Client cloudApiClient, {
    required final CommandOutput output,
    final bool inUtc = false,
    final bool includeArchived = false,
  }) async {
    final projects = await cloudApiClient.adminProjects.listProjectsInfo(
      includeArchived: includeArchived,
      includeLatestDeployAttemptTime: true,
    );

    final timezoneName = inUtc ? 'UTC' : 'local';

    output.outputList(
      projects,
      OutputSchemaObject<ProjectInfo>([
        OutputSchemaField(
          name: 'projectId',
          label: 'Project Id',
          value: (final p) => p.project.cloudProjectId,
        ),
        OutputSchemaField(
          name: 'createdAt',
          label: 'Created At ($timezoneName)',
          value: (final p) => p.project.createdAt,
        ),
        OutputSchemaField(
          name: 'archivedAt',
          label: 'Archived At ($timezoneName)',
          value: (final p) => p.project.archivedAt,
        ),
        OutputSchemaField(
          name: 'lastDeployAttemptAt',
          label: 'Last Deploy Attempt',
          value: (final p) => p.latestDeployAttemptTime?.timestamp,
        ),
        OutputSchemaField(
          name: 'ownerEmail',
          label: 'Owner',
          value: (final p) => p.project.owner?.user?.email,
        ),
        OutputSchemaField(
          name: 'users',
          label: 'Users',
          value: (final p) => _formatProjectUsers(p.project),
        ),
      ]),
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

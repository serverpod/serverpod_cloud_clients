import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_ops.dart';

abstract class RedeployOperations {
  static Future<Map<String, Object?>> redeployProject(
    final Client cloudApiClient, {
    required final String projectId,
  }) {
    return ProjectAdminCommands.redeployProject(
      cloudApiClient,
      projectId: projectId,
    );
  }
}

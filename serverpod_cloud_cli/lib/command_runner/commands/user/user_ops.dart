import 'package:ground_control_client/ground_control_client.dart';

abstract class UserCommands {
  static Future<List<User>> listUsersOperation(
    final Client cloudApiClient, {
    required final String projectId,
  }) {
    return cloudApiClient.users.listUsersInProject(cloudProjectId: projectId);
  }
}

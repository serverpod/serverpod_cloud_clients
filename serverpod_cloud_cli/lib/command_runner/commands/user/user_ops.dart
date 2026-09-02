import 'package:ground_control_client/ground_control_client.dart';

abstract class UserCommands {
  static Future<List<User>> listUsersOperation(
    Client cloudApiClient, {
    required String projectId,
  }) {
    return cloudApiClient.users.listUsersInProject(cloudProjectId: projectId);
  }
}

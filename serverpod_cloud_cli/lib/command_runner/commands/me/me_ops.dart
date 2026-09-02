import 'package:ground_control_client/ground_control_client.dart';

abstract class MeCommands {
  static Future<List<User>> showCurrentUserOperation(
    Client cloudApiClient,
  ) async {
    final user = await cloudApiClient.users.readUser();
    return [user];
  }
}

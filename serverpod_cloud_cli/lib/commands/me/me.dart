import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

class CurrentUserInfo {
  final String email;

  const CurrentUserInfo({required this.email});
}

abstract class MeCommands {
  static Future<void> showCurrentUser(
    final Client cloudApiClient, {
    required final CommandOutput output,
  }) async {
    final user = await cloudApiClient.users.readUser();
    final info = CurrentUserInfo(email: user.email);

    output.outputObject(
      info,
      OutputSchemaObject<CurrentUserInfo>([
        OutputSchemaField(
          name: 'email',
          label: 'Email',
          value: (final item) => item.email,
        ),
      ]),
    );
  }
}

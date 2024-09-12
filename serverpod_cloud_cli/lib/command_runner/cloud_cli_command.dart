import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

abstract class CloudCliCommand extends BetterCommand {
  final Logger logger;
  CloudCliCommand({required this.logger})
      : super(
          logInfo: (final String message) => logger.info(message),
          wrapTextColumn: logger.wrapTextColumn,
        );

  /// Gets a [Client] for the Serverpod Cloud.
  /// Will contain the authentication if the user is authenticated.
  Future<Client> getClient({
    required final String localStoragePath,
    required final String serverAddress,
  }) async {
    final cloudClient = Client(
      serverAddress,
      authenticationKeyManager: CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: localStoragePath,
      ),
    );
    return cloudClient;
  }
}

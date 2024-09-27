import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

/// A service provider for the Serverpod Cloud CLI.
/// [initialize] should be called before first use.
/// [shutdown] should be called after last use.
class CloudCliServiceProvider {
  late GlobalConfiguration _globalConfiguration;
  late Logger _logger;
  Client? _cloudApiClient;

  CloudCliServiceProvider();

  void initialize({
    required final GlobalConfiguration globalConfiguration,
    required final Logger logger,
  }) {
    _globalConfiguration = globalConfiguration;
    _logger = logger;
  }

  void shutdown() {
    _cloudApiClient?.close();
    _cloudApiClient = null;
  }

  /// Gets a [Client] for the Serverpod Cloud.
  /// Will contain the authentication if the user is authenticated.
  ///
  /// The client is cached and will be reused for subsequent calls.
  Client get cloudApiClient {
    final localCloudApiClient = _cloudApiClient;
    if (localCloudApiClient != null) {
      return localCloudApiClient;
    }

    final localStoragePath = _globalConfiguration.authDir;
    final serverAddress = _globalConfiguration.apiServer;
    final address =
        serverAddress.endsWith('/') ? serverAddress : '$serverAddress/';

    final cloudApiClient = Client(
      address,
      authenticationKeyManager: CliAuthenticationKeyManager(
        logger: _logger,
        localStoragePath: localStoragePath,
      ),
    );

    _cloudApiClient = cloudApiClient;
    return cloudApiClient;
  }
}

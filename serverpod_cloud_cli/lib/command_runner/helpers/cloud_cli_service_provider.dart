import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'file_uploader_factory.dart';

/// A service provider for the Serverpod Cloud CLI.
/// [initialize] should be called before first use.
/// [shutdown] should be called after last use.
class CloudCliServiceProvider {
  final Client Function(GlobalConfiguration globalCfg)? _apiClientFactory;
  final FileUploaderFactory _fileUploaderFactory;

  late GlobalConfiguration _globalConfiguration;
  late CommandLogger _logger;

  Client? _cloudApiClient;

  CloudCliServiceProvider({
    final Client Function(GlobalConfiguration globalCfg)? apiClientFactory,
    final FileUploaderFactory? fileUploaderFactory,
  })  : _apiClientFactory = apiClientFactory,
        _fileUploaderFactory = fileUploaderFactory ?? _createGcsFileUploader;

  void initialize({
    required final GlobalConfiguration globalConfiguration,
    required final CommandLogger logger,
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

    final Client cloudApiClient;
    if (_apiClientFactory != null) {
      cloudApiClient = _apiClientFactory(_globalConfiguration);
    } else {
      final localStoragePath = _globalConfiguration.scloudDir;
      final serverAddress = _globalConfiguration.apiServer;
      final address =
          serverAddress.endsWith('/') ? serverAddress : '$serverAddress/';

      final authTokenOverride = _globalConfiguration.authToken;
      final cloudDataOverride = authTokenOverride != null
          ? ServerpodCloudData(authTokenOverride)
          : null;

      cloudApiClient = Client(
        address,
        authenticationKeyManager: CliAuthenticationKeyManager(
          logger: _logger,
          localStoragePath: localStoragePath.path,
          cloudDataOverride: cloudDataOverride,
        ),
        connectionTimeout: _globalConfiguration.connectionTimeout,
      );
    }

    _cloudApiClient = cloudApiClient;
    return cloudApiClient;
  }

  FileUploaderFactory get fileUploaderFactory => _fileUploaderFactory;
}

FileUploaderClient _createGcsFileUploader(
  final String uploadDescription,
) {
  return GoogleCloudStorageUploader(uploadDescription);
}

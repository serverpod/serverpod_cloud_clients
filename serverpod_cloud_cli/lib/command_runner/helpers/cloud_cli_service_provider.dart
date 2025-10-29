import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/scloud_settings.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'file_uploader_factory.dart';

/// A service provider for the Serverpod Cloud CLI.
/// [initialize] should be called before first use.
/// [shutdown] should be called after last use.
class CloudCliServiceProvider {
  final Client Function(GlobalConfiguration globalCfg)? _apiClientFactory;
  final FileUploaderFactory _fileUploaderFactory;

  bool _initialized = false;
  late GlobalConfiguration _globalConfiguration;
  late CommandLogger _logger;

  Client? _cloudApiClient;
  ScloudSettings? _scloudSettings;

  CloudCliServiceProvider({
    final Client Function(GlobalConfiguration globalCfg)? apiClientFactory,
    final FileUploaderFactory? fileUploaderFactory,
  })  : _apiClientFactory = apiClientFactory,
        _fileUploaderFactory = fileUploaderFactory ?? _createGcsFileUploader;

  bool get initialized => _initialized;

  void initialize({
    required final GlobalConfiguration globalConfiguration,
    required final CommandLogger logger,
  }) {
    if (_initialized) {
      throw StateError('CloudCliServiceProvider already initialized');
    }
    _initialized = true;
    _globalConfiguration = globalConfiguration;
    _logger = logger;
  }

  void shutdown() {
    _cloudApiClient?.close();
    _cloudApiClient = null;
    _initialized = false; // enables re-initialization in test runs
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
          ? ServerpodCloudAuthData(authTokenOverride)
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

  ScloudSettings get scloudSettings => _scloudSettings ??= ScloudSettings(
        localStoragePath: _globalConfiguration.scloudDir.path,
      );
}

FileUploaderClient _createGcsFileUploader(
  final String uploadDescription,
) {
  return GoogleCloudStorageUploader(uploadDescription);
}

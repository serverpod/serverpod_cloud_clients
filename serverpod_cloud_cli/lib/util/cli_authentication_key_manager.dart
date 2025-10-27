import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:ground_control_client/ground_control_client.dart';

extension IsAuthenticated on AuthenticationKeyManager {
  Future<bool> get isAuthenticated async => await get() != null;
}

class CliAuthenticationKeyManager extends AuthenticationKeyManager {
  final CommandLogger _logger;
  final String _localStoragePath;
  ServerpodCloudAuthData? _cloudData;

  CliAuthenticationKeyManager({
    required final CommandLogger logger,
    required final String localStoragePath,
    final ServerpodCloudAuthData? cloudDataOverride,
  })  : _localStoragePath = localStoragePath,
        _logger = logger,
        _cloudData = cloudDataOverride;

  @override
  Future<String?> get() async {
    final cloudData = _cloudData;
    if (cloudData != null) {
      return cloudData.token;
    }

    _cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
      localStoragePath: _localStoragePath,
      logger: _logger,
    );

    return _cloudData?.token;
  }

  @override
  Future<void> put(final String key) async {
    _cloudData = null;
    return ResourceManager.storeServerpodCloudAuthData(
      authData: ServerpodCloudAuthData(key),
      localStoragePath: _localStoragePath,
    );
  }

  @override
  Future<void> remove() async {
    _cloudData = null;
    return ResourceManager.removeServerpodCloudAuthData(
      localStoragePath: _localStoragePath,
    );
  }
}

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

extension IsAuthenticated on AuthenticationKeyManager {
  Future<bool> get isAuthenticated async => await get() != null;
}

class CliAuthenticationKeyManager extends AuthenticationKeyManager {
  final Logger _logger;
  final String _localStoragePath;
  ServerpodCloudData? _cloudData;

  CliAuthenticationKeyManager({
    required final Logger logger,
    required final String localStoragePath,
    final ServerpodCloudData? cloudDataOverride,
  })  : _localStoragePath = localStoragePath,
        _logger = logger,
        _cloudData = cloudDataOverride;

  @override
  Future<String?> get() async {
    final cloudData = _cloudData;
    if (cloudData != null) {
      return cloudData.token;
    }

    _cloudData = await ResourceManager.tryFetchServerpodCloudData(
      localStoragePath: _localStoragePath,
      logger: _logger,
    );

    return _cloudData?.token;
  }

  @override
  Future<void> put(final String key) async {
    _cloudData = null;
    return ResourceManager.storeServerpodCloudData(
      cloudData: ServerpodCloudData(key),
      localStoragePath: _localStoragePath,
    );
  }

  @override
  Future<void> remove() async {
    _cloudData = null;
    return ResourceManager.removeServerpodCloudData(
      localStoragePath: _localStoragePath,
    );
  }
}

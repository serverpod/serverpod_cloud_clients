import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

class CloudLogoutCommand extends CloudCliCommand {
  @override
  final name = 'logout';

  @override
  final description =
      'Log out from Serverpod Cloud and remove stored credentials.';

  CloudLogoutCommand({required super.logger}) : super(options: []);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final localStoragePath = globalConfiguration.authDir;

    final cloudData = await ResourceManager.tryFetchServerpodCloudData(
      localStoragePath: localStoragePath,
      logger: logger,
    );

    if (cloudData == null) {
      logger.info('No stored Serverpod Cloud credentials found.');
      return;
    }

    final cloudClient = runner.serviceProvider.cloudApiClient;

    ExitException? exitException;
    try {
      await cloudClient.modules.auth.status.signOutDevice();
    } catch (e) {
      logger.error(
        'Request to sign out from Serverpod Cloud failed: $e',
      );
      exitException = ExitException();
    }

    try {
      await ResourceManager.removeServerpodCloudData(
        localStoragePath: localStoragePath,
      );
    } catch (e) {
      logger.error(
        'Failed to remove stored credentials. Please remove the these manually: $e',
      );
      exitException = ExitException();
    }

    if (exitException != null) {
      throw exitException;
    }

    logger.info('Successfully logged out from Serverpod cloud.');
  }
}

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class CloudLogoutCommand extends CloudCliCommand {
  @override
  final name = 'logout';

  @override
  final description =
      'Log out from Serverpod Cloud and remove stored credentials.';

  CloudLogoutCommand({required super.logger}) {
    // Developer options and flags
    argParser.addOption(
      'dir',
      abbr: 'd',
      help:
          'The directory path where the Serverpod Cloud credentials are stored.',
      hide: true,
      defaultsTo: ResourceManager.localStorageDirectory.path,
    );

    argParser.addOption(
      'server',
      abbr: 's',
      help: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    );
  }

  @override
  void run() async {
    final localStoragePath = argResults!['dir'] as String;
    final serverAddress = argResults!['server'] as String;

    final cloudData = await ResourceManager.tryFetchServerpodCloudData(
      localStoragePath: localStoragePath,
      logger: logger,
    );

    if (cloudData == null) {
      logger.info('No stored Serverpod Cloud credentials found.');
      return;
    }

    final cloudClient = Client(
      serverAddress,
      authenticationKeyManager: CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: localStoragePath,
        cloudData: cloudData,
      ),
    );

    ExitException? exitException;
    try {
      await cloudClient.modules.auth.status.signOut();
    } catch (e, stackTrace) {
      logger.error(
        'Request to sign out from Serverpod Cloud failed: $e',
        stackTrace: stackTrace,
      );
      exitException = ExitException();
    }

    try {
      await ResourceManager.removeServerpodCloudData(
        localStoragePath: localStoragePath,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to remove stored credentials. Please remove the these manually: $e',
        stackTrace: stackTrace,
      );
      exitException = ExitException();
    }

    if (exitException != null) {
      throw exitException;
    }

    logger.info('Successfully logged out from Serverpod cloud.');
  }
}

import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

abstract final class CLIVersionChecker {
  /// Check current Serverpod CLI version and prompt user to update if needed
  /// Returns true if the CLI should be updated, false otherwise
  static Future<Version?> fetchLatestCLIVersion({
    required final CommandLogger logger,
    required final String localStoragePath,
    final PubApiClient? pubClientOverride,
  }) async {
    return PackageVersion.fetchLatestPackageVersion(
      storePackageVersionData: (final PackageVersionData versionArtefact) =>
          ResourceManager.storeLatestCliVersion(
            cliVersionData: versionArtefact,
            logger: logger,
          ),
      loadPackageVersionData: () => ResourceManager.tryFetchLatestCliVersion(
        localStoragePath: localStoragePath,
        logger: logger,
      ),
      fetchLatestPackageVersion: () async {
        final pubClient = pubClientOverride ?? PubApiClient();
        Version? version;
        try {
          version = await pubClient
              .tryFetchLatestStableVersion('serverpod_cloud_cli')
              .timeout(const Duration(seconds: 2));
        } on VersionFetchException catch (e) {
          logger.error(e.message);
        } on VersionParseException catch (e) {
          logger.error(e.message);
        } finally {
          pubClient.close();
        }

        return version;
      },
    );
  }

  /// Returns true if the latest CLI version is a breaking update from the current
  static bool isBreakingUpdate({
    required final Version currentVersion,
    required final Version latestVersion,
  }) {
    return currentVersion.nextBreaking <= latestVersion;
  }
}

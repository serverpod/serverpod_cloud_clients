abstract class HostConstants {
  static const serverpodCloudConsole = 'https://console.serverpod.dev';
  static const serverpodCloudApi = 'https://api.serverpod.dev';

  static const tenantDomain = 'serverpod.space';
}

abstract final class ExitCodeConstants {
  /// The exit code for when `scloud` must be updated.
  static const scloudUpdateRequired = 69;

  /// The exit code for when `scloud` has updated itself and the command
  /// must be run again with the new version.
  static const scloudUpdatedRerunRequired = 75;
}

abstract final class VersionConstants {
  /// The minimum Serverpod version supported for tenant projects in Serverpod Cloud.
  static const minSupportedServerpodVersion = '2.3.0';

  /// The constraint for which Serverpod versions are supported for tenant
  /// projects in Serverpod Cloud.
  static const supportedServerpodConstraint = '>=$minSupportedServerpodVersion';

  /// Minimum Serverpod version recommended when deploying with more than one
  /// podlet (scaling / rolling deploy behavior).
  static const serverpodMultiPodletSafeMinVersion = '3.3.0';
}

abstract final class ProjectConfigFileConstants {
  static const fileBaseName = 'scloud';

  static const defaultFileName = '$fileBaseName.yaml';

  static const defaultYamlFileHeader = '''
# This file configures your Serverpod Cloud project.
# It is automatically generated and updated by the `scloud` command.
# 
# Useful commands:
# - Deploy: `scloud deploy`
# - Get Help: `scloud help`
#
# For full documentation, visit: https://docs.serverpod.dev/cloud

''';
}

/// The number of characters to display in user-friendly format for a timestamp.
const numTimeStampChars = 19;

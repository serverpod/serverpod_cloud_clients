abstract class HostConstants {
  static const serverpodCloudConsole = 'https://console.serverpod.cloud';
  static const serverpodCloudApi = 'https://api.serverpod.cloud';
}

abstract final class VersionConstants {
  /// The minimum SDK version supported for tenant projects in Serverpod Cloud.
  static const minSupportedSdkVersion = '3.8.0';

  /// The constraint for which SDK versions are supported for tenant projects
  /// in Serverpod Cloud. This is the highest tested version plus 0.1.
  static const supportedSdkConstraint = '>=$minSupportedSdkVersion <3.9.0';

  /// The minimum Serverpod version supported for tenant projects in Serverpod Cloud.
  static const minSupportedServerpodVersion = '2.3.0';

  /// The constraint for which Serverpod versions are supported for tenant
  /// projects in Serverpod Cloud.
  static const supportedServerpodConstraint = '>=$minSupportedServerpodVersion';
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
# For full documentation, visit: https://docs.serverpod.cloud

''';
}

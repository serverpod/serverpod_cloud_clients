abstract class HostConstants {
  static const serverpodCloudConsole = 'https://console.serverpod.cloud';
  static const serverpodCloudApi = 'https://api.serverpod.cloud';
}

abstract final class ConfigFileConstants {
  static const fileName = 'scloud.yaml';

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

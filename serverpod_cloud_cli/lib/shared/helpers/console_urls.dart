import 'dart:io' show Platform;
import 'package:serverpod_cloud_cli/constants.dart';

String getConsoleBaseUrl() {
  const prodConsoleHost = HostConstants.serverpodCloudConsole;

  final hostFromEnv =
      Platform.environment['SERVERPOD_CLOUD_CONSOLE_SERVER_URL'];
  return hostFromEnv ?? prodConsoleHost;
}

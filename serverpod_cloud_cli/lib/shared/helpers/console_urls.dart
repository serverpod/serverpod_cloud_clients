import 'dart:io' show Platform;

import 'package:ground_control_client/ground_control_client.dart'
    show ConsoleRoutes;
import 'package:serverpod_cloud_cli/constants.dart';

String getConsoleBaseUrl() {
  const prodConsoleHost = HostConstants.serverpodCloudConsole;

  final hostFromEnv =
      Platform.environment['SERVERPOD_CLOUD_CONSOLE_SERVER_URL'];
  return hostFromEnv ?? prodConsoleHost;
}

/// The console URL of the plan and settings page of [projectId],
/// where the project's plan can be changed.
String getProjectPlanUrl(String projectId) {
  return '${getConsoleBaseUrl()}'
      '${ConsoleRoutes.projectPlanAndSettings(projectId)}';
}

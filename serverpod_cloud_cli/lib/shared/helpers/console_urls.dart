import 'dart:io' show Platform;

String getConsoleBaseUrl() {
  const prodConsoleHost = 'https://console.serverpod.cloud';

  final hostFromEnv =
      Platform.environment['SERVERPOD_CLOUD_CONSOLE_SERVER_URL'];
  return hostFromEnv ?? prodConsoleHost;
}

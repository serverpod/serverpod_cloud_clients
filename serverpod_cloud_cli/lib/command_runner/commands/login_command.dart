import 'dart:async';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/listener_server.dart';

enum LoginCommandOption implements OptionDefinition {
  timeoutOpt(
    ConfigOption(
      argName: 'timeout',
      argAbbrev: 't',
      helpText:
          'The time in seconds to wait for the authentication to complete.',
      defaultsTo: '120',
    ),
  ),
  persistentOpt(
    ConfigOption(
      argName: 'persistent',
      helpText: 'Store the authentication credentials.',
      isFlag: true,
      defaultsTo: 'true',
      negatable: true,
    ),
  ),
  browserOpt(
    ConfigOption(
      argName: 'browser',
      helpText: 'Allow CLI to open browser for logging in.',
      isFlag: true,
      defaultsTo: 'true',
      negatable: true,
    ),
  ),
  // Developer options and flags
  signinPathOpt(
    ConfigOption(
      argName: 'sign-in-path',
      helpText: 'The path to the sign-in endpoint on the server.',
      hide: true,
      defaultsTo: '/cli/signin',
    ),
  );

  const LoginCommandOption(this.option);

  @override
  final ConfigOption option;
}

class CloudLoginCommand extends CloudCliCommand<LoginCommandOption> {
  CloudLoginCommand({required super.logger})
      : super(options: LoginCommandOption.values);

  @override
  final name = 'login';

  @override
  final description = 'Log in to Serverpod cloud.';

  @override
  Future<void> runWithConfig(
      final Configuration<LoginCommandOption> commandConfig) async {
    final timeLimit = Duration(
        seconds: int.parse(commandConfig.value(LoginCommandOption.timeoutOpt)));
    final signInPath = commandConfig.value(LoginCommandOption.signinPathOpt);
    final persistent = commandConfig.flag(LoginCommandOption.persistentOpt);
    final openBrowser = commandConfig.flag(LoginCommandOption.browserOpt);

    final localStoragePath = globalConfiguration.authDir;
    final serverAddress = globalConfiguration.consoleServer;

    final storedCloudData = await ResourceManager.tryFetchServerpodCloudData(
      localStoragePath: localStoragePath,
      logger: logger,
    );

    if (storedCloudData != null) {
      logger.info(
          'Detected an existing login session for Serverpod cloud. Logout first to log in again.');
      return;
    }

    final cloudServer = Uri.parse(serverAddress).replace(
      path: signInPath,
    );

    final callbackUrlFuture = Completer<Uri>();
    final tokenFuture = ListenerServer.listenForAuthenticationToken(
      onConnected: (final Uri callbackUrl) =>
          callbackUrlFuture.complete(callbackUrl),
      timeLimit: timeLimit,
      logger: logger,
    );

    final callbackUrl = await callbackUrlFuture.future;
    final signInUrl = cloudServer.replace(
      queryParameters: {'callback': callbackUrl.toString()},
    );
    logger.info(
        'Please log in to Serverpod Cloud using the opened browser or through this link: $signInUrl');

    if (openBrowser) {
      try {
        await BrowserLauncher.openUrl(signInUrl);
      } catch (e) {
        logger.debug('Failed to open browser: $e');
      }
    }

    await logger.progress('Waiting for authentication to complete...',
        () async {
      final token = await tokenFuture;
      return token != null;
    });

    final token = await tokenFuture;
    if (token == null) {
      logger.error('Failed to get authentication token.');
      throw ExitException();
    }

    if (persistent) {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData(token),
        localStoragePath: localStoragePath,
      );
    }
    logger.info('Successfully logged in to Serverpod cloud.');
  }
}

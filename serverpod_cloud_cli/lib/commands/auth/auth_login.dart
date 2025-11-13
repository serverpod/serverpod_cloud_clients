import 'dart:async';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/listener_server.dart';

abstract class AuthLoginCommands {
  static Future<void> login({
    required final CommandLogger logger,
    required final GlobalConfiguration globalConfig,
    final Duration timeLimit = const Duration(seconds: 300),
    required final bool persistent,
    required final bool openBrowser,
    final String signInPath = '/cli/signin',
  }) async {
    final localStoragePath = globalConfig.scloudDir;
    final serverAddress = globalConfig.consoleServer;

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
        'Please log in to Serverpod Cloud using the opened browser or through this link:\n$signInUrl');

    if (openBrowser) {
      try {
        await BrowserLauncher.openUrl(signInUrl);
      } on Exception catch (e) {
        logger.error(
          'Failed to open browser',
          exception: e,
        );
      }
    }

    await logger.progress('Waiting for authentication to complete...',
        () async {
      final token = await tokenFuture;
      return token != null;
    });

    final token = await tokenFuture;
    if (token == null) {
      throw FailureException(
        error: 'Failed to get authentication token.',
        hint: 'Please try to log in again.',
      );
    }

    if (persistent) {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData(token),
        localStoragePath: localStoragePath.path,
      );
    }

    logger.success('Successfully logged in to Serverpod cloud.');
  }
}

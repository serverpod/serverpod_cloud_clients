import 'dart:async';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/listener_server.dart';

class CloudLoginCommand extends CloudCliCommand {
  CloudLoginCommand({required super.logger}) {
    argParser.addOption(
      'timeout',
      abbr: 't',
      help: 'The time in seconds to wait for the authentication to complete.',
      defaultsTo: '120',
    );

    argParser.addFlag(
      'persistent',
      help: 'Store the authentication credentials.',
      defaultsTo: true,
      negatable: true,
    );

    argParser.addFlag(
      'browser',
      help: 'Allow CLI to open browser for logging in.',
      defaultsTo: true,
      negatable: true,
    );

    argParser.addOption(
      'auth-dir',
      abbr: 'd',
      help:
          'Override the directory path where the serverpod cloud authentication file is stored.',
      defaultsTo: ResourceManager.localStorageDirectory.path,
    );

    // Developer options and flags

    argParser.addOption(
      'server',
      abbr: 's',
      help: 'The URL to the Serverpod cloud server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloud,
    );

    argParser.addOption(
      'sign-in-path',
      help: 'The path to the sign-in endpoint on the server.',
      hide: true,
      defaultsTo: '/cli/signin',
    );
  }
  @override
  final name = 'login';

  @override
  final description = 'Log in to Serverpod cloud.';

  @override
  void run() async {
    final localStoragePath = argResults!['auth-dir'] as String;
    final timeLimit = Duration(seconds: int.parse(argResults!['timeout']));
    final serverAddress = argResults!['server'] as String;
    final signInPath = argResults!['sign-in-path'] as String;
    final persistent = argResults!['persistent'] as bool;
    final openBrowser = argResults!['browser'] as bool;

    final storedCloudData = await ResourceManager.tryFetchServerpodCloudData(
      localStoragePath: localStoragePath,
      logger: logger,
    );

    if (storedCloudData != null) {
      logger.info('Already logged in to Serverpod cloud.');
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

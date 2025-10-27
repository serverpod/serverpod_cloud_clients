import 'dart:async';

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/listener_server.dart';

import 'categories.dart';

class CloudAuthCommand extends CloudCliCommand {
  @override
  final name = 'auth';

  @override
  final description = 'Manage user authentication.';

  @override
  String get category => CommandCategories.manage;

  CloudAuthCommand({required super.logger}) {
    addSubcommand(CloudLoginCommand(logger: logger));
    addSubcommand(CloudLogoutCommand(logger: logger));
  }
}

enum LoginCommandOption<V> implements OptionDefinition<V> {
  timeoutOpt(
    DurationOption(
      argName: 'timeout',
      argAbbrev: 't',
      helpText: 'The time to wait for the authentication to complete.',
      defaultsTo: Duration(seconds: 300),
      min: Duration.zero,
    ),
  ),
  persistentOpt(
    FlagOption(
      argName: 'persistent',
      helpText: 'Store the authentication credentials.',
      defaultsTo: true,
      negatable: true,
    ),
  ),
  browserOpt(
    FlagOption(
      argName: 'browser',
      helpText: 'Allow CLI to open browser for logging in.',
      defaultsTo: true,
      negatable: true,
    ),
  ),
  // Developer options and flags
  signinPathOpt(
    StringOption(
      argName: 'sign-in-path',
      helpText: 'The path to the sign-in endpoint on the server.',
      hide: true,
      defaultsTo: '/cli/signin',
    ),
  );

  const LoginCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudLoginCommand extends CloudCliCommand<LoginCommandOption> {
  CloudLoginCommand({required super.logger})
      : super(options: LoginCommandOption.values);

  @override
  bool get requireLogin => false;

  @override
  final name = 'login';

  @override
  final description = 'Log in to Serverpod cloud.';

  @override
  Future<void> runWithConfig(
      final Configuration<LoginCommandOption> commandConfig) async {
    final timeLimit = commandConfig.value(LoginCommandOption.timeoutOpt);
    final signInPath = commandConfig.value(LoginCommandOption.signinPathOpt);
    final persistent = commandConfig.value(LoginCommandOption.persistentOpt);
    final openBrowser = commandConfig.value(LoginCommandOption.browserOpt);

    final localStoragePath = globalConfiguration.scloudDir;
    final serverAddress = globalConfiguration.consoleServer;

    final storedCloudData =
        await ResourceManager.tryFetchServerpodCloudAuthData(
      localStoragePath: localStoragePath.path,
      logger: logger,
    );

    if (storedCloudData != null) {
      logger.error(
        'Detected an existing login session for Serverpod cloud. '
        'Log out first to log in again.',
      );
      logger.terminalCommand(
        'scloud auth logout',
      );
      throw FailureException();
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

class CloudLogoutCommand extends CloudCliCommand {
  @override
  bool get requireLogin => false;

  @override
  final name = 'logout';

  @override
  final description =
      'Log out from Serverpod Cloud and remove stored credentials.';

  CloudLogoutCommand({required super.logger}) : super(options: []);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final localStoragePath = globalConfiguration.scloudDir;

    final cloudData = await ResourceManager.tryFetchServerpodCloudAuthData(
      localStoragePath: localStoragePath.path,
      logger: logger,
    );

    if (cloudData == null) {
      logger.info('No stored Serverpod Cloud credentials found.');
      return;
    }

    final cloudClient = runner.serviceProvider.cloudApiClient;

    ErrorExitException? exitException;
    try {
      await cloudClient.auth.logoutDevice();
    } on Exception catch (e) {
      // TODO: warning logging can be removed when we are out of the beta phase
      logger.warning('Ignoring error response from server: $e');
    }

    try {
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: localStoragePath.path,
      );
    } on Exception catch (e) {
      logger.error(
        'Failed to remove stored credentials',
        exception: e,
        hint: 'Please remove these manually. '
            'They should be located in $localStoragePath.',
      );
      exitException = ErrorExitException();
    }

    if (exitException != null) {
      throw exitException;
    }

    logger.success('Successfully logged out from Serverpod cloud.');
  }
}

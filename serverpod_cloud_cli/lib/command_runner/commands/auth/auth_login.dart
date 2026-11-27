import 'dart:async';
import 'dart:io' show Directory;

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_user_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/listener_server.dart';

abstract class AuthLoginCommands {
  static const _backfillTimeout = Duration(seconds: 5);

  /// Logs in to Serverpod Cloud through the console in the browser.
  ///
  /// Opens the console sign-in page at [signInPath] and waits up to
  /// [timeLimit] for the console to send the login back. When [persistent] is
  /// true, the login is stored in [scloudDir].
  ///
  /// When [selectProject] is true, the console also lets the user select or
  /// create a project after logging in.
  ///
  /// Returns the id of the project selected in the console, or `null` if no
  /// project was selected.
  ///
  /// Throws a [FailureException] if no login was received.
  static Future<String?> login({
    required CommandLogger logger,
    required Directory scloudDir,
    required String consoleServer,
    required bool openBrowser,
    required Client cloudApiClient,
    Duration timeLimit = const Duration(minutes: 10),
    required bool persistent,
    required String signInPath,
    bool selectProject = false,
  }) async {
    final localStoragePath = scloudDir.path;

    final cloudServer = Uri.parse(consoleServer).replace(path: signInPath);

    final callbackUrlFuture = Completer<Uri>();
    final callbackFuture =
        ListenerServer.listenForAuthenticationTokenAndProject(
          onConnected: (Uri callbackUrl) =>
              callbackUrlFuture.complete(callbackUrl),
          timeLimit: timeLimit,
          logger: logger,
        );

    final callbackUrl = await callbackUrlFuture.future;
    final signInUrl = cloudServer.replace(
      queryParameters: {
        if (selectProject) 'select-project': 'true',
        'callback': callbackUrl.toString(),
      },
    );
    logger.info(
      'Please log in to Serverpod Cloud using the opened browser or through this link:\n$signInUrl',
    );

    if (openBrowser) {
      try {
        await BrowserLauncher.openUrl(signInUrl);
      } on Exception catch (e) {
        logger.error('Failed to open browser', exception: e);
      }
    }

    await logger.progress(
      'Waiting for authentication to complete...',
      () async {
        final callback = await callbackFuture;
        return callback != null;
      },
    );

    final callback = await callbackFuture;
    if (callback == null) {
      throw FailureException(
        error: 'Failed to get authentication token.',
        hint: 'Please try to log in again.',
      );
    }

    if (persistent) {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData(callback.token),
        localStoragePath: localStoragePath,
      );
      await fetchAndStoreServerpodCloudUserData(
        cloudApiClient: cloudApiClient,
        localStoragePath: localStoragePath,
        logger: logger,
      );
    }

    logger.success('Successfully logged in to Serverpod Cloud.');

    return callback.projectId;
  }

  static Future<void> fetchAndStoreServerpodCloudUserData({
    required Client cloudApiClient,
    required String localStoragePath,
    required CommandLogger logger,
  }) async {
    try {
      final user = await cloudApiClient.users.readUser();
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData(
          user.id.toString(),
          userAuthId: user.userAuthId,
        ),
        localStoragePath: localStoragePath,
      );
    } on Exception catch (e) {
      logger.debug('Failed to fetch user data: $e');
    }
  }

  static Future<void> backfillUserAuthId({
    required Client cloudApiClient,
    required String localStoragePath,
    required CommandLogger logger,
  }) async {
    final storedUserData = ResourceManager.tryFetchServerpodCloudUserDataSync(
      localStoragePath: localStoragePath,
    );
    if (storedUserData == null || storedUserData.userAuthId != null) {
      return;
    }

    try {
      final user = await cloudApiClient.users.readUser().timeout(
        _backfillTimeout,
      );
      if (user.id.toString() != storedUserData.id) {
        return;
      }
      await ResourceManager.storeServerpodCloudUserData(
        cloudUserData: ServerpodCloudUserData(
          storedUserData.id,
          userAuthId: user.userAuthId,
        ),
        localStoragePath: localStoragePath,
      );
    } on Exception catch (e, stackTrace) {
      logger.debug('Failed to backfill the user auth id: $e\n$stackTrace');
    }
  }
}

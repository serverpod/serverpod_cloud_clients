import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/commands/auth/auth_login.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

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
      argName: 'time-limit',
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

    await AuthLoginCommands.login(
      logger: logger,
      globalConfig: globalConfiguration,
      timeLimit: timeLimit,
      persistent: persistent,
      openBrowser: openBrowser,
      signInPath: signInPath,
    );
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

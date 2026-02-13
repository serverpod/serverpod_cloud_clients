import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/auth/auth_login.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../../commands/auth/auth.dart';
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
    addSubcommand(ListAuthSessionsCommand(logger: logger));
    addSubcommand(CreateTokenCommand(logger: logger));
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
    final Configuration<LoginCommandOption> commandConfig,
  ) async {
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
      logger.terminalCommand('scloud auth logout');
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

enum LogoutCommandOption<V> implements OptionDefinition<V> {
  tokenId(
    MultiStringOption(
      argName: 'token-id',
      helpText:
          'The token IDs to log out. Logs out the current session if not provided.',
      defaultsTo: [],
      group: _sessions,
    ),
  ),
  all(
    FlagOption(
      argName: 'all',
      helpText: 'Log out from all sessions including API tokens.',
      defaultsTo: false,
      negatable: false,
      group: _sessions,
    ),
  );

  static const _sessions = MutuallyExclusive(
    'Sessions',
    mode: MutuallyExclusiveMode.allowDefaults,
  );

  const LogoutCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudLogoutCommand extends CloudCliCommand<LogoutCommandOption> {
  @override
  bool get requireLogin => false;

  @override
  final name = 'logout';

  @override
  final description = '''Log out from Serverpod Cloud.

By default the current session is logged out.
Use options to log out other sessions and CLI / personal access tokens.
See also "scloud auth list", to list the current authentication sessions.''';

  CloudLogoutCommand({required super.logger})
    : super(options: LogoutCommandOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<LogoutCommandOption> commandConfig,
  ) async {
    final tokenIds = commandConfig.value(LogoutCommandOption.tokenId);
    final all = commandConfig.value(LogoutCommandOption.all);

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

    final currentSessionLoggedOut = await _logout(cloudClient, tokenIds, all);

    if (!currentSessionLoggedOut) {
      logger.success('Successfully logged out the selected sessions.');
      return;
    }

    try {
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: localStoragePath.path,
      );
    } on Exception catch (e) {
      logger.error(
        'Failed to remove stored credentials',
        exception: e,
        hint:
            'Please remove these manually. '
            'They should be located in $localStoragePath.',
      );
      exitException = ErrorExitException();
    }

    if (exitException != null) {
      throw exitException;
    }

    logger.success('Successfully logged out from Serverpod cloud.');
  }

  Future<bool> _logout(
    final Client cloudClient,
    final List<String> tokenIds,
    final bool all,
  ) async {
    if (tokenIds.isNotEmpty) {
      bool currentSessionLoggedOut = false;
      for (final tokenId in tokenIds) {
        currentSessionLoggedOut |= await cloudClient.authWithAuth.logoutDevice(
          authTokenId: tokenId,
        );
      }
      return currentSessionLoggedOut;
    }

    if (all) {
      await cloudClient.authWithAuth.logoutAll();
    } else {
      try {
        await cloudClient.authWithAuth.logoutDevice();
      } on Exception catch (_) {
        // continue even if server logout fails
      }
    }
    return true;
  }
}

enum ListAuthSessionsOption<V> implements OptionDefinition<V> {
  utc(UtcOption());

  const ListAuthSessionsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class ListAuthSessionsCommand extends CloudCliCommand<ListAuthSessionsOption> {
  ListAuthSessionsCommand({required super.logger})
    : super(options: ListAuthSessionsOption.values);

  @override
  bool get requireLogin => true;

  @override
  final name = 'list';

  @override
  final description = 'List the current authentication sessions.';

  @override
  Future<void> runWithConfig(
    final Configuration<ListAuthSessionsOption> commandConfig,
  ) async {
    final inUtc = commandConfig.value(ListAuthSessionsOption.utc);
    final cloudClient = runner.serviceProvider.cloudApiClient;
    await Auth.listAuthSessions(cloudClient, logger: logger, inUtc: inUtc);
  }
}

enum CreateTokenCommandOption<V> implements OptionDefinition<V> {
  expireAt(
    DateTimeOption(
      argName: 'expire-at',
      helpText: 'The calendar time to expire the token at.',
    ),
  ),
  idleTtl(
    DurationOption(
      argName: 'idle-ttl',
      helpText: 'The duration of non-use after which the token will expire.',
      defaultsTo: Duration(days: 30),
      group: _expiresAfter,
    ),
  ),
  noExpiresAfter(
    FlagOption(
      argName: 'no-idle-ttl',
      helpText: 'Do not expire the token after a duration of non-use.',
      defaultsTo: false,
      negatable: false,
      group: _expiresAfter,
    ),
  );

  static const _expiresAfter = MutuallyExclusive(
    'TTL: Expire after non-use',
    mode: MutuallyExclusiveMode.allowDefaults,
  );

  const CreateTokenCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CreateTokenCommand extends CloudCliCommand<CreateTokenCommandOption> {
  CreateTokenCommand({required super.logger})
    : super(options: CreateTokenCommandOption.values);

  @override
  bool get requireLogin => true;

  @override
  final name = 'create-token';

  @override
  final description = '''Create a personal access token.
  
Creates an additional CLI / personal access token for the current user.
This token can be used to authenticate scloud commands by using
the --token option or the SERVERPOD_CLOUD_TOKEN environment variable.''';

  @override
  Future<void> runWithConfig(
    final Configuration<CreateTokenCommandOption> commandConfig,
  ) async {
    final expiresAt = commandConfig.optionalValue(
      CreateTokenCommandOption.expireAt,
    );
    final noExpiresAfter = commandConfig.value(
      CreateTokenCommandOption.noExpiresAfter,
    );
    final expiresAfter = commandConfig.optionalValue(
      CreateTokenCommandOption.idleTtl,
    );

    final cloudClient = runner.serviceProvider.cloudApiClient;
    await Auth.createApiToken(
      cloudClient,
      logger: logger,
      expiresAt: expiresAt,
      expiresAfter: noExpiresAfter ? null : expiresAfter,
    );
  }
}

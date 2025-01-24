import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

import 'exit_exceptions.dart';

abstract class CloudCliCommand<T extends OptionDefinition>
    extends BetterCommand {
  final CommandLogger logger;

  /// The option definitions for this command.
  final List<T> options;

  final bool requireLogin = true;

  CloudCliCommand({
    required this.logger,
    this.options = const [],
  }) : super(
          logInfo: (final String message) => logger.info(message),
          wrapTextColumn: logger.wrapTextColumn,
        ) {
    options.prepareForParsing(argParser);
  }

  /// Gets the command runner [CloudCliCommandRunner].
  @override
  CloudCliCommandRunner get runner => super.runner as CloudCliCommandRunner;

  /// Gets the current global configuration.
  /// Valid after the command runner has started running.
  GlobalConfiguration get globalConfiguration => runner.globalConfiguration;

  /// Runs this command. Subclasses should instead override [runWithConfig].
  @override
  Future<void> run() async {
    final config = Configuration.fromEnvAndArgs(
      options: options,
      args: argResults,
      env: Platform.environment,
    );

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    if (requireLogin &&
        await apiCloudClient.authenticationKeyManager?.isAuthenticated !=
            true) {
      logger.error('This command requires you to be logged in.');
      logger.terminalCommand(
        message: 'Please run the login command to authenticate and try again:',
        'scloud login',
      );
      throw ErrorExitException();
    }

    try {
      await runWithConfig(config);
    } on CloudCliUsageException catch (e) {
      logger.error(e.message, hint: e.hint);
      throw ErrorExitException();
    }
  }

  /// Runs this command with prepared configuration (options).
  /// Subclasses should override this method.
  Future<void> runWithConfig(final Configuration<T> commandConfig) async {
    throw UnimplementedError(
        'CLI command $name has not implemented runWithConfig.');
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/capitalize.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

import 'exit_exceptions.dart';

abstract class CloudCliCommand<T extends OptionDefinition>
    extends BetterCommand {
  final CommandLogger logger;

  /// The option definitions for this command.
  final List<T> options;

  /// Whether the command requires the user to be logged in.
  /// The default is true, subclasses can override to false.
  final bool requireLogin = true;

  CloudCliCommand({
    required this.logger,
    this.options = const [],
  }) : super(
          passOutput: MessageOutput(
            logUsage: logger.info,
          ),
          wrapTextColumn: logger.wrapTextColumn,
        ) {
    options.prepareForParsing(argParser);
  }

  /// Gets the top parent command for this command.
  Command get _topCommand {
    Command command = this;
    do {
      if (command.parent case final Command par) {
        command = par;
      } else {
        return command;
      }
    } while (true);
  }

  @override
  String? get usageFooter =>
      '\nSee the full documentation at: https://docs.serverpod.cloud/references/cli/commands/${_topCommand.name}';

  /// Gets the command runner [CloudCliCommandRunner].
  @override
  CloudCliCommandRunner get runner => super.runner as CloudCliCommandRunner;

  /// Gets the current global configuration.
  /// Valid after the command runner has started running.
  GlobalConfiguration get globalConfiguration => runner.globalConfiguration;

  /// Runs this command. Subclasses should instead override [runWithConfig].
  @override
  Future<void> run() async {
    final config = Configuration.resolve(
      options: options,
      argResults: argResults,
      env: Platform.environment,
      configBroker: scloudCliConfigBroker(
        globalConfig: globalConfiguration,
        logger: logger,
      ),
    );

    if (config.errors.isNotEmpty) {
      final buffer = StringBuffer();
      final errors = config.errors.map(
        (final e) => '${e.capitalize()}.',
      );
      buffer.writeAll(errors, '\n');
      usageException(buffer.toString());
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    if (requireLogin &&
        await apiCloudClient.authenticationKeyManager?.isAuthenticated !=
            true) {
      logger.error('This command requires you to be logged in.');
      logger.terminalCommand(
        message: 'Please run the login command to authenticate and try again:',
        'scloud auth login',
      );
      throw ErrorExitException('This command requires you to be logged in.');
    }

    try {
      await runWithConfig(config);
    } on CloudCliUsageException catch (e, stackTrace) {
      // TODO: Don't catch CloudCliUsageException,
      // it's a UsageException and is handled by the caller.
      logger.error(e.message, hint: e.hint);
      throw ErrorExitException(e.message, e, stackTrace);
    }
  }

  /// Runs this command with prepared configuration (options).
  /// Subclasses should override this method.
  Future<void> runWithConfig(final Configuration<T> commandConfig) async {
    throw UnimplementedError(
        'CLI command $name has not implemented runWithConfig.');
  }
}

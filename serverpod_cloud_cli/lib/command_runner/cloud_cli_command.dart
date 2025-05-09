import 'package:args/args.dart' show ArgResults;
import 'package:args/command_runner.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_broker.dart'
    show scloudCliConfigBroker;

import 'exit_exceptions.dart';

abstract class CloudCliCommand<O extends OptionDefinition>
    extends BetterCommand<O, void> {
  final CommandLogger logger;

  /// Whether the command requires the user to be logged in.
  /// The default is true, subclasses can override to false.
  final bool requireLogin = true;

  CloudCliCommand({
    required this.logger,
    super.options = const [],
  }) : super(
          wrapTextColumn: logger.wrapTextColumn,
        );

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
      await super.run();
    } on CloudCliUsageException catch (e, stackTrace) {
      // TODO: Don't catch CloudCliUsageException,
      // it's a UsageException and is handled by the caller.
      logger.error(e.message, hint: e.hint);
      throw ErrorExitException(e.message, e, stackTrace);
    }
  }

  @override
  Configuration<O> resolveConfiguration(final ArgResults? argResults) {
    return Configuration.resolve(
      options: options,
      argResults: argResults,
      env: envVariables,
      configBroker: scloudCliConfigBroker(
        globalConfig: globalConfiguration,
        logger: logger,
      ),
    );
  }

  /// Runs this command with prepared configuration (options).
  /// Subclasses should override this method.
  @override
  Future<void> runWithConfig(final Configuration<O> commandConfig) async {
    throw UnimplementedError(
        'CLI command $name has not implemented runWithConfig.');
  }
}

import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

abstract class CloudCliCommand<T extends OptionDefinition>
    extends BetterCommand {
  final Logger logger;

  /// The option definitions for this command.
  final List<T> options;

  CloudCliCommand({
    required this.logger,
    this.options = const [],
  }) : super(
          logInfo: (final String message) => logger.info(message),
          wrapTextColumn: logger.wrapTextColumn,
        ) {
    options.addToArgParser(argParser);
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
    await runWithConfig(config);
  }

  /// Runs this command with prepared configuration (options).
  /// Subclasses should override this method.
  Future<void> runWithConfig(final Configuration<T> commandConfig) async {
    throw UnimplementedError(
        'CLI command $name has not implemented runWithConfig.');
  }
}

import 'package:config/command.dart' show ActionOptionMixin, CommandContext;
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version/version_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version/version_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

/// Prints the version of the Serverpod Cloud CLI.
class VersionCommand extends CloudCliCommand {
  static const usageDescription =
      'Prints the version of the Serverpod Cloud CLI.';

  @override
  bool get requireLogin => false;

  @override
  bool get warnIfBillingOverdue => false;

  @override
  final name = 'version';

  @override
  final description = usageDescription;

  VersionCommand({required super.logger});

  @override
  Future<void> runWithOutput(
    final CommandContext<OptionDefinition, void> context,
    final CommandOutput output,
  ) {
    return printCliVersion(context);
  }
}

/// Global `--version` option.
///
/// Prints the CLI version instead of running the command on the line.
class VersionOption extends FlagOption with ActionOptionMixin<bool> {
  /// Creates the global version option.
  const VersionOption()
    : super(
        argName: 'version',
        negatable: false,
        helpText: VersionCommand.usageDescription,
      );

  @override
  Future<R?> run<O extends OptionDefinition, R>(
    final CommandContext<O, R> context,
  ) async {
    await printCliVersion(context);
    return null;
  }
}

/// Prints the version of the CLI that is running [context].
///
/// [output] receives the version line. When it is omitted, the line is
/// written with the global output format through the runner logger.
Future<void> printCliVersion<O extends OptionDefinition, T>(
  final CommandContext<O, T> context,
) async {
  final runner = context.runner;
  await context.commandOutput.render(
    operation: () async =>
        VersionOperations.currentVersion(runner.version.toString()),
    ui: CommandWidget.text(textOutputUi: const VersionTextUi()),
  );
}

import 'package:cli_tools/cli_tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/login_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/logout_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version_command.dart';

class CloudCliCommandRunner extends BetterCommandRunner {
  final Version version;
  final Logger logger;

  CloudCliCommandRunner._({
    required this.logger,
    required this.version,
    super.setLogLevel,
    super.logError,
    super.logInfo,
  }) : super(
          'scloud',
          'Manage your Serverpod Cloud projects',
          wrapTextColumn: logger.wrapTextColumn,
        );

  static CloudCliCommandRunner create({
    required final Logger logger,
    required final Version version,
  }) {
    final runner = CloudCliCommandRunner._(
      logger: logger,
      version: version,
      logInfo: logger.info,
      logError: logger.error,
      setLogLevel: ({
        final String? commandName,
        required final CommandRunnerLogLevel parsedLogLevel,
      }) =>
          _configureLogLevel(
        logger: logger,
        parsedLogLevel: parsedLogLevel,
        commandName: commandName,
      ),
    );

    runner.addCommands([
      VersionCommand(logger: logger),
      CloudLoginCommand(logger: logger),
      CloudLogoutCommand(logger: logger),
      CloudDeployCommand(logger: logger),
    ]);

    return runner;
  }

  static void _configureLogLevel({
    required final Logger logger,
    required final CommandRunnerLogLevel parsedLogLevel,
    final String? commandName,
  }) {
    var logLevel = LogLevel.info;

    if (parsedLogLevel == CommandRunnerLogLevel.verbose) {
      logLevel = LogLevel.debug;
    } else if (parsedLogLevel == CommandRunnerLogLevel.quiet) {
      logLevel = LogLevel.nothing;
    }

    logger.logLevel = logLevel;
  }
}

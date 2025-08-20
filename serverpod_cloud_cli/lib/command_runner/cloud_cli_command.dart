import 'package:args/args.dart' show ArgResults;
import 'package:args/command_runner.dart';
import 'package:cli_tools/better_command_runner.dart';
import 'package:cli_tools/logger.dart' show TextLogType;
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart'
    show processCommonClientExceptions;
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_broker.dart'
    show scloudCliConfigBroker;

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
    } on FailureException catch (e, stackTrace) {
      _processFailureException(e, stackTrace);
    } on CloudCliUsageException catch (e, stackTrace) {
      // TODO: Don't catch CloudCliUsageException,
      // it's a UsageException and is handled by the caller.
      logger.error(e.message, hint: e.hint);
      throw ErrorExitException(e.message, e, stackTrace);
    } on UsageException catch (_) {
      rethrow;
    } on ErrorExitException catch (_) {
      rethrow;
    } on Exception catch (e, stackTrace) {
      processCommonClientExceptions(logger, e, stackTrace);
      logger.error(
        'Error when running command `$name`',
        exception: e,
        stackTrace: stackTrace,
      );
      throw ErrorExitException(e.toString(), e, stackTrace);
    }
  }

  /// Process a [FailureException] by displaying relevant messages to the user
  /// and throw an [ErrorExitException].
  Never _processFailureException(
    final FailureException e,
    final StackTrace stackTrace,
  ) {
    final nested = e.nestedException;
    if (nested != null) {
      processCommonClientExceptions(
        logger,
        nested,
        e.nestedStackTrace ?? stackTrace,
      );
    }

    if (e.errors.isNotEmpty) {
      logger.error(
        e.errors.join('\n'),
        hint: e.hint,
        exception: nested,
        stackTrace: e.nestedStackTrace,
      );
    } else if (e.hint case final String hint) {
      logger.log(
        hint,
        level: LogLevel.info,
        type: TextLogType.hint,
      );
    }

    throw ErrorExitException(e.reason, e.nestedException, e.nestedStackTrace);
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

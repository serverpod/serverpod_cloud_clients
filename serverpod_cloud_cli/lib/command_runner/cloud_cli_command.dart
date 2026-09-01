import 'package:args/args.dart' show ArgResults;
import 'package:args/command_runner.dart';
import 'package:cli_tools/better_command_runner.dart';
import 'package:cli_tools/logger.dart' show TextLogType;
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_login.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/billing_commands.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart'
    show commonClientExceptionExit, processCommonClientExceptions;
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_broker.dart'
    show scloudCliConfigBroker;

import 'ui/ui.dart';

abstract class CloudCliCommand<O extends OptionDefinition>
    extends BetterCommand<O, void> {
  final CommandLogger logger;

  /// Whether the command requires the user to be logged in.
  /// The default is true, subclasses can override to false.
  final bool requireLogin = true;

  /// Whether to warn the user if their account is not in good standing.
  /// The default is true, subclasses can override to false.
  final bool warnIfBillingOverdue = true;

  CloudCliCommand({required this.logger, super.options = const []})
    : super(wrapTextColumn: logger.wrapTextColumn);

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

  static const String commandDocBaseUrl =
      'https://docs.serverpod.dev/cloud/reference/cli/commands/';

  @override
  String? get usageFooter =>
      '''${usageExamples ?? ''}
See the full documentation at: $commandDocBaseUrl${_topCommand.name}
''';

  /// Commands can override this getter to add examples to the usage help text.
  String? get usageExamples => null;

  /// Gets the command runner [CloudCliCommandRunner].
  @override
  CloudCliCommandRunner get runner => super.runner as CloudCliCommandRunner;

  /// The base command name the CLI was invoked under, e.g. `scloud`.
  ///
  /// Valid once the command has been added to the command runner.
  String get baseCommand => runner.executableName;

  /// Gets the current global configuration.
  /// Valid after the command runner has started running.
  GlobalConfiguration get globalConfiguration => runner.globalConfiguration;

  /// Runs this command. Subclasses should instead override [runWithOutput].
  @override
  Future<void> run() async {
    final client = runner.serviceProvider.cloudApiClient;
    final isAuthenticated =
        await client.authKeyProvider?.isAuthenticated == true;

    if (requireLogin && !isAuthenticated) {
      await AuthLoginCommands.login(
        logger: logger,
        scloudDir: globalConfiguration.scloudDir,
        consoleServer: globalConfiguration.consoleServer,
        openBrowser: globalConfiguration.browser,
        cloudApiClient: client,
        persistent: true,
        signInPath: globalConfiguration.signInPath,
      );
    }

    if (isAuthenticated &&
        warnIfBillingOverdue &&
        globalConfiguration.warnBillingOverdue) {
      await BillingCommands.warnIfOverdue(
        logger: logger,
        billing: runner.serviceProvider.cloudApiClient.billing,
      );
    }

    await _runCommand();
  }

  Future<void> _runCommand() async {
    try {
      await super.run();
    } on FailureException catch (e, stackTrace) {
      _processFailureException(e, stackTrace);
    } on UsageException catch (_) {
      rethrow;
    } on ExitException catch (_) {
      rethrow;
    } on Exception catch (e, stackTrace) {
      processCommonClientExceptions(logger, baseCommand, e, stackTrace);
      logger.error(
        'Error when running command `$name`',
        exception: e,
        stackTrace: stackTrace,
      );
      throw UnexpectedErrorExitException(e.toString(), e, stackTrace);
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
        baseCommand,
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
      logger.log(hint, level: LogLevel.info, type: TextLogType.hint);
    }

    if (nested != null) {
      throw UnexpectedErrorExitException(e.reason, nested, e.nestedStackTrace);
    }
    throw ErrorExitException(e.reason, null, e.nestedStackTrace);
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
  ///
  /// Creates a [CommandOutput] from the global `--format` option and
  /// delegates to [runWithOutput]. Subclasses should override [runWithOutput].
  @override
  Future<void> runWithConfig(final Configuration<O> commandConfig) async {
    final output = CommandOutput(
      format: globalConfiguration.format,
      logger: logger,
    );
    await runWithOutput(commandConfig, output);
  }

  /// Runs this command with prepared configuration and output.
  ///
  /// Subclasses should override this method.
  Future<void> runWithOutput(
    final Configuration<O> commandConfig,
    final CommandOutput output,
  ) async {
    throw UnimplementedError(
      'CLI command $name has not implemented runWithOutput.',
    );
  }

  /// Confirms with the user whether to continue with the action.
  ///
  /// Throws a [UserAbortException] if the user does not confirm.
  /// Throws a [CloudCliUsageException] if the configured format and interaction
  /// mode is not supported.
  Future<void> confirmToContinue(
    final CommandOutput output, {
    required final String message,
    final bool? defaultValue,
  }) async {
    if (globalConfiguration.skipConfirmation == true) {
      return;
    }

    if (output.format.isStructured) {
      throw CloudCliUsageException(
        'Interactive UI is not supported with structured format "${output.format.name}".',
        hint: 'Use "--yes" with "--format json|yaml" for interactive commands.',
      );
    }

    final confirmed = await output.renderInteractive(
      ui: ConfirmationWidget(message, defaultValue: defaultValue),
    );
    if (!confirmed) {
      throw UserAbortException();
    }
  }

  Future<OutputContext> renderCommand<T extends Object>(
    final CommandOutput output, {
    required final Operation<T> operation,
    required final OutputWidget textOutputUi,
    final OutputWidget? fallbackErrorUi,
  }) async {
    final exceptionHandlingUi = CommonClientExceptionsWidget(
      baseCommand: baseCommand,
      elseWidget: ExceptionHandlingWidget<FailureException>(
        errorWidgetMaker: (final e) => FailureExceptionWidget(e),
        elseWidget: fallbackErrorUi,
      ),
    );

    final ui = CommandWidget.text(
      textOutputUi: textOutputUi,
      textErrorUi: exceptionHandlingUi,
    );

    final context = await output.render(operation: operation, ui: ui);

    // Re-throw exceptions as appropriate so that Sentry reporting and process exit
    // are performed.
    final qe = context.find<QualifiedException>();
    if (qe != null) {
      if (qe.exception case final FailureException f) {
        final nested = f.nestedException;
        if (nested != null) {
          throw UnexpectedErrorExitException(
            f.reason,
            nested,
            f.nestedStackTrace,
          );
        }
        throw ErrorExitException(f.reason, null, f.nestedStackTrace);
      }
      final exitException = commonClientExceptionExit(
        qe.exception,
        qe.stackTrace,
      );
      if (exitException != null) {
        throw exitException;
      }
      Error.throwWithStackTrace(qe.exception, qe.stackTrace);
    }

    return context;
  }
}

class FailureExceptionWidget extends OutputWidget {
  final FailureException exception;

  const FailureExceptionWidget(this.exception);

  @override
  OutputWidget build(final OutputContext context) {
    return TextErrorOutputWidget(
      exception,
      message: exception.errors.join('\n'),
      hint: exception.hint,
      exception: exception.nestedException,
      stackTrace: exception.nestedStackTrace,
    );
  }
}

import 'dart:io';

import 'package:cli_tools/cli_tools.dart' as cli;
import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/helpers/exception_user_message.dart';
import 'package:serverpod_cloud_cli/util/common.dart';

/// Logger that logs using the provided [cli.Logger].
/// This interface is created to make it easier to follow the UX guidelines, as outlined in this issue: https://github.com/serverpod/serverpod_cloud/issues/371
///
/// # Guiding principles
/// ## Clear and Concise Communication

/// Use precise language: messages should be brief but informative, guiding users without overwhelming them.

/// ## Consistency in Interactions

/// Standardize the phrasing, formatting, and style of commands, errors, and responses.
/// Use predictable patterns that help users form mental models.

/// ## Thematic 🚀 , Yet Professional
/// In general use space-themed metaphors sparingly to keep the interface professional, but they can be used where it's suitable.

/// Align messaging with the Serverpod space theme in a way that conveys progress and exploration.
/// Avoid overly playful language but embrace an aspirational, empowering tone (e.g., "✅ Booster liftoff: Upload successful!" for build status instead of “We’re blasting off!”).

/// Integrate subtle rocket/space motifs in ASCII art or feedback visuals, where appropriate, without distracting from usability.

/// ## Actionable Feedback

/// Every error or success message should offer guidance or a pathway forward (e.g., suggest corrections or next commands).

/// ## Graceful Handling of Errors

/// Acknowledge the user’s intent with empathy. Avoid making them feel at fault or blaming them.

/// ## Messaging guidelines
///
/// The language used should always be written in an objective tone and avoid addressing the user with "you" or refer to the system as "we" (e.g. "The project was deployed" instead of "Your project was deployed").
class CommandLogger {
  final cli.Logger _logger;

  GlobalConfiguration? configuration;

  CommandLogger(
    final cli.Logger logger, {
    this.configuration,
  }) : _logger = logger;

  factory CommandLogger.create(
      [final cli.LogLevel logLevel = cli.LogLevel.info]) {
    const Map<String, String> windowsReplacements = {
      '🚀': '',
    };

    final stdOutLogger = Platform.isWindows
        ? cli.StdOutLogger(logLevel, replacements: windowsReplacements)
        : cli.StdOutLogger(logLevel);

    return CommandLogger(stdOutLogger);
  }

  cli.LogLevel get logLevel => _logger.logLevel;
  set logLevel(final cli.LogLevel level) => _logger.logLevel = level;

  int? get wrapTextColumn => _logger.wrapTextColumn;

  /// **Debug Messages Guidelines**
  ///
  /// Should contain information that could be helpful when debugging user issues.
  /// These messages are not intended to be shown to the user.
  void debug(
    final String message, {
    final cli.TextLogType type = cli.TextLogType.normal,
    final bool newParagraph = false,
  }) {
    _logger.debug(
      message,
      type: type,
      newParagraph: newParagraph,
    );
  }

  /// **Error Messages Guidelines**
  ///
  /// Tone: Polite and encouraging, never accusatory.
  /// Format:
  /// ```bash
  /// ERROR: <Short description>
  /// <Actionable suggestion/hint>
  /// ```
  /// Example:
  /// ```bash
  /// ERROR: Could not update the environment variable.
  /// The variable does not exist, double check the name by running the list command:
  ///  $ scloud env list
  /// ```
  void error(
    final String message, {
    final Exception? exception,
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
  }) {
    final String msg;
    if (exception != null) {
      final separator = isPunctuation(message[message.length - 1]) ? ' ' : ': ';
      final eMessage = userFriendlyExceptionMessage(exception);
      final suffix = isPunctuation(eMessage[eMessage.length - 1]) ? '' : '.';
      msg = '$message$separator$eMessage$suffix';
    } else {
      msg = message;
    }

    _logger.error(
      msg,
      newParagraph: newParagraph,
      stackTrace: stackTrace,
    );

    if (hint != null) {
      _logger.info(
        hint,
        type: cli.TextLogType.hint,
      );
    }
  }

  Future<void> flush() async {
    await _logger.flush();
  }

  /// **Information Messages Guidelines**
  ///
  /// Used for messages to the user when the message does not fit into
  /// success, error or warning types.
  /// Can be used for general information.
  ///
  /// Tone: Neutral and informative.
  ///
  /// Format:
  /// ```bash
  /// <Informational message>
  /// ```
  /// Example:
  /// ```bash
  /// The current project is set to my-project.
  /// ```
  void info(
    final String message, {
    final bool newParagraph = false,
  }) {
    _logger.info(
      message,
      type: cli.TextLogType.normal,
      newParagraph: newParagraph,
    );
  }

  /// **Box Messages Guidelines**
  ///
  /// Same as [info] but with a box around the message.
  void box(
    final String message, {
    final bool newParagraph = false,
  }) {
    _logger.info(
      message,
      type: const cli.BoxLogType(newParagraph: true),
      newParagraph: newParagraph,
    );
  }

  /// **Line Output Guidelines**
  ///
  /// Used for line-oriented output that should not be modified or formatted
  /// other than each line being appended with a newline.
  /// Typical use cases are logs, tables, and line-oriented text data dumps.
  ///
  /// Format:
  /// ```bash
  /// <line of text>
  /// ```
  /// Example:
  /// ```bash
  /// Fetching logs from oldest to newest. Display time zone: local (CET).
  /// Timestamp                   | Level   | Content
  /// ----------------------------+---------+--------
  /// 2024-11-26 16:38:44.113541  | INFO    | Webserver listening on port 8082
  /// ```
  void line(
    final String line,
  ) {
    _logger.info(
      '$line\n',
      type: cli.RawLogType(),
      newParagraph: false,
    );
  }

  /// **Raw Messages Guidelines**
  ///
  /// Used for raw text output for full control over the output.
  /// You should normally not use this directly, but rely on prebuilt printers
  /// like [TablePrinter]. This method is useful when constructing custom
  /// printers where additional control may be needed.
  ///
  /// Setting the [style] to [TextLogStyle.hint] will output the content in a
  /// dark gray color.
  ///
  /// Format:
  /// ```bash
  /// <content>
  /// ```
  void raw(
    final String content, {
    final cli.AnsiStyle? style,
    final cli.LogLevel logLevel = cli.LogLevel.info,
  }) {
    final String characters = style?.wrap(content) ?? content;

    _logger.write(characters, logLevel, newLine: false, newParagraph: false);
  }

  /// **List Guidelines**
  ///
  /// Use when displaying a list of items. Uses info log level.
  ///
  /// Format:
  /// ```bash
  /// <Optional header>
  ///  • <Item 1>
  ///  • ...
  /// ```
  /// Example:
  /// ```bash
  /// Follow these steps:
  ///  • first step
  ///  • second step
  /// ```
  void list(
    final Iterable<String> items, {
    final String? title,
    final bool newParagraph = false,
  }) {
    if (title != null) {
      _logger.info(
        title,
        type: cli.TextLogType.normal,
        newParagraph: newParagraph,
      );
    }

    items.forEachIndexed((final i, final item) {
      _logger.info(
        item,
        type: cli.TextLogType.bullet,
        newParagraph: i == 0 && newParagraph && title == null,
      );
    });
  }

  /// **Progress Messages Guidelines**
  ///
  /// Format:
  /// ```bash
  /// <Resource or action that is awaited>
  /// ```
  /// Example:
  /// ```bash
  /// Waiting for authentication to complete...
  /// ```
  Future<bool> progress(
    final String message,
    final Future<bool> Function() runner, {
    final bool newParagraph = false,
  }) async {
    return _logger.progress(message, runner, newParagraph: newParagraph);
  }

  /// **Success Messages Guidelines**
  ///
  /// Tone: Affirmative and empowering.
  /// Format:
  /// ```bash
  /// <Action outcome> <Optional follow-up>
  /// ```
  /// Example:
  /// ```bash
  /// Successfully linked the project! 🚀
  /// The --project flag can now be omitted from commands.
  /// ```
  void success(
    final String message, {
    final bool trailingRocket = false,
    final bool newParagraph = false,
    final String? followUp,
  }) {
    _logger.info(
      '$message${trailingRocket ? ' 🚀' : ''}',
      type: cli.TextLogType.header,
      newParagraph: newParagraph,
    );

    if (followUp != null) {
      _logger.info(
        followUp,
        type: cli.TextLogType.normal,
      );
    }
  }

  /// **Terminal Command Messages Guidelines**
  ///
  /// Format:
  /// ```bash
  /// <Imperative sentance>
  ///   $ <Command>
  /// ```
  /// Example:
  /// ```bash
  /// Run the following command to see all projects:
  ///  $ scloud projects list
  /// ```
  void terminalCommand(
    final String command, {
    final String? message,
    final bool newParagraph = false,
  }) {
    if (message != null) {
      _logger.info(
        message,
        newParagraph: newParagraph,
        type: cli.TextLogType.normal,
      );
    }

    _logger.info(
      command,
      type: cli.TextLogType.command,
      newParagraph: newParagraph && message == null,
    );
  }

  /// **Warning Messages Guidelines**
  ///
  /// Use if the CLI can continue to run but the user should still be warned
  /// that something went wrong or is not as expected.
  /// Ensure to always provide actionable guidance on how to resolve the issue.
  ///
  /// Format:
  /// ```bash
  /// WARNING: <Short description>
  /// <Actionable suggestion/hint>
  /// ```
  void warning(
    final String message, {
    final bool newParagraph = false,
    final String? hint,
  }) {
    _logger.warning(
      message,
      newParagraph: newParagraph,
    );

    if (hint != null) {
      _logger.info(
        hint,
        type: cli.TextLogType.hint,
      );
    }
  }

  /// ***Confirmation Messages Guidelines***
  ///
  /// Prompts the user for a `y/n` confirmation.
  /// Accepts an optional [defaultValue] to specify what happens when the user simply presses Enter.
  /// Returns `true` for "yes" or "y" and `false` for "no" or "n".
  ///
  /// Format:
  /// ```bash
  /// <message prompt> [y/n]:
  /// ```
  Future<bool> confirm(
    final String message, {
    final bool? defaultValue,
  }) async {
    if (configuration?.skipConfirmation == true) {
      return true;
    }

    return cli.confirm(
      message,
      defaultValue: defaultValue,
      logger: _logger,
    );
  }

  /// ***Input Request Guidelines***
  ///
  /// Prompts the user for a string.
  /// Accepts an optional [defaultValue] to specify what happens when the user simply presses Enter.
  /// Returns the string the user entered / accepted.
  ///
  /// Format:
  /// ```bash
  /// <message prompt>:
  /// ```
  Future<String> input(
    final String message, {
    final String? defaultValue,
  }) async {
    // TODO: Replace implementation with cli.input() when that is properly exposed by cli_tools
    final defaultDescription = defaultValue == null ? '' : ' ($defaultValue)';

    _logger.write(
      '$message$defaultDescription: ',
      cli.LogLevel.info,
      newLine: false,
      newParagraph: false,
    );
    final input = stdin.readLineSync()?.trim();
    final missingInput = input == null || input.isEmpty;
    if (missingInput) {
      return defaultValue ?? '';
    }

    return input;
  }
}

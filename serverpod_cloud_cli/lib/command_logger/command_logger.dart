import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:collection/collection.dart';

/// Logger that logs using the provided [Logger].
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
  final Logger _logger;

  CommandLogger(final Logger logger) : _logger = logger;

  factory CommandLogger.create([final LogLevel logLevel = LogLevel.info]) {
    const Map<String, String> windowsReplacements = {
      '🚀': '',
    };

    final stdOutLogger = Platform.isWindows
        ? StdOutLogger(logLevel, replacements: windowsReplacements)
        : StdOutLogger(logLevel);

    return CommandLogger(stdOutLogger);
  }

  LogLevel get logLevel => _logger.logLevel;
  set logLevel(final LogLevel level) => _logger.logLevel = level;

  int? get wrapTextColumn => _logger.wrapTextColumn;

  /// **Debug Messages Guidelines**
  ///
  /// Should contain information that could be helpful when debugging user issues.
  /// These messages are not intended to be shown to the user.
  void debug(
    final String message, {
    final TextLogType type = TextLogType.normal,
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
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
  }) {
    _logger.error(
      message,
      newParagraph: newParagraph,
      stackTrace: stackTrace,
    );

    if (hint != null) {
      _logger.info(
        hint,
        type: TextLogType.hint,
      );
    }
  }

  Future<void> flush() async {
    await _logger.flush();
  }

  /// **Information Messages Guidelines**
  ///
  /// Use when the message does not fit into success, error or warning types.
  /// Can be used for tables, lists, or general information.
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
      type: TextLogType.normal,
      newParagraph: newParagraph,
    );
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
    final List<String> items, {
    final String? title,
    final bool newParagraph = false,
  }) {
    if (title != null) {
      _logger.info(
        title,
        type: TextLogType.normal,
        newParagraph: newParagraph,
      );
    }

    items.forEachIndexed((final i, final item) {
      _logger.info(
        items[i],
        type: TextLogType.bullet,
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
  /// The --project-id flag can now be omitted from commands.
  /// ```
  void success(
    final String message, {
    final bool trailingRocket = false,
    final bool newParagraph = false,
    final String? followUp,
  }) {
    _logger.info(
      '$message${trailingRocket ? ' 🚀' : ''}',
      type: TextLogType.header,
      newParagraph: newParagraph,
    );

    if (followUp != null) {
      _logger.info(
        followUp,
        type: TextLogType.normal,
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
        type: TextLogType.normal,
      );
    }

    _logger.info(
      command,
      type: TextLogType.command,
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
        type: TextLogType.hint,
      );
    }
  }
}

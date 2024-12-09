import 'package:cli_tools/cli_tools.dart';

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

  LogLevel get logLevel => _logger.logLevel;
  set logLevel(final LogLevel level) => _logger.logLevel = level;

  int? get wrapTextColumn => _logger.wrapTextColumn;

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
  /// [Error] <Short description>: <Actionable suggestion>
  /// ```
  /// Example:
  /// ```bash
  /// [Error] Could not update the environment variable: the variable does not exist, double check the name by running the `scloud list` command.
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
        newParagraph: true,
        type: TextLogType.hint,
      );
    }
  }

  Future<void> flush() async {
    await _logger.flush();
  }

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

    for (var i = 0; i < items.length; i++) {
      _logger.info(
        items[i],
        type: TextLogType.bullet,
        newParagraph: i == 0 && newParagraph && title == null,
      );
    }
  }

  Future<bool> progress(
    final String message,
    final Future<bool> Function() runner, {
    final bool newParagraph = false,
  }) async {
    return _logger.progress(message, runner, newParagraph: newParagraph);
  }

  /// **Success Messages Guidelines**
  /// Tone: Affirmative and empowering.
  /// Format:
  /// ```bash
  /// [Success] <Action outcome> <Optional follow-up>
  /// ```
  /// Example:
  /// ```bash
  /// [Success] The project was successfully deployed! 🚀 Run `scloud status` to see the build logs.
  /// ```
  void success(
    final String message, {
    final bool trailingRocket = false,
    final bool newParagraph = false,
    final String? followUp,
  }) {
    _logger.info(
      '$message${trailingRocket ? '🚀' : ''}',
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
  /// Use only if necessary and ensure to provide actionable guidance on how to resolve the issue.
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

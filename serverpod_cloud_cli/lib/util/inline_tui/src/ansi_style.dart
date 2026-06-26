/// Standard ANSI escape code for terminal colors and styles.
enum AnsiStyle {
  terminalDefault('\x1B[39m'),
  reset('\x1B[0m'),
  red('\x1B[91m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  cyan('\x1B[36m'),
  lightGreen('\x1B[92m'),
  darkGray('\x1B[90m'),
  gray('\x1B[2m'),
  cyanBold('\x1B[1;36m'),
  bold('\x1B[1m'),
  italic('\x1B[3m');

  /// Creates a new instance of [AnsiStyle].
  const AnsiStyle(this.ansiCode);

  /// The ANSI escape code for the style.
  final String ansiCode;
}

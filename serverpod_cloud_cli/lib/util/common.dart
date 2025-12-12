import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

/// Returns the maximum value from an iterable of values, which must extend [Comparable].
T max<T extends Comparable>(final Iterable<T> values) {
  return values.reduce((final a, final b) => a.compareTo(b) > 0 ? a : b);
}

extension TimezonedString on DateTime {
  /// Converts this date-time to a string in either local or UTC time zone.
  /// If [numChars] is provided, the string will be truncated to that length.
  /// Note that is [inUtc] is true, 'z' will be appended to the string regardless of [numChars].
  String toTzString(final bool inUtc, [final int? numChars]) {
    final s = inUtc ? toUtc().toString() : toLocal().toString();
    final trunc = numChars == null ? s : s.substring(0, numChars);
    return inUtc && !trunc.endsWith('Z') ? '${trunc}z' : trunc;
  }
}

void logProjectDirIsNotAServerpodServerDirectory(
  final CommandLogger logger, [
  final String? projectDir,
]) {
  if (projectDir != null) {
    logger.error(
      '`$projectDir` is not a Serverpod server directory.',
      hint: "Provide the project's server directory and try again.",
    );
  } else {
    logger.error(
      'The provided project directory (either through the '
      '--project-dir flag or found near the current directory) '
      'is not a Serverpod server directory.',
      hint: "Provide the project's server directory and try again.",
    );
  }
}

/// Returns true if the character is a punctuation mark.
bool isPunctuation(final String char) {
  return RegExp(r'\p{P}', unicode: true).hasMatch(char);
}

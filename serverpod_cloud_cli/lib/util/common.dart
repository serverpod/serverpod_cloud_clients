import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

/// Returns the maximum value from an iterable of values, which must extend [Comparable].
T max<T extends Comparable>(Iterable<T> values) {
  return values.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
}

extension TimezonedString on DateTime {
  /// Converts this date-time to a string in either local or UTC time zone.
  /// If [numChars] is provided, the string will be truncated to that length.
  ///
  /// The result carries no time zone marker - state the zone with
  /// [timeZoneLabel] where the value is displayed.
  String toTzString(bool inUtc, [int? numChars]) {
    final s = inUtc ? toUtc().toString() : toLocal().toString();
    return numChars == null ? s : s.substring(0, numChars);
  }

  /// Converts this date-time to a string in either local or UTC time zone,
  /// followed by the [timeZoneLabel] of that zone in parentheses.
  String toLabeledTzString(bool inUtc, [int? numChars]) {
    return '${toTzString(inUtc, numChars)} (${timeZoneLabel(inUtc)})';
  }
}

/// The user-facing name of the time zone that timestamps are displayed in.
String timeZoneLabel(bool inUtc) => inUtc ? 'UTC' : 'local';

void logProjectDirIsNotAServerpodServerDirectory(
  CommandLogger logger, [
  String? projectDir,
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
bool isPunctuation(String char) {
  return RegExp(r'\p{P}', unicode: true).hasMatch(char);
}

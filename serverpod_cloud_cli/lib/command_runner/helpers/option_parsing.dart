/// Common option value parsers.
abstract final class OptionParsing {
  /// Parses a date string into a [DateTime] object.
  /// Throws [ArgumentError] if parsing failed.
  /// This is more forgiving than [DateTime.parse], in addition
  /// to the standard T and space separators between date and time
  /// it also allows [-_/:t].
  static DateTime parseDate(final String dateStr) {
    final value = DateTime.tryParse(dateStr);
    if (value != null) return value;
    if (dateStr.length >= 11 && '-_/:t'.contains(dateStr[10])) {
      final value = DateTime.tryParse(
          '${dateStr.substring(0, 10)}T${dateStr.substring(11)}');
      if (value != null) return value;
    }
    throw ArgumentError('Failed to parse date-time option "$dateStr".\n'
        'Value must be an ISO date-time: '
        'YYYY-MM-DD HH:MM:SSz (or shorter) '
        'Alternate date/time separators: Tt-_/:');
  }
}

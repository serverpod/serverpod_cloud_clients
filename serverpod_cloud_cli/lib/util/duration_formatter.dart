extension DurationFormatter on Duration {
  /// Formats a duration in a friendly format
  /// like "1d 2h 3m 4s 5ms 6us".
  String friendlyFormat() {
    return friendlyFormatDuration(this);
  }
}

/// Formats a duration in a friendly format
/// like "1d 2h 3m 4s 5ms 6us".
String friendlyFormatDuration(final Duration value) {
  if (value == Duration.zero) return '0s';

  final sign = value.isNegative ? '-' : '';
  final d = _unitStr(value.inDays, null, 'd');
  final h = _unitStr(value.inHours, 24, 'h');
  final m = _unitStr(value.inMinutes, 60, 'm');
  final s = _unitStr(value.inSeconds, 60, 's');
  final ms = _unitStr(value.inMilliseconds, 1000, 'ms');
  final us = _unitStr(value.inMicroseconds, 1000, 'us');

  final elements = [d, h, m, s, ms, us];
  final displayed = elements.where((final element) => element.isNotEmpty);

  return '$sign${displayed.join(' ')}';
}

String _unitStr(final int value, final int? mod, final String unit) {
  final absValue = value.abs();
  if (mod == null) {
    return absValue > 0 ? '$absValue$unit' : '';
  }
  return absValue % mod > 0 ? '${absValue.remainder(mod)}$unit' : '';
}

import 'package:serverpod_cloud_cli/constants.dart' show numTimeStampChars;
import 'package:serverpod_cloud_cli/util/common.dart';

const _relativeTimeLimit = Duration(days: 7);

extension DurationFormatter on Duration {
  /// Formats a duration in a friendly format
  /// like "1d 2h 3m 4s 5ms 6us".
  String friendlyFormat() {
    return friendlyFormatDuration(this);
  }
}

/// Formats a duration in a friendly format
/// like "1d 2h 3m 4s 5ms 6us".
String friendlyFormatDuration(Duration value) {
  if (value == Duration.zero) return '0s';

  final sign = value.isNegative ? '-' : '';
  final d = _unitStr(value.inDays, null, 'd');
  final h = _unitStr(value.inHours, 24, 'h');
  final m = _unitStr(value.inMinutes, 60, 'm');
  final s = _unitStr(value.inSeconds, 60, 's');
  final ms = _unitStr(value.inMilliseconds, 1000, 'ms');
  final us = _unitStr(value.inMicroseconds, 1000, 'us');

  final elements = [d, h, m, s, ms, us];
  final displayed = elements.where((element) => element.isNotEmpty);

  return '$sign${displayed.join(' ')}';
}

/// Formats a past [time] as a coarse, human-friendly relative-time
/// phrase like "2 hours ago" or "just now", measured against [now]
/// which defaults to the current time.
///
/// Times more than 7 days in the past are formatted as an absolute
/// timestamp instead, like "2026-07-23 09:15:05" — in the local time
/// zone, or in UTC if [inUtc] is set.
String friendlyPastTimeFormat(
  DateTime time, {
  bool inUtc = false,
  DateTime? now,
}) {
  final elapsed = (now ?? DateTime.now()).difference(time);
  if (elapsed > _relativeTimeLimit) {
    return time.toTzString(inUtc, numTimeStampChars);
  }
  return friendlyAgoFormat(elapsed);
}

/// Formats an elapsed duration as a coarse, human-friendly
/// relative-time phrase like "2 hours ago" or "just now".
///
/// Only the largest applicable time unit is shown,
/// and durations under 5 seconds are treated as "just now".
String friendlyAgoFormat(Duration elapsed) {
  if (elapsed.inSeconds < 5) {
    return 'just now';
  }
  if (elapsed.inMinutes < 1) {
    return _pluralizedAgo(elapsed.inSeconds, 'second');
  }
  if (elapsed.inHours < 1) {
    return _pluralizedAgo(elapsed.inMinutes, 'minute');
  }
  if (elapsed.inDays < 1) {
    return _pluralizedAgo(elapsed.inHours, 'hour');
  }
  return _pluralizedAgo(elapsed.inDays, 'day');
}

String _pluralizedAgo(int count, String unit) {
  final pluralizedUnit = count == 1 ? unit : '${unit}s';
  return '$count $pluralizedUnit ago';
}

String _unitStr(int value, int? mod, String unit) {
  final absValue = value.abs();
  if (mod == null) {
    return absValue > 0 ? '$absValue$unit' : '';
  }
  return absValue % mod > 0 ? '${absValue.remainder(mod)}$unit' : '';
}

import 'package:intl/intl.dart';

abstract final class DateTimeFormatter {
  static final DateFormat _dateOnly = DateFormat('yyyy-MM-dd');
  static final DateFormat _timestamp = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _timestampWithSeconds = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
  );

  static String fullTimestamp(DateTime date) {
    return _timestamp.format(date.toLocal());
  }

  /// Like [fullTimestamp] but with seconds precision
  /// (e.g. 2026-05-20 10:22:00).
  static String fullTimestampWithSeconds(DateTime date) {
    return _timestampWithSeconds.format(date.toLocal());
  }

  static String dateOnly(DateTime date) {
    return _dateOnly.format(date.toLocal());
  }

  static String relativeTime(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  static String relativeDate(DateTime date, {DateTime? now}) {
    final referenceTime = (now ?? DateTime.now()).toLocal();
    final localDate = date.toLocal();
    final refAtMidnight = DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
    final dateAtMidnight = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    final calendarDaysDiff = refAtMidnight.difference(dateAtMidnight).inDays;

    if (calendarDaysDiff == 0) {
      return 'today';
    } else if (calendarDaysDiff == 1) {
      return 'yesterday';
    } else if (calendarDaysDiff < 7) {
      return '$calendarDaysDiff days ago';
    } else {
      return dateOnly(date);
    }
  }

  static String duration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static String deploymentTimestamp({
    required DateTime? startedAt,
    DateTime? endedAt,
    int relativeThresholdDays = 7,
    DateTime? now,
  }) {
    if (startedAt == null) {
      return 'Unknown time';
    }

    final referenceTime = now ?? DateTime.now();
    final difference = referenceTime.difference(startedAt);
    final timeAgo = difference.inDays > relativeThresholdDays
        ? fullTimestamp(startedAt)
        : relativeTime(difference);
    final durationStr = endedAt != null
        ? duration(endedAt.difference(startedAt))
        : null;

    if (durationStr != null) {
      return '$timeAgo • $durationStr';
    }
    return timeAgo;
  }
}

import 'package:test/test.dart';
import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';

void main() {
  group('DateTimeFormatter.fullTimestamp', () {
    test('When date has single-digit month and day, Then pads with zero', () {
      final date = DateTime(2025, 1, 5, 9, 3);
      expect(DateTimeFormatter.fullTimestamp(date), '2025-01-05 09:03');
    });

    test('When date has two-digit month and day, Then formats correctly', () {
      final date = DateTime(2025, 12, 25, 14, 30);
      expect(DateTimeFormatter.fullTimestamp(date), '2025-12-25 14:30');
    });
  });

  group('DateTimeFormatter.dateOnly', () {
    test('When date is given, Then returns yyyy-MM-dd only', () {
      final date = DateTime(2025, 2, 4, 14, 30);
      expect(DateTimeFormatter.dateOnly(date), '2025-02-04');
    });

    test('When date has single-digit month and day, Then pads with zero', () {
      final date = DateTime(2025, 1, 5);
      expect(DateTimeFormatter.dateOnly(date), '2025-01-05');
    });

    test('When the date is in UTC, Then it is formatted in local time', () {
      final date = DateTime(2025, 2, 4, 23, 30).toUtc();
      expect(DateTimeFormatter.dateOnly(date), '2025-02-04');
    });
  });

  group('DateTimeFormatter.relativeTime', () {
    test('When difference is zero, Then returns "Just now"', () {
      expect(DateTimeFormatter.relativeTime(Duration.zero), 'Just now');
    });

    test('When difference is under a minute, Then returns "Just now"', () {
      expect(
        DateTimeFormatter.relativeTime(const Duration(seconds: 59)),
        'Just now',
      );
    });

    test('When difference is one minute, Then returns "1 minute ago"', () {
      expect(
        DateTimeFormatter.relativeTime(const Duration(minutes: 1)),
        '1 minute ago',
      );
    });

    test(
      'When difference is multiple minutes, Then returns "X minutes ago"',
      () {
        expect(
          DateTimeFormatter.relativeTime(const Duration(minutes: 59)),
          '59 minutes ago',
        );
      },
    );

    test('When difference is one hour, Then returns "1 hour ago"', () {
      expect(
        DateTimeFormatter.relativeTime(const Duration(hours: 1)),
        '1 hour ago',
      );
    });

    test('When difference is multiple hours, Then returns "X hours ago"', () {
      expect(
        DateTimeFormatter.relativeTime(const Duration(hours: 23)),
        '23 hours ago',
      );
    });

    test('When difference is one day, Then returns "1 day ago"', () {
      expect(
        DateTimeFormatter.relativeTime(const Duration(days: 1)),
        '1 day ago',
      );
    });

    test('When difference is multiple days, Then returns "X days ago"', () {
      expect(
        DateTimeFormatter.relativeTime(const Duration(days: 7)),
        '7 days ago',
      );
    });
  });

  group('DateTimeFormatter.duration', () {
    test('When duration is seconds only, Then returns "Xs"', () {
      expect(DateTimeFormatter.duration(const Duration(seconds: 45)), '45s');
    });

    test('When duration is zero seconds, Then returns "0s"', () {
      expect(DateTimeFormatter.duration(Duration.zero), '0s');
    });

    test('When duration has minutes and seconds, Then returns "Xm Ys"', () {
      expect(
        DateTimeFormatter.duration(const Duration(minutes: 2, seconds: 30)),
        '2m 30s',
      );
    });

    test('When duration is minutes only (whole), Then returns "Xm 0s"', () {
      expect(DateTimeFormatter.duration(const Duration(minutes: 5)), '5m 0s');
    });
  });

  group('DateTimeFormatter.deploymentTimestamp', () {
    test('When startedAt is null, Then returns "Unknown time"', () {
      expect(
        DateTimeFormatter.deploymentTimestamp(startedAt: null, endedAt: null),
        'Unknown time',
      );
    });

    test(
      'When startedAt is null and endedAt is set, Then returns "Unknown time"',
      () {
        expect(
          DateTimeFormatter.deploymentTimestamp(
            startedAt: null,
            endedAt: DateTime(2025, 2, 4, 12, 0),
          ),
          'Unknown time',
        );
      },
    );

    test(
      'When startedAt is within threshold and no endedAt, Then returns relative time',
      () {
        final now = DateTime(2025, 2, 4, 12, 0);
        final startedAt = now.subtract(const Duration(hours: 2));
        final result = DateTimeFormatter.deploymentTimestamp(
          startedAt: startedAt,
          endedAt: null,
          now: now,
        );
        expect(result, '2 hours ago');
      },
    );

    test(
      'When startedAt is beyond threshold and no endedAt, Then returns full timestamp',
      () {
        final now = DateTime(2025, 2, 4, 12, 0);
        final startedAt = now.subtract(const Duration(days: 8));
        final result = DateTimeFormatter.deploymentTimestamp(
          startedAt: startedAt,
          endedAt: null,
          relativeThresholdDays: 7,
          now: now,
        );
        expect(result, '2025-01-27 12:00');
      },
    );

    test('When startedAt and endedAt are set, Then includes duration', () {
      final now = DateTime(2025, 2, 4, 12, 0);
      final startedAt = now.subtract(const Duration(hours: 1));
      final endedAt = startedAt.add(const Duration(minutes: 15, seconds: 30));
      final result = DateTimeFormatter.deploymentTimestamp(
        startedAt: startedAt,
        endedAt: endedAt,
        now: now,
      );
      expect(result, '1 hour ago • 15m 30s');
    });
  });

  group('DateTimeFormatter.relativeDate', () {
    group('Given same calendar day', () {
      test(
        'When date is same moment as reference time, Then returns "today"',
        () {
          final now = DateTime(2025, 2, 4, 12, 0);
          expect(DateTimeFormatter.relativeDate(now, now: now), 'today');
        },
      );

      test('When date is earlier same day, Then returns "today"', () {
        final now = DateTime(2025, 2, 4, 14, 0);
        final date = DateTime(2025, 2, 4, 9, 0);
        expect(DateTimeFormatter.relativeDate(date, now: now), 'today');
      });

      test('When the date is in UTC, Then it is compared in local time', () {
        final now = DateTime(2025, 2, 4, 21, 0);
        final date = DateTime(2025, 2, 4, 23, 30).toUtc();
        expect(DateTimeFormatter.relativeDate(date, now: now), 'today');
      });
    });

    group('Given reference is 01:00 today and date is 23:00 yesterday', () {
      test(
        'When relativeDate is called, Then returns "yesterday" (not today)',
        () {
          final now = DateTime(2025, 2, 4, 1, 0);
          final date = DateTime(2025, 2, 3, 23, 0);
          expect(DateTimeFormatter.relativeDate(date, now: now), 'yesterday');
        },
      );
    });

    group('Given reference is 23:00 today and date is 01:00 today', () {
      test('When relativeDate is called, Then returns "today"', () {
        final now = DateTime(2025, 2, 4, 23, 0);
        final date = DateTime(2025, 2, 4, 1, 0);
        expect(DateTimeFormatter.relativeDate(date, now: now), 'today');
      });
    });

    group('Given date is one full calendar day before reference', () {
      test('When relativeDate is called, Then returns "yesterday"', () {
        final now = DateTime(2025, 2, 4, 12, 0);
        final date = DateTime(2025, 2, 3, 12, 0);
        expect(DateTimeFormatter.relativeDate(date, now: now), 'yesterday');
      });
    });

    group('Given date is 25 hours before reference', () {
      test('When relativeDate is called, Then returns "yesterday"', () {
        final now = DateTime(2025, 2, 4, 12, 0);
        final date = DateTime(2025, 2, 3, 11, 0);
        expect(DateTimeFormatter.relativeDate(date, now: now), 'yesterday');
      });
    });

    group('Given date is 2 calendar days before reference', () {
      test('When relativeDate is called, Then returns "2 days ago"', () {
        final now = DateTime(2025, 2, 4, 12, 0);
        final date = DateTime(2025, 2, 2, 12, 0);
        expect(DateTimeFormatter.relativeDate(date, now: now), '2 days ago');
      });
    });

    group(
      'Given date is 25 hours before reference but 2 calendar days apart (e.g. 23:00 vs 01:00 + 24h)',
      () {
        test('When relativeDate is called, Then returns "2 days ago"', () {
          final now = DateTime(2025, 2, 4, 1, 0);
          final date = DateTime(2025, 2, 2, 23, 0);
          expect(DateTimeFormatter.relativeDate(date, now: now), '2 days ago');
        });
      },
    );

    group('Given date is 6 calendar days before reference', () {
      test('When relativeDate is called, Then returns "6 days ago"', () {
        final now = DateTime(2025, 2, 4, 12, 0);
        final date = DateTime(2025, 1, 29, 12, 0);
        expect(DateTimeFormatter.relativeDate(date, now: now), '6 days ago');
      });
    });

    group('Given date is 7 days before reference', () {
      test(
        'When relativeDate is called, Then returns date-only format (yyyy-MM-dd)',
        () {
          final now = DateTime(2025, 2, 4, 12, 0);
          final date = DateTime(2025, 1, 28, 12, 0);
          expect(DateTimeFormatter.relativeDate(date, now: now), '2025-01-28');
        },
      );
    });

    group('Given date is 30 days before reference', () {
      test(
        'When relativeDate is called, Then returns date-only format (yyyy-MM-dd)',
        () {
          final now = DateTime(2025, 2, 4, 12, 0);
          final date = DateTime(2025, 1, 5, 12, 0);
          expect(DateTimeFormatter.relativeDate(date, now: now), '2025-01-05');
        },
      );
    });
  });
}

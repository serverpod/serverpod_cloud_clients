import 'package:serverpod_cloud_cli/util/duration_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('friendlyFormatDuration', () {
    group('when duration is zero', () {
      test('then returns "0s"', () {
        expect(friendlyFormatDuration(Duration.zero), '0s');
      });
    });

    group('when duration contains a single time unit', () {
      test('then formats days correctly', () {
        expect(friendlyFormatDuration(const Duration(days: 1)), '1d');
        expect(friendlyFormatDuration(const Duration(days: 5)), '5d');
        expect(friendlyFormatDuration(const Duration(days: 365)), '365d');
      });

      test('then formats hours correctly', () {
        expect(friendlyFormatDuration(const Duration(hours: 1)), '1h');
        expect(friendlyFormatDuration(const Duration(hours: 12)), '12h');
        expect(friendlyFormatDuration(const Duration(hours: 23)), '23h');
      });

      test('then formats minutes correctly', () {
        expect(friendlyFormatDuration(const Duration(minutes: 1)), '1m');
        expect(friendlyFormatDuration(const Duration(minutes: 30)), '30m');
        expect(friendlyFormatDuration(const Duration(minutes: 59)), '59m');
      });

      test('then formats seconds correctly', () {
        expect(friendlyFormatDuration(const Duration(seconds: 1)), '1s');
        expect(friendlyFormatDuration(const Duration(seconds: 30)), '30s');
        expect(friendlyFormatDuration(const Duration(seconds: 59)), '59s');
      });

      test('then formats milliseconds correctly', () {
        expect(friendlyFormatDuration(const Duration(milliseconds: 1)), '1ms');
        expect(
          friendlyFormatDuration(const Duration(milliseconds: 500)),
          '500ms',
        );
        expect(
          friendlyFormatDuration(const Duration(milliseconds: 999)),
          '999ms',
        );
      });

      test('then formats microseconds correctly', () {
        expect(friendlyFormatDuration(const Duration(microseconds: 1)), '1us');
        expect(
          friendlyFormatDuration(const Duration(microseconds: 500)),
          '500us',
        );
        expect(
          friendlyFormatDuration(const Duration(microseconds: 999)),
          '999us',
        );
      });
    });

    group('when duration contains multiple time units', () {
      test('then formats days and hours', () {
        expect(
          friendlyFormatDuration(const Duration(days: 1, hours: 2)),
          '1d 2h',
        );
        expect(
          friendlyFormatDuration(const Duration(days: 5, hours: 23)),
          '5d 23h',
        );
      });

      test('then formats hours and minutes', () {
        expect(
          friendlyFormatDuration(const Duration(hours: 2, minutes: 30)),
          '2h 30m',
        );
        expect(
          friendlyFormatDuration(const Duration(hours: 12, minutes: 45)),
          '12h 45m',
        );
      });

      test('then formats minutes and seconds', () {
        expect(
          friendlyFormatDuration(const Duration(minutes: 5, seconds: 30)),
          '5m 30s',
        );
        expect(
          friendlyFormatDuration(const Duration(minutes: 59, seconds: 59)),
          '59m 59s',
        );
      });

      test('then formats seconds and milliseconds', () {
        expect(
          friendlyFormatDuration(const Duration(seconds: 5, milliseconds: 500)),
          '5s 500ms',
        );
        expect(
          friendlyFormatDuration(
            const Duration(seconds: 30, milliseconds: 250),
          ),
          '30s 250ms',
        );
      });

      test('then formats milliseconds and microseconds', () {
        expect(
          friendlyFormatDuration(
            const Duration(milliseconds: 100, microseconds: 500),
          ),
          '100ms 500us',
        );
        expect(
          friendlyFormatDuration(
            const Duration(milliseconds: 5, microseconds: 123),
          ),
          '5ms 123us',
        );
      });

      test('then formats all units together', () {
        expect(
          friendlyFormatDuration(
            const Duration(
              days: 1,
              hours: 2,
              minutes: 3,
              seconds: 4,
              milliseconds: 5,
              microseconds: 6,
            ),
          ),
          '1d 2h 3m 4s 5ms 6us',
        );
      });

      test('then omits zero units', () {
        expect(
          friendlyFormatDuration(
            const Duration(days: 1, minutes: 5, seconds: 10),
          ),
          '1d 5m 10s',
        );
        expect(
          friendlyFormatDuration(const Duration(hours: 3, seconds: 45)),
          '3h 45s',
        );
        expect(
          friendlyFormatDuration(const Duration(days: 2, milliseconds: 100)),
          '2d 100ms',
        );
      });
    });

    group('when duration is negative', () {
      test('then prepends minus sign to output', () {
        expect(friendlyFormatDuration(const Duration(seconds: -1)), '-1s');
        expect(friendlyFormatDuration(const Duration(minutes: -5)), '-5m');
      });

      test('then formats negative durations with multiple units', () {
        expect(
          friendlyFormatDuration(const Duration(hours: -2, minutes: -30)),
          '-2h 30m',
        );
        expect(
          friendlyFormatDuration(
            const Duration(days: -1, hours: -2, minutes: -3, seconds: -4),
          ),
          '-1d 2h 3m 4s',
        );
      });
    });

    group('when duration is very large', () {
      test('then handles hundreds of days', () {
        expect(friendlyFormatDuration(const Duration(days: 999)), '999d');
      });

      test('then converts overflow hours to days', () {
        expect(friendlyFormatDuration(const Duration(hours: 100)), '4d 4h');
      });

      test('then converts overflow seconds to appropriate units', () {
        expect(friendlyFormatDuration(const Duration(seconds: 86400)), '1d');
      });
    });

    group('when duration is at exact unit boundaries', () {
      test('then converts 24 hours to 1 day', () {
        expect(friendlyFormatDuration(const Duration(hours: 24)), '1d');
        expect(friendlyFormatDuration(const Duration(hours: 48)), '2d');
      });

      test('then converts 60 minutes to 1 hour', () {
        expect(friendlyFormatDuration(const Duration(minutes: 60)), '1h');
        expect(friendlyFormatDuration(const Duration(minutes: 120)), '2h');
      });

      test('then converts 60 seconds to 1 minute', () {
        expect(friendlyFormatDuration(const Duration(seconds: 60)), '1m');
        expect(friendlyFormatDuration(const Duration(seconds: 3600)), '1h');
      });

      test('then converts 1000 milliseconds to 1 second', () {
        expect(
          friendlyFormatDuration(const Duration(milliseconds: 1000)),
          '1s',
        );
        expect(
          friendlyFormatDuration(const Duration(milliseconds: 5000)),
          '5s',
        );
      });

      test('then converts 1000 microseconds to 1 millisecond', () {
        expect(
          friendlyFormatDuration(const Duration(microseconds: 1000)),
          '1ms',
        );
        expect(
          friendlyFormatDuration(const Duration(microseconds: 1000000)),
          '1s',
        );
      });
    });
  });

  group('DurationFormatter extension', () {
    group('when calling friendlyFormat on a duration', () {
      test('then formats zero duration', () {
        expect(Duration.zero.friendlyFormat(), '0s');
      });

      test('then formats single unit durations', () {
        expect(const Duration(days: 1).friendlyFormat(), '1d');
        expect(const Duration(seconds: 45).friendlyFormat(), '45s');
      });

      test('then formats multiple unit durations', () {
        expect(
          const Duration(hours: 2, minutes: 30).friendlyFormat(),
          '2h 30m',
        );
        expect(
          const Duration(
            days: 1,
            hours: 2,
            minutes: 3,
            seconds: 4,
            milliseconds: 5,
            microseconds: 6,
          ).friendlyFormat(),
          '1d 2h 3m 4s 5ms 6us',
        );
      });

      test('then formats negative durations', () {
        expect(const Duration(seconds: -30).friendlyFormat(), '-30s');
        expect(
          const Duration(hours: -1, minutes: -15).friendlyFormat(),
          '-1h 15m',
        );
      });
    });
  });

  group('friendlyAgoFormat', () {
    group('when the elapsed duration is zero', () {
      test('then returns "just now"', () {
        expect(friendlyAgoFormat(Duration.zero), 'just now');
      });
    });

    group('when the elapsed duration is at the just-now boundary', () {
      test('then 4 seconds returns "just now"', () {
        expect(friendlyAgoFormat(const Duration(seconds: 4)), 'just now');
      });

      test('then 5 seconds formats as seconds', () {
        expect(friendlyAgoFormat(const Duration(seconds: 5)), '5 seconds ago');
      });
    });

    group('when the elapsed duration is at the minute boundary', () {
      test('then 59 seconds formats as seconds', () {
        expect(
          friendlyAgoFormat(const Duration(seconds: 59)),
          '59 seconds ago',
        );
      });

      test('then 1 minute formats as a singular minute', () {
        expect(friendlyAgoFormat(const Duration(minutes: 1)), '1 minute ago');
      });
    });

    group('when the elapsed duration is at the hour boundary', () {
      test('then 59 minutes formats as minutes', () {
        expect(
          friendlyAgoFormat(const Duration(minutes: 59)),
          '59 minutes ago',
        );
      });

      test('then 1 hour formats as a singular hour', () {
        expect(friendlyAgoFormat(const Duration(hours: 1)), '1 hour ago');
      });
    });

    group('when the elapsed duration is at the day boundary', () {
      test('then 23 hours formats as hours', () {
        expect(friendlyAgoFormat(const Duration(hours: 23)), '23 hours ago');
      });

      test('then 1 day formats as a singular day', () {
        expect(friendlyAgoFormat(const Duration(days: 1)), '1 day ago');
      });
    });

    group('when the elapsed duration mixes units', () {
      test('then hours dominate minutes', () {
        expect(
          friendlyAgoFormat(const Duration(hours: 2, minutes: 14)),
          '2 hours ago',
        );
      });

      test('then days dominate hours', () {
        expect(
          friendlyAgoFormat(const Duration(days: 3, hours: 12)),
          '3 days ago',
        );
      });
    });
  });

  group('friendlyPastTimeFormat', () {
    final now = DateTime(2026, 7, 31, 12, 0, 0);

    group('when the time is recent', () {
      test('then formats as a relative phrase', () {
        expect(
          friendlyPastTimeFormat(
            now.subtract(const Duration(hours: 2)),
            now: now,
          ),
          '2 hours ago',
        );
      });
    });

    group('when the time is at the relative-limit boundary', () {
      test('then exactly 7 days formats as a relative phrase', () {
        expect(
          friendlyPastTimeFormat(
            now.subtract(const Duration(days: 7)),
            now: now,
          ),
          '7 days ago',
        );
      });

      test('then more than 7 days formats as a local timestamp', () {
        expect(
          friendlyPastTimeFormat(
            now.subtract(const Duration(days: 7, seconds: 1)),
            now: now,
          ),
          '2026-07-24 11:59:59',
        );
      });
    });

    group('when the time is long past', () {
      test('then formats as a local timestamp', () {
        expect(
          friendlyPastTimeFormat(DateTime(2026, 7, 1, 9, 15, 5), now: now),
          '2026-07-01 09:15:05',
        );
      });

      test('then formats as a utc timestamp when inUtc is set', () {
        expect(
          friendlyPastTimeFormat(
            DateTime.utc(2026, 7, 1, 9, 15, 5),
            inUtc: true,
            now: now,
          ),
          '2026-07-01 09:15:05z',
        );
      });
    });

    group('when the time is recent and inUtc is set', () {
      test('then still formats as a relative phrase', () {
        expect(
          friendlyPastTimeFormat(
            now.subtract(const Duration(hours: 2)),
            inUtc: true,
            now: now,
          ),
          '2 hours ago',
        );
      });
    });
  });
}

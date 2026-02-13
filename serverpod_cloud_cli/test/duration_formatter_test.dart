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
}

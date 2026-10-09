import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:test/test.dart';

void main() {
  group('Given a date-time with single digit time parts', () {
    final DateTime time = DateTime.utc(2026, 1, 2, 3, 4, 5, 678);

    test('when converting the time of day in UTC '
        'then the parts are zero padded and the fraction is dropped', () {
      expect(time.toTzTimeOfDayString(true), '03:04:05');
    });

    test('when converting the labeled time of day in UTC '
        'then the zone label follows the time', () {
      expect(time.toLabeledTzTimeOfDayString(true), '03:04:05 (UTC)');
    });
  });
}

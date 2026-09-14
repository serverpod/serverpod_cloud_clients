import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given a size below one kilobyte', () {
    test('when it is zero then it is formatted in bytes', () {
      expect(ByteSizeFormatter.format(0), '0 B');
    });

    test('when it is just below the unit boundary then it stays in '
        'bytes', () {
      expect(ByteSizeFormatter.format(999), '999 B');
    });
  });

  group('Given a size of at least one kilobyte', () {
    test('when it is exactly one thousand then it becomes one kilobyte', () {
      expect(ByteSizeFormatter.format(1000), '1.0 kB');
    });

    test('when it is one million then it becomes one megabyte', () {
      expect(ByteSizeFormatter.format(1000000), '1.0 MB');
    });

    test('when it is one billion then it becomes one gigabyte', () {
      expect(ByteSizeFormatter.format(1000000000), '1.0 GB');
    });

    test('when it is 1024 then it renders as 1.0 kB, not 1 KB', () {
      expect(ByteSizeFormatter.format(1024), '1.0 kB');
    });
  });

  group('Given the value needs rounding', () {
    test('when it is below one hundred then one decimal is kept', () {
      expect(ByteSizeFormatter.format(1500), '1.5 kB');
    });

    test('when it is at least one hundred then no decimal is kept', () {
      expect(ByteSizeFormatter.format(150000), '150 kB');
    });

    test('when it rounds up to the next unit then that unit is used', () {
      expect(ByteSizeFormatter.format(999950), '1.0 MB');
    });

    test('when it stays just below the next unit then the unit is kept', () {
      expect(ByteSizeFormatter.format(999400), '999 kB');
    });

    test('when the value would render as 1000 of its unit then the next unit '
        'is used', () {
      expect(ByteSizeFormatter.format(999500), '1.0 MB');
    });

    test('when the value still renders below 1000 of its unit then the unit '
        'is kept', () {
      expect(ByteSizeFormatter.format(999499), '999 kB');
    });

    test('when formatting 12345 then one decimal is kept', () {
      expect(ByteSizeFormatter.format(12345), '12.3 kB');
    });

    test('when formatting 1500000 then it steps up to megabytes', () {
      expect(ByteSizeFormatter.format(1500000), '1.5 MB');
    });
  });

  group('Given the size exceeds the largest unit', () {
    test('when formatted then it stays in petabytes', () {
      expect(ByteSizeFormatter.format(5000000000000000000), '5000 PB');
    });
  });
}

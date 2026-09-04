import 'package:serverpod_cloud_cli/util/byte_size.dart';
import 'package:test/test.dart';

void main() {
  group('Given an unknown size', () {
    test('when formatting then returns a dash', () {
      expect(formatByteSize(null), '-');
    });
  });

  group('Given a size below one kilobyte', () {
    test('when formatting zero then returns bytes', () {
      expect(formatByteSize(0), '0 B');
    });

    test('when formatting 999 then returns bytes', () {
      expect(formatByteSize(999), '999 B');
    });
  });

  group('Given a size of at least one kilobyte', () {
    test('when formatting 1000 then returns one decimal', () {
      expect(formatByteSize(1000), '1.0 kB');
    });

    test('when formatting 12345 then returns one decimal', () {
      expect(formatByteSize(12345), '12.3 kB');
    });

    test('when formatting 123456 then returns no decimals', () {
      expect(formatByteSize(123456), '123 kB');
    });

    test('when formatting 1500000 then steps up to megabytes', () {
      expect(formatByteSize(1500000), '1.5 MB');
    });
  });
}

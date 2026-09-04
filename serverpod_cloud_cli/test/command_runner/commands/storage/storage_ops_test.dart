import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ops.dart';
import 'package:test/test.dart';

void main() {
  group('Given no folder path', () {
    test('when normalizing null then returns null', () {
      expect(StorageOperations.normalizePrefix(null), isNull);
    });

    test('when normalizing an empty string then returns null', () {
      expect(StorageOperations.normalizePrefix(''), isNull);
    });

    test('when normalizing whitespace then returns null', () {
      expect(StorageOperations.normalizePrefix('  '), isNull);
    });

    test('when normalizing a lone slash then returns null', () {
      expect(StorageOperations.normalizePrefix('/'), isNull);
    });
  });

  group('Given a folder path', () {
    test('when it has no trailing slash then one is added', () {
      expect(StorageOperations.normalizePrefix('docs'), 'docs/');
    });

    test('when it has a trailing slash then it is kept as is', () {
      expect(StorageOperations.normalizePrefix('docs/'), 'docs/');
    });

    test('when it has a leading slash then it is stripped', () {
      expect(StorageOperations.normalizePrefix('/docs/'), 'docs/');
    });

    test('when it is nested then the whole path is kept', () {
      expect(
        StorageOperations.normalizePrefix('docs/reports'),
        'docs/reports/',
      );
    });

    test('when it has repeated slashes then they collapse to one', () {
      expect(StorageOperations.normalizePrefix('//docs//'), 'docs/');
    });

    test('when it is padded with whitespace then it is trimmed', () {
      expect(StorageOperations.normalizePrefix('  docs  '), 'docs/');
    });
  });
}

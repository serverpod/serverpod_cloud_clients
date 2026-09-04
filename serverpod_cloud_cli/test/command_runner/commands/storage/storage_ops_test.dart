import 'dart:io';

import 'package:path/path.dart' as p;
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

  group('Given a single file to upload', () {
    test('when no path is given then the file name is used', () {
      expect(StorageOperations.resolveUploadPath(null, 'a.png'), 'a.png');
    });

    test('when the path is blank then the file name is used', () {
      expect(StorageOperations.resolveUploadPath('  ', 'a.png'), 'a.png');
    });

    test('when the path ends with a slash then the file name is appended', () {
      expect(
        StorageOperations.resolveUploadPath('avatars/', 'a.png'),
        'avatars/a.png',
      );
    });

    test('when the path has a leading slash then it is stripped', () {
      expect(
        StorageOperations.resolveUploadPath('/avatars/', 'a.png'),
        'avatars/a.png',
      );
    });

    test('when the path is a plain path then it renames the file', () {
      expect(
        StorageOperations.resolveUploadPath('avatars/u1.png', 'a.png'),
        'avatars/u1.png',
      );
    });
  });

  group('Given a directory to upload', () {
    test('when no path is given then the directory name is kept', () {
      expect(
        StorageOperations.resolveFolderUploadPath(null, 'avatars', 'u1.png'),
        'avatars/u1.png',
      );
    });

    test('when the path ends with a slash then the name is nested', () {
      expect(
        StorageOperations.resolveFolderUploadPath('docs/', 'avatars', 'u1.png'),
        'docs/avatars/u1.png',
      );
    });

    test('when the path has a leading slash then it is stripped', () {
      expect(
        StorageOperations.resolveFolderUploadPath(
          '/docs/',
          'avatars',
          'u1.png',
        ),
        'docs/avatars/u1.png',
      );
    });

    test('when the path is a plain path then it renames the directory', () {
      expect(
        StorageOperations.resolveFolderUploadPath(
          'images',
          'avatars',
          'u1.png',
        ),
        'images/u1.png',
      );
    });

    test('when the file is nested then the structure is kept', () {
      expect(
        StorageOperations.resolveFolderUploadPath(
          null,
          'avatars',
          'sub/u1.png',
        ),
        'avatars/sub/u1.png',
      );
    });
  });

  group('Given a file to download', () {
    test('when no output is given then the file name is used', () {
      expect(
        StorageOperations.resolveDownloadPath(null, 'docs/report.pdf').path,
        'report.pdf',
      );
    });

    test('when the output is a file then it is used as is', () {
      final output = File(p.join('out', 'q3.pdf'));

      expect(
        StorageOperations.resolveDownloadPath(output, 'docs/report.pdf').path,
        output.path,
      );
    });

    test('when the output is a directory then the file name is appended', () {
      final output = Directory('downloads');

      expect(
        StorageOperations.resolveDownloadPath(output, 'docs/report.pdf').path,
        p.join('downloads', 'report.pdf'),
      );
    });
  });
}

import 'dart:io';

import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/file_dir_option.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a path to an existing file', () {
    test('when parsed then it resolves to a File', () async {
      await d.file('a.txt', 'contents').create();

      const option = FileDirOption();
      final parsed = option.valueParser.parse(p.join(d.sandbox, 'a.txt'));

      expect(parsed, isA<File>());
    });
  });

  group('Given a path to an existing directory', () {
    test('when parsed then it resolves to a Directory', () async {
      await d.dir('a-folder').create();

      const option = FileDirOption();
      final parsed = option.valueParser.parse(p.join(d.sandbox, 'a-folder'));

      expect(parsed, isA<Directory>());
    });
  });

  group('Given a path that does not exist', () {
    test('when parsed then it resolves to a File', () {
      const option = FileDirOption();
      final parsed = option.valueParser.parse('missing-path');

      expect(parsed, isA<File>());
    });
  });

  group('Given mode mayExist', () {
    const option = FileDirOption();

    test('when the path does not exist then validation passes', () {
      expect(() => option.validateValue(File('missing.png')), returnsNormally);
    });

    test('when the path exists then validation passes', () async {
      await d.file('a.txt', 'contents').create();

      expect(
        () => option.validateValue(File(p.join(d.sandbox, 'a.txt'))),
        returnsNormally,
      );
    });
  });

  group('Given mode mustExist', () {
    const option = FileDirOption(mode: PathExistMode.mustExist);

    test('when the path does not exist then validation throws', () {
      expect(
        () => option.validateValue(File('missing.png')),
        throwsA(isA<UsageException>()),
      );
    });

    test('when the file exists then validation passes', () async {
      await d.file('a.txt', 'contents').create();

      expect(
        () => option.validateValue(File(p.join(d.sandbox, 'a.txt'))),
        returnsNormally,
      );
    });

    test('when the directory exists then validation passes', () async {
      await d.dir('a-folder').create();

      expect(
        () => option.validateValue(Directory(p.join(d.sandbox, 'a-folder'))),
        returnsNormally,
      );
    });
  });

  group('Given mode mustNotExist', () {
    const option = FileDirOption(mode: PathExistMode.mustNotExist);

    test('when the path does not exist then validation passes', () {
      expect(() => option.validateValue(File('missing.png')), returnsNormally);
    });

    test('when the path exists then validation throws', () async {
      await d.file('a.txt', 'contents').create();

      expect(
        () => option.validateValue(File(p.join(d.sandbox, 'a.txt'))),
        throwsA(isA<UsageException>()),
      );
    });
  });
}

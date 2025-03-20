import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/util/scloud_config/file_finder.dart';

void main() {
  group('Given an scloudFileFinder,', () {
    finder(final String startingDir) => scloudFileFinder(
          fileBaseName: 'scloud',
          supportedExtensions: ['yaml', 'yml'],
          startingDirectory: (final String dir) => dir,
        )(startingDir);

    test('when starting directory is empty then null is returned', () {
      expect(finder(d.sandbox), isNull);
    });

    test('when starting directory is the root directory then null is returned',
        () {
      final root = p.rootPrefix(p.absolute(d.sandbox));
      expect(finder(root), isNull);
    });

    group(
        'and an scloud.yaml file in the starting directory '
        'when calling finder', () {
      setUp(() async {
        await d.file('scloud.yaml').create();
      });

      test('then the file path is returned', () {
        final result = finder(d.sandbox);
        expect(result, isNotNull);
        expect(result, equals(p.join(d.sandbox, 'scloud.yaml')));
      });

      test('then the returned file path is absolute', () {
        final result = finder(d.sandbox);
        expect(result, isNotNull);
        expect(p.isAbsolute(result!), isTrue);
      });
    });

    group(
        'and an scloud.yaml and a scloud.yml file in the starting directory '
        'when calling finder', () {
      setUp(() async {
        await d.file('scloud.yaml').create();
        await d.file('scloud.yml').create();
      });

      test('then an AmbiguousSearchException is thrown', () {
        expect(
          () => finder(d.sandbox),
          throwsA(isA<AmbiguousSearchException>().having(
            (final e) => e.message,
            'message',
            contains('Ambiguous search, multiple candidates found'),
          )),
        );
      });
    });

    group(
        'and 2 scloud.yaml files in separate dirs two levels deep '
        'when calling finder', () {
      setUp(() async {
        await d.dir('parent_dir', [
          d.dir('subdir1', [d.file('scloud.yaml')]),
          d.dir('subdir2', [d.file('scloud.yaml')]),
        ]).create();
      });

      test('then an AmbiguousSearchException is thrown', () {
        expect(
          () => finder(d.sandbox),
          throwsA(isA<AmbiguousSearchException>().having(
            (final e) => e.message,
            'message',
            contains('Ambiguous search, multiple candidates found'),
          )),
        );
      });
    });

    group(
        'and an scloud.yaml file in starting dir and one in dir two levels deep '
        'when calling finder', () {
      setUp(() async {
        await d.dir('.', [
          d.file('scloud.yaml'),
          d.dir('parent_dir', [
            d.dir('subdir1', [
              d.file('scloud.yaml'),
            ]),
          ]),
        ]).create();
      });

      test('then an AmbiguousSearchException is thrown', () {
        expect(
          () => finder(d.sandbox),
          throwsA(isA<AmbiguousSearchException>().having(
            (final e) => e.message,
            'message',
            contains('Ambiguous search, multiple candidates found'),
          )),
        );
      });
    });

    group(
        'and an scloud.yaml in parent dir and a scloud.yml in dir two levels deep '
        'when calling finder', () {
      setUp(() async {
        await d.dir('parent_dir', [
          d.file('scloud.yaml'),
          d.dir('starting_dir', [
            d.dir('subdir', [
              d.dir('subsubdir', [
                d.file('scloud.yml'),
              ]),
            ]),
          ]),
        ]).create();
      });

      test('then scloud.yml in sub-sub-dir is returned', () {
        final result = finder(p.join(d.sandbox, 'parent_dir', 'starting_dir'));
        expect(result, isNotNull);
        expect(
            result,
            equals(p.join(
              d.sandbox,
              'parent_dir',
              'starting_dir',
              'subdir',
              'subsubdir',
              'scloud.yml',
            )));
      });
    });

    group(
        'no pubspec file present in starting dir, and an scloud.yaml in parent dir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('parent_dir', [
          d.file('scloud.yaml'),
          d.dir('starting_dir', [
            d.dir('subdir'),
          ]),
        ]).create();
      });

      test('then no file is found', () {
        final result = finder(p.join(d.sandbox, 'parent_dir', 'starting_dir'));
        expect(result, isNull);
      });
    });

    group(
        'a pubspec file present in parent dir, and an scloud.yaml in parent dir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('parent_dir', [
          d.file('scloud.yaml'),
          d.file('pubspec.yaml'),
          d.dir('starting_dir', [
            d.dir('subdir'),
          ]),
        ]).create();
      });

      test('then no file is found', () {
        final result = finder(p.join(d.sandbox, 'parent_dir', 'starting_dir'));
        expect(result, isNull);
      });
    });

    group(
        'a pubspec file present in starting dir, and an scloud.yaml in parent dir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('parent_dir', [
          d.file('scloud.yaml'),
          d.dir('starting_dir', [
            d.file('pubspec.yaml'),
            d.dir('subdir'),
          ]),
        ]).create();
      });

      test('then scloud.yaml in parent dir is returned', () {
        final result = finder(p.join(d.sandbox, 'parent_dir', 'starting_dir'));
        expect(result, isNotNull);
        expect(result, equals(p.join(d.sandbox, 'parent_dir', 'scloud.yaml')));
      });
    });

    group(
        'and 2 scloud.yaml files in separate dirs three levels deep '
        'when calling finder', () {
      setUp(() async {
        await d.dir('grandparent_dir', [
          d.dir('parent_dir', [
            d.dir('subdir1', [d.file('scloud.yaml')]),
            d.dir('subdir2', [d.file('scloud.yaml')]),
          ])
        ]).create();
      });

      test('then no file is found', () {
        final result = finder(d.sandbox);
        expect(result, isNull);
      });
    });

    group(
        'and an scloud.yaml file in inacessible subdir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('starting_dir', [
          d.dir('parent_dir', [
            d.dir('no_access_dir', [
              d.file('scloud.yaml'),
            ]),
          ]),
        ]).create();

        // Make the no_access_dir non-readable
        final noAccessDir =
            p.join(d.sandbox, 'starting_dir', 'parent_dir', 'no_access_dir');
        Process.runSync(
          'chmod',
          ['222', noAccessDir],
        );
        addTearDown(() {
          // necessary to allow clean up
          Process.runSync(
            'chmod',
            ['777', noAccessDir],
          );
        });
      });

      test('then no file is found', () {
        final result = finder(p.join(d.sandbox, 'starting_dir'));
        expect(result, isNull);
      });
    });

    group(
        'and an scloud.yaml file that is non-readable '
        'when calling finder', () {
      late final String filePath;

      setUp(() async {
        await d.dir('starting_dir', [
          d.dir('accessible_dir', [
            d.file('scloud.yaml'),
          ]),
        ]).create();

        // Make scloud.yaml non-readable
        filePath =
            p.join(d.sandbox, 'starting_dir', 'accessible_dir', 'scloud.yaml');
        Process.runSync(
          'chmod',
          ['222', filePath],
        );
        addTearDown(() {
          // necessary to allow clean up
          Process.runSync(
            'chmod',
            ['777', filePath],
          );
        });
      });

      test('then the scloud.yaml file is returned', () {
        final result = finder(p.join(d.sandbox, 'starting_dir'));
        expect(result, isNotNull);
        expect(result, equals(filePath));
      });
    });

    group(
        'and an scloud.yaml file in inacessible subdir '
        'and an scloud.yml file in acessible subdir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('starting_dir', [
          d.dir('parent_dir', [
            d.dir('no_access_dir', [
              d.file('scloud.yaml'),
            ]),
            d.dir('accessible_dir', [
              d.file('scloud.yml'),
            ]),
          ]),
        ]).create();

        // Make the no_access_dir non-readable
        final noAccessDir =
            p.join(d.sandbox, 'starting_dir', 'parent_dir', 'no_access_dir');
        Process.runSync(
          'chmod',
          ['222', noAccessDir],
        );
        addTearDown(() {
          // necessary to allow clean up
          Process.runSync(
            'chmod',
            ['777', noAccessDir],
          );
        });
      });

      test('then scloud.yml in accessible dir is returned', () {
        final result = finder(p.join(d.sandbox, 'starting_dir'));
        expect(result, isNotNull);
        expect(
            result,
            equals(
              p.join(
                d.sandbox,
                'starting_dir',
                'parent_dir',
                'accessible_dir',
                'scloud.yml',
              ),
            ));
      });
    });
  });
}

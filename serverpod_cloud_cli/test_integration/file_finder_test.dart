import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/util/scloud_config/file_finder.dart';

void main() {
  group('Given an scloudFileFinder,', () {
    finder(
      final String startingDir, {
      final int searchLevelsUp = 2,
      final int searchLevelsDown = 2,
      final FileContentCondition? fileContentCondition,
    }) => scloudFileFinder(
      fileBaseName: 'scloud',
      supportedExtensions: ['yaml', 'yml'],
      startingDirectory: (final String dir) => dir,
      searchLevelsUp: searchLevelsUp,
      searchLevelsDown: searchLevelsDown,
      fileContentCondition: fileContentCondition,
    )(startingDir);

    group('and a tree without any candidate bounded by a git root '
        'when calling finder', () {
      setUp(() async {
        await d.dir('.', [d.dir('.git'), d.dir('starting_dir')]).create();
      });

      test('then null is returned', () {
        expect(finder(p.join(d.sandbox, 'starting_dir')), isNull);
      });
    });

    test(
      'and no file candidate when starting directory is the root directory then null is returned',
      () {
        final root = p.rootPrefix(p.absolute(d.sandbox));
        expect(finder(root), isNull);
      },
    );

    group('and an scloud.yaml file in the starting directory '
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

    group('and an scloud.yaml and a scloud.yml file in the starting directory '
        'when calling finder', () {
      setUp(() async {
        await d.file('scloud.yaml').create();
        await d.file('scloud.yml').create();
      });

      test('then an AmbiguousSearchException is thrown', () {
        expect(
          () => finder(d.sandbox),
          throwsA(
            isA<AmbiguousSearchException>().having(
              (final e) => e.message,
              'message',
              contains('Ambiguous search, multiple candidates found'),
            ),
          ),
        );
      });
    });

    group('and an scloud.yaml in the starting directory '
        'and an scloud.yaml two levels down '
        'when calling finder', () {
      setUp(() async {
        await d.dir('.', [
          d.file('scloud.yaml'),
          d.dir('parent_dir', [
            d.dir('subdir1', [d.file('scloud.yaml')]),
          ]),
        ]).create();
      });

      test('then the starting directory file is returned', () {
        final result = finder(d.sandbox);
        expect(result, equals(p.join(d.sandbox, 'scloud.yaml')));
      });
    });

    group(
      'and an scloud.yaml in the starting directory and and an scloud.yaml in parent dir '
      'when calling finder',
      () {
        setUp(() async {
          await d.dir('parent_dir', [
            d.file('scloud.yaml'),
            d.dir('starting_dir', [d.file('scloud.yaml')]),
          ]).create();
        });

        test('then the starting directory file is returned', () {
          final result = finder(
            p.join(d.sandbox, 'parent_dir', 'starting_dir'),
          );
          expect(
            result,
            equals(
              p.join(d.sandbox, 'parent_dir', 'starting_dir', 'scloud.yaml'),
            ),
          );
        });
      },
    );

    group('and 2 scloud.yaml files in separate dirs two levels deep '
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
          throwsA(
            isA<AmbiguousSearchException>().having(
              (final e) => e.message,
              'message',
              contains('Ambiguous search, multiple candidates found'),
            ),
          ),
        );
      });
    });

    group(
      'and an scloud.yaml in parent dir and a scloud.yml in dir two levels deep '
      'when calling finder',
      () {
        setUp(() async {
          await d.dir('parent_dir', [
            d.file('scloud.yaml'),
            d.dir('starting_dir', [
              d.dir('subdir', [
                d.dir('subsubdir', [d.file('scloud.yml')]),
              ]),
            ]),
          ]).create();
        });

        test('then scloud.yml in sub-sub-dir is returned', () {
          final result = finder(
            p.join(d.sandbox, 'parent_dir', 'starting_dir'),
          );
          expect(result, isNotNull);
          expect(
            result,
            equals(
              p.join(
                d.sandbox,
                'parent_dir',
                'starting_dir',
                'subdir',
                'subsubdir',
                'scloud.yml',
              ),
            ),
          );
        });
      },
    );

    group('no candidate in starting dir, and an scloud.yaml in parent dir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('parent_dir', [
          d.file('scloud.yaml'),
          d.dir('starting_dir', [d.dir('subdir')]),
        ]).create();
      });

      test('then scloud.yaml in parent dir is returned', () {
        final result = finder(p.join(d.sandbox, 'parent_dir', 'starting_dir'));
        expect(result, equals(p.join(d.sandbox, 'parent_dir', 'scloud.yaml')));
      });
    });

    group(
      'a pubspec file present in starting dir, and an scloud.yaml in parent dir '
      'when calling finder',
      () {
        setUp(() async {
          await d.dir('parent_dir', [
            d.file('scloud.yaml'),
            d.dir('starting_dir', [d.file('pubspec.yaml'), d.dir('subdir')]),
          ]).create();
        });

        test('then scloud.yaml in parent dir is returned', () {
          final result = finder(
            p.join(d.sandbox, 'parent_dir', 'starting_dir'),
          );
          expect(result, isNotNull);
          expect(
            result,
            equals(p.join(d.sandbox, 'parent_dir', 'scloud.yaml')),
          );
        });
      },
    );

    group('and 2 scloud.yaml files in separate dirs three levels deep, '
        'bounded by a git root, '
        'when calling finder', () {
      setUp(() async {
        await d.dir('.', [
          d.dir('.git'),
          d.dir('starting_dir', [
            d.dir('grandparent_dir', [
              d.dir('parent_dir', [
                d.dir('subdir1', [d.file('scloud.yaml')]),
                d.dir('subdir2', [d.file('scloud.yaml')]),
              ]),
            ]),
          ]),
        ]).create();
      });

      test('then no file is found', () {
        final result = finder(p.join(d.sandbox, 'starting_dir'));
        expect(result, isNull);
      });
    });

    group('and a Dart workspace root above the starting directory', () {
      group('with a single workspace package containing scloud.yaml '
          'when calling finder', () {
        setUp(() async {
          await d.dir('.', [
            d.file('pubspec.yaml', _workspacePubspec(['server', 'client'])),
            d.dir('server', [d.file('scloud.yaml')]),
            d.dir('client', []),
          ]).create();
        });

        test('then the workspace package scloud.yaml is returned', () {
          final result = finder(p.join(d.sandbox, 'client'));
          expect(result, equals(p.join(d.sandbox, 'server', 'scloud.yaml')));
        });
      });

      group('with two workspace packages containing scloud.yaml '
          'when calling finder', () {
        setUp(() async {
          await d.dir('.', [
            d.file('pubspec.yaml', _workspacePubspec(['server1', 'server2'])),
            d.dir('server1', [d.file('scloud.yaml')]),
            d.dir('server2', [d.file('scloud.yaml')]),
            d.dir('other', []),
          ]).create();
        });

        test('then an AmbiguousSearchException is thrown', () {
          expect(
            () => finder(p.join(d.sandbox, 'other')),
            throwsA(isA<AmbiguousSearchException>()),
          );
        });
      });

      group('with no workspace package containing scloud.yaml '
          'when calling finder', () {
        setUp(() async {
          await d.dir('.', [
            d.file('pubspec.yaml', _workspacePubspec(['server'])),
            d.dir('server', []),
            d.dir('other', []),
          ]).create();
        });

        test('then no file is found', () {
          final result = finder(p.join(d.sandbox, 'other'));
          expect(result, isNull);
        });
      });
    });

    group('and a git repository root above the starting directory', () {
      group('with a single scloud.yaml within two levels '
          'when calling finder', () {
        setUp(() async {
          await d.dir('.', [
            d.dir('.git'),
            d.dir('server', [d.file('scloud.yaml')]),
            d.dir('other', []),
          ]).create();
        });

        test('then the scloud.yaml is returned', () {
          final result = finder(p.join(d.sandbox, 'other'));
          expect(result, equals(p.join(d.sandbox, 'server', 'scloud.yaml')));
        });
      });

      group('with two scloud.yaml files within two levels '
          'when calling finder', () {
        setUp(() async {
          await d.dir('.', [
            d.dir('.git'),
            d.dir('server1', [d.file('scloud.yaml')]),
            d.dir('server2', [d.file('scloud.yaml')]),
            d.dir('other', []),
          ]).create();
        });

        test('then an AmbiguousSearchException is thrown', () {
          expect(
            () => finder(p.join(d.sandbox, 'other')),
            throwsA(isA<AmbiguousSearchException>()),
          );
        });
      });

      group('with no scloud.yaml within two levels '
          'when calling finder', () {
        setUp(() async {
          await d.dir('.', [d.dir('.git'), d.dir('other', [])]).create();
        });

        test('then no file is found', () {
          final result = finder(p.join(d.sandbox, 'other'));
          expect(result, isNull);
        });
      });
    });

    group('and a file content condition '
        'with an scloud.yaml failing the condition in the starting dir '
        'and an scloud.yaml passing the condition one level down '
        'when calling finder', () {
      setUp(() async {
        await d.dir('.', [
          d.file('scloud.yaml', 'skip'),
          d.dir('subdir', [d.file('scloud.yaml', 'keep')]),
        ]).create();
      });

      test('then the file passing the condition is returned', () {
        final result = finder(
          d.sandbox,
          fileContentCondition: (final filePath) =>
              File(filePath).readAsStringSync() == 'keep',
        );
        expect(result, equals(p.join(d.sandbox, 'subdir', 'scloud.yaml')));
      });
    });

    group('and a searchLevelsUp limit', () {
      group('with a candidate within the up limit when calling finder', () {
        setUp(() async {
          await d.dir('parent_dir', [
            d.file('scloud.yaml'),
            d.dir('starting_dir', []),
          ]).create();
        });

        test('then the candidate in the parent dir is returned', () {
          final result = finder(
            p.join(d.sandbox, 'parent_dir', 'starting_dir'),
            searchLevelsUp: 1,
          );
          expect(
            result,
            equals(p.join(d.sandbox, 'parent_dir', 'scloud.yaml')),
          );
        });
      });

      group('with a candidate beyond the up limit when calling finder', () {
        setUp(() async {
          await d.dir('grandparent_dir', [
            d.file('scloud.yaml'),
            d.dir('parent_dir', [d.dir('starting_dir', [])]),
          ]).create();
        });

        test('then no file is found', () {
          final result = finder(
            p.join(d.sandbox, 'grandparent_dir', 'parent_dir', 'starting_dir'),
            searchLevelsUp: 1,
          );
          expect(result, isNull);
        });
      });
    });

    group(
      'and a final subdirectory search at the top level dir to examine',
      () {
        group(
          'with a single candidate in a sibling subtree of the top level dir '
          'when calling finder',
          () {
            setUp(() async {
              await d.dir('top_dir', [
                d.dir('sibling_dir', [d.file('scloud.yaml')]),
                d.dir('parent_dir', [d.dir('starting_dir', [])]),
              ]).create();
            });

            test(
              'then the candidate found by the final search is returned',
              () {
                final result = finder(
                  p.join(d.sandbox, 'top_dir', 'parent_dir', 'starting_dir'),
                  searchLevelsUp: 2,
                );
                expect(
                  result,
                  equals(
                    p.join(d.sandbox, 'top_dir', 'sibling_dir', 'scloud.yaml'),
                  ),
                );
              },
            );
          },
        );

        group('with two candidates in sibling subtrees of the top level dir '
            'when calling finder', () {
          setUp(() async {
            await d.dir('top_dir', [
              d.dir('sibling_dir1', [d.file('scloud.yaml')]),
              d.dir('sibling_dir2', [d.file('scloud.yaml')]),
              d.dir('parent_dir', [d.dir('starting_dir', [])]),
            ]).create();
          });

          test('then an AmbiguousSearchException is thrown', () {
            expect(
              () => finder(
                p.join(d.sandbox, 'top_dir', 'parent_dir', 'starting_dir'),
                searchLevelsUp: 2,
              ),
              throwsA(isA<AmbiguousSearchException>()),
            );
          });
        });
      },
    );

    group('and an scloud.yaml file in inacessible subdir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('.', [
          d.dir('.git'),
          d.dir('starting_dir', [
            d.dir('parent_dir', [
              d.dir('no_access_dir', [d.file('scloud.yaml')]),
            ]),
          ]),
        ]).create();

        // Make the no_access_dir non-readable
        final noAccessDir = p.join(
          d.sandbox,
          'starting_dir',
          'parent_dir',
          'no_access_dir',
        );
        Process.runSync('chmod', ['222', noAccessDir]);
        addTearDown(() {
          // necessary to allow clean up
          Process.runSync('chmod', ['777', noAccessDir]);
        });
      });

      test('then no file is found', () {
        final result = finder(p.join(d.sandbox, 'starting_dir'));
        expect(result, isNull);
      });
    }, onPlatform: {'windows': Skip('chmod not supported on Windows')});

    group('and an scloud.yaml file that is non-readable '
        'when calling finder', () {
      late final String filePath;

      setUp(() async {
        await d.dir('starting_dir', [
          d.dir('accessible_dir', [d.file('scloud.yaml')]),
        ]).create();

        // Make scloud.yaml non-readable
        filePath = p.join(
          d.sandbox,
          'starting_dir',
          'accessible_dir',
          'scloud.yaml',
        );
        Process.runSync('chmod', ['222', filePath]);
        addTearDown(() {
          // necessary to allow clean up
          Process.runSync('chmod', ['777', filePath]);
        });
      });

      test('then the scloud.yaml file is returned', () {
        final result = finder(p.join(d.sandbox, 'starting_dir'));
        expect(result, isNotNull);
        expect(result, equals(filePath));
      });
    }, onPlatform: {'windows': Skip('chmod not supported on Windows')});

    group('and an scloud.yaml file in inacessible subdir '
        'and an scloud.yml file in acessible subdir '
        'when calling finder', () {
      setUp(() async {
        await d.dir('starting_dir', [
          d.dir('parent_dir', [
            d.dir('no_access_dir', [d.file('scloud.yaml')]),
            d.dir('accessible_dir', [d.file('scloud.yml')]),
          ]),
        ]).create();

        // Make the no_access_dir non-readable
        final noAccessDir = p.join(
          d.sandbox,
          'starting_dir',
          'parent_dir',
          'no_access_dir',
        );
        Process.runSync('chmod', ['222', noAccessDir]);
        addTearDown(() {
          // necessary to allow clean up
          Process.runSync('chmod', ['777', noAccessDir]);
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
          ),
        );
      });
    }, onPlatform: {'windows': Skip('chmod not supported on Windows')});
  });
}

String _workspacePubspec(final List<String> packages) {
  final packageList = packages.map((final pkg) => '  - $pkg').join('\n');
  return '''
name: my_workspace
environment:
  sdk: ^3.6.0
workspace:
$packageList
''';
}

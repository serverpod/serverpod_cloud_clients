import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/printers/file_tree_printer.dart';
import 'package:test/test.dart';

class BufferLogger {
  final List<String> lines = [];

  void raw(final String content, {final AnsiStyle? style}) {
    lines.add(content);
  }

  String get output => lines.join('');
}

void main() {
  test(
      'Given empty inputs '
      'when printing the file tree '
      'then an empty string is printed', () {
    final result = BufferLogger();

    FileTreePrinter.writeFileTree(
      filePaths: {},
      ignoredPaths: {},
      write: result.raw,
    );

    expect(result.output, '');
  });

  group('Only included files - ', () {
    test(
        'Given a single file in the root '
        'when printing the file tree '
        'then that single file is printed', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'pubspec.yaml',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
╰─ pubspec.yaml
''');
    });

    test(
        'Given a two files in the root '
        'when printing the file tree '
        'then both files are printed', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'README.md',
          'pubspec.yaml',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
├─ README.md
╰─ pubspec.yaml
''');
    });

    test(
        'Given a two files in unsorted order in the root '
        'when printing the file tree '
        'then both files are printed in sorted order', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'b.md',
          'a.md',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
├─ a.md
╰─ b.md
''');
    });

    test(
        'Given a file nested in a directory '
        'when printing the file tree '
        'then the path to the file is printed', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'folder/README.md',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
╰─ folder
   ╰─ README.md
''');
    });

    test(
        'Given multiple files nested in a directory '
        'when printing the file tree '
        'then the path to the files is printed', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'folder/pubspec.yaml',
          'folder/a.md',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
╰─ folder
   ├─ a.md
   ╰─ pubspec.yaml
''');
    });

    test(
        'Given a file and multiple files nested in a directory in the root '
        'when printing the file tree '
        'then the printed tree includes all paths', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'README.md',
          'folder/pubspec.yaml',
          'folder/a.md',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
├─ folder
│  ├─ a.md
│  ╰─ pubspec.yaml
╰─ README.md
''');
    });

    test(
        'Given nested directory and file structure '
        'when printing the file tree '
        'then the nested directory is printed before the file', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'root/b/a.dart',
          'root/b/b.dart',
          'root/a.dart',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
╰─ root
   ├─ b
   │  ├─ a.dart
   │  ╰─ b.dart
   ╰─ a.dart
''');
    });

    test(
        'Given a platform specific structure format '
        'when printing the file tree '
        'then the structure is printed correctly', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          p.join('root', 'b', 'b.dart'),
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
╰─ root
   ╰─ b
      ╰─ b.dart
''');
    });

    test(
        'Given a nested directories with different lengths '
        'when printing the file tree '
        'then the structure is printed in sorted order', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'aa.dart',
          'web/long/nested/path/to/file.dart',
          'a/b/c.dart',
          'a/b/a.dart',
        },
        ignoredPaths: {},
        write: result.raw,
      );

      expect(result.output, '''
├─ a
│  ╰─ b
│     ├─ a.dart
│     ╰─ c.dart
├─ web
│  ╰─ long
│     ╰─ nested
│        ╰─ path
│           ╰─ to
│              ╰─ file.dart
╰─ aa.dart
''');
    });
  });

  group('Only ignored files - ', () {
    test(
        'Given a single ignored file in the root '
        'when printing the file tree '
        'then that single file is printed with a (ignored) suffix', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'pubspec.yaml',
        },
        write: result.raw,
      );

      expect(result.output, '''
╰╌ pubspec.yaml                                                        (ignored)
''');
    });

    test(
        'Given a two ignored files in the root '
        'when printing the file tree '
        'then both files are printed with a (ignored) suffix', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'README.md',
          'pubspec.yaml',
        },
        write: result.raw,
      );

      expect(result.output, '''
┆╌ README.md                                                           (ignored)
╰╌ pubspec.yaml                                                        (ignored)
''');
    });

    test(
        'Given a two ignored files in unsorted order in the root '
        'when printing the file tree '
        'then both files are printed in sorted order with a (ignored) suffix',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'b.md',
          'a.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
┆╌ a.md                                                                (ignored)
╰╌ b.md                                                                (ignored)
''');
    });

    test(
        'Given an ignored file nested in a directory '
        'when printing the file tree '
        'then the path to the file is printed with a dashed line and a (ignored) suffix',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'folder/README.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
╰╌ folder                                                              (ignored)
   ╰╌ README.md                                                        (ignored)
''');
    });

    test(
        'Given multiple ignored files nested in a directory '
        'when printing the file tree '
        'then the path to the files is printed with a dashed line and a (ignored) suffix',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'folder/pubspec.yaml',
          'folder/a.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
╰╌ folder                                                              (ignored)
   ┆╌ a.md                                                             (ignored)
   ╰╌ pubspec.yaml                                                     (ignored)
''');
    });

    test(
        'Given an ignored file and multiple ignored files nested in a directory in the root '
        'when printing the file tree '
        'then the printed tree includes all paths with a dashed line and a (ignored) suffix',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'README.md',
          'folder/pubspec.yaml',
          'folder/a.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
┆╌ folder                                                              (ignored)
┆  ┆╌ a.md                                                             (ignored)
┆  ╰╌ pubspec.yaml                                                     (ignored)
╰╌ README.md                                                           (ignored)
''');
    });

    test(
        'Given a very long file path '
        'when printing the file tree '
        'then the file path pushes the suffix out of the max but with a space',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          'very/long/path/to/a_very_long_file_name_that_takes_up_more_than_80_columns_pubspec.yaml',
        },
        write: result.raw,
      );

      expect(result.output, '''
╰╌ very                                                                (ignored)
   ╰╌ long                                                             (ignored)
      ╰╌ path                                                          (ignored)
         ╰╌ to                                                         (ignored)
            ╰╌ a_very_long_file_name_that_takes_up_more_than_80_columns_pubspec.yaml (ignored)
''');
    });

    test(
        'Given a platform specific structure format '
        'when printing the file tree '
        'then the structure is printed correctly', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {},
        ignoredPaths: {
          p.join('root', 'b', 'b.dart'),
        },
        write: result.raw,
      );

      expect(result.output, '''
╰╌ root                                                                (ignored)
   ╰╌ b                                                                (ignored)
      ╰╌ b.dart                                                        (ignored)
''');
    });
  });

  group('Included and ignored files - ', () {
    test(
        'Given a single included file and a single ignored file in the root '
        'when printing the file tree '
        'then the included file is printed and the ignored file is printed with a (ignored) suffix',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'pubspec.yaml',
        },
        ignoredPaths: {
          'README.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
├─ README.md                                                           (ignored)
╰─ pubspec.yaml
''');
    });

    test(
        'Given a single included file and a single ignored file in a directory '
        'when printing the file tree '
        'then the included file is printed and the ignored file is printed with a (ignored) suffix',
        () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'folder/pubspec.yaml',
        },
        ignoredPaths: {
          'folder/README.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
╰─ folder
   ├─ README.md                                                        (ignored)
   ╰─ pubspec.yaml
''');
    });

    test(
        'Given multiple files in nested structures '
        'when printing the file tree '
        'then the files are printed with the correct line dashes', () {
      final result = BufferLogger();

      FileTreePrinter.writeFileTree(
        filePaths: {
          'folder/nested/structure/pubspec.yaml',
          'folder/nested/structure/image.png',
          'root.file',
        },
        ignoredPaths: {
          'folder/nested/ignored/README.md',
          'folder/nested/ignored/LICENSE.md',
          'folder/nested/ignored/deep/file.md',
          'folder/nested/ignored/deep/file2.md',
          'folder/nested/ignored/deep/file3.md',
          'root.md',
        },
        write: result.raw,
      );

      expect(result.output, '''
├─ folder
│  ╰─ nested
│     ├─ ignored                                                       (ignored)
│     │  ┆╌ deep                                                       (ignored)
│     │  ┆  ┆╌ file.md                                                 (ignored)
│     │  ┆  ┆╌ file2.md                                                (ignored)
│     │  ┆  ╰╌ file3.md                                                (ignored)
│     │  ┆╌ LICENSE.md                                                 (ignored)
│     │  ╰╌ README.md                                                  (ignored)
│     ╰─ structure
│        ├─ image.png
│        ╰─ pubspec.yaml
├─ root.file
╰─ root.md                                                             (ignored)
''');
    });
  });
}

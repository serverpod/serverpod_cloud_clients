import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:test/test.dart';

void main() {
  group('Given a windows-style relative path', () {
    test(
      'when converting to an archive entry name then the separators are posix',
      () {
        final entryName = ProjectZipper.toArchiveEntryName(
          r'pkg\pubspec.yaml',
          pathContext: p.Context(style: p.Style.windows),
        );

        expect(entryName, 'pkg/pubspec.yaml');
      },
    );
  });

  group('Given a posix-style relative path', () {
    test(
      'when converting to an archive entry name then the path is unchanged',
      () {
        final entryName = ProjectZipper.toArchiveEntryName(
          'pkg/pubspec.yaml',
          pathContext: p.Context(style: p.Style.posix),
        );

        expect(entryName, 'pkg/pubspec.yaml');
      },
    );
  });
}

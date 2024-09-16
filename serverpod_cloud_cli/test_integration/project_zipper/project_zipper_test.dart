import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../test_utils/project_factory.dart';

void main() {
  final logger = StdOutLogger(LogLevel.debug);
  final testProjectPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  tearDown(() {
    final directory = Directory(testProjectPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  test(
      'Given non existing project directory when zipping project then project directory does not exist exception is thrown.',
      () async {
    final projectDirectory = Directory(testProjectPath);
    expect(Directory(testProjectPath).existsSync(), isFalse);

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: logger,
      ),
      throwsA(isA<ProjectDirectoryDoesNotExistException>()),
    );
  });

  test(
      'Given an empty project directory when zipping project then empty project exception is thrown.',
      () async {
    final projectDirectory = DirectoryFactory().construct(testProjectPath);
    expect(projectDirectory.listSync(), isEmpty);

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: logger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });

  test(
      'Given a project containing a symlink to a directory when zipping then directory symlink exception is thrown.',
      () async {
    const symlinkedDirectoryName = 'symlinked_directory';
    final projectDirectory = DirectoryFactory(
      withSubDirectories: [
        DirectoryFactory(
          withDirectoryName: symlinkedDirectoryName,
          withFiles: [
            FileFactory(withName: 'file1.txt', withContents: 'file1'),
          ],
        ),
      ],
      withSymLinks: [
        SymLinkFactory(
          withName: 'symlinked_directory_link',
          withTarget: symlinkedDirectoryName,
        ),
      ],
    ).construct(testProjectPath);

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: logger,
      ),
      throwsA(isA<DirectorySymLinkException>()),
    );
  });

  test(
      'Given project containing non-resolving symlink file when zipping project then non resolving symlink exception is thrown',
      () async {
    final projectDirectory = DirectoryFactory(
      withSymLinks: [
        SymLinkFactory(
          withName: 'non-resolving-symlink',
          withTarget: 'non-existing-file',
        ),
      ],
    ).construct(testProjectPath);

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: logger,
      ),
      throwsA(isA<NonResolvingSymlinkException>()),
    );
  });

  test(
      'Given a project directory with files when zipping then files are included in the root of the zip file.',
      () async {
    final projectDirectory = DirectoryFactory(
      withFiles: [
        FileFactory(withName: 'file1.txt', withContents: 'file1'),
        FileFactory(withName: 'file2.txt', withContents: 'file2'),
        FileFactory(withName: 'file3.txt', withContents: 'file3'),
      ],
    ).construct(testProjectPath);

    final zippedProject = await ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: logger,
    );

    final archive = ZipDecoder().decodeBytes(zippedProject);
    expect(archive.length, 3);
    final archiveNames = archive.map((final file) => file.name).toList();

    expect(archiveNames, contains('file1.txt'));
    expect(archiveNames, contains('file2.txt'));
    expect(archiveNames, contains('file3.txt'));
  });
}

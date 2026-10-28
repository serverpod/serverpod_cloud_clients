import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:uuid/uuid.dart';

import '../../test_utils/project_factory.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final commandLogger = TestCommandLogger();

  final testProjectPath = p.join('test_integration', const Uuid().v4());

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
          rootDirectory: projectDirectory,
          logger: commandLogger,
        ),
        throwsA(isA<ProjectDirectoryDoesNotExistException>()),
      );
    },
  );

  test(
    'Given an empty project directory when zipping project then empty project exception is thrown.',
    () async {
      final projectDirectory = DirectoryFactory().construct(testProjectPath);
      expect(projectDirectory.listSync(), isEmpty);

      await expectLater(
        ProjectZipper.zipProject(
          rootDirectory: projectDirectory,
          logger: commandLogger,
        ),
        throwsA(isA<EmptyProjectException>()),
      );
    },
  );

  test(
    'Given a project containing a symlink to a directory when zipping then a directory symlink exception is thrown.',
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
          rootDirectory: projectDirectory,
          logger: commandLogger,
        ),
        throwsA(isA<DirectorySymLinkException>()),
      );
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

  test(
    'Given a project containing non-resolving symlink file when zipping the project then a non resolving symlink exception is thrown.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [FileFactory(withName: 'file1.txt', withContents: 'file1')],
        withSymLinks: [
          SymLinkFactory(
            withName: 'non-resolving-symlink',
            withTarget: 'non-existing-file',
          ),
        ],
      ).construct(testProjectPath);

      await expectLater(
        ProjectZipper.zipProject(
          rootDirectory: projectDirectory,
          logger: commandLogger,
        ),
        throwsA(isA<NonResolvingSymlinkException>()),
      );
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

  test(
    'Given a directory symlink inside a directory ignored by a subdirectory .gitignore when zipping then the project is zipped without the ignored directory.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [FileFactory(withName: 'keep.txt', withContents: 'keep')],
        withSubDirectories: [
          DirectoryFactory(
            withDirectoryName: 'macos',
            withFiles: [
              FileFactory(
                withName: '.gitignore',
                withContents: '**/Flutter/ephemeral/',
              ),
              FileFactory(withName: 'AppDelegate.swift', withContents: 'app'),
            ],
            withSubDirectories: [
              DirectoryFactory(
                withDirectoryName: 'Flutter',
                withSubDirectories: [
                  DirectoryFactory(
                    withDirectoryName: 'ephemeral',
                    withSymLinks: [
                      SymLinkFactory(withName: 'Packages', withTarget: '..'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archiveNames = ZipDecoder()
          .decodeBytes(zippedProject)
          .map((file) => file.name)
          .toList();
      expect(
        archiveNames,
        unorderedEquals(['keep.txt', 'macos/AppDelegate.swift']),
      );
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

  test(
    'Given an ignored symlink to a directory when zipping then the project is zipped without the symlink.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [
          FileFactory(withName: '.gitignore', withContents: 'linked_directory'),
        ],
        withSubDirectories: [
          DirectoryFactory(
            withDirectoryName: 'real_directory',
            withFiles: [
              FileFactory(withName: 'file1.txt', withContents: 'file1'),
            ],
          ),
        ],
        withSymLinks: [
          SymLinkFactory(
            withName: 'linked_directory',
            withTarget: 'real_directory',
          ),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archiveNames = ZipDecoder()
          .decodeBytes(zippedProject)
          .map((file) => file.name)
          .toList();
      expect(archiveNames, ['real_directory/file1.txt']);
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

  test(
    'Given a non-resolving symlink inside an ignored directory when zipping then the project is zipped without it.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [
          FileFactory(withName: '.gitignore', withContents: 'build/'),
          FileFactory(withName: 'file1.txt', withContents: 'file1'),
        ],
        withSubDirectories: [
          DirectoryFactory(
            withDirectoryName: 'build',
            withSymLinks: [
              SymLinkFactory(
                withName: 'non-resolving-symlink',
                withTarget: 'non-existing-file',
              ),
            ],
          ),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archiveNames = ZipDecoder()
          .decodeBytes(zippedProject)
          .map((file) => file.name)
          .toList();
      expect(archiveNames, ['file1.txt']);
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

  test(
    'Given a symlink to a file when zipping then the file content is included under the symlink name.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [FileFactory(withName: 'file1.txt', withContents: 'file1')],
        withSymLinks: [
          SymLinkFactory(withName: 'link1.txt', withTarget: 'file1.txt'),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final linkEntry = ZipDecoder()
          .decodeBytes(zippedProject)
          .findFile('link1.txt');
      expect(linkEntry, isNotNull);
      expect(String.fromCharCodes(linkEntry!.content), 'file1');
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

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
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archive = ZipDecoder().decodeBytes(zippedProject);
      expect(archive.length, 3);
      final archiveNames = archive.map((file) => file.name).toList();

      expect(archiveNames, contains('file1.txt'));
      expect(archiveNames, contains('file2.txt'));
      expect(archiveNames, contains('file3.txt'));
    },
  );

  test(
    'Given a project directory with a hidden file when zipping then the hidden file is not included in the final output.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [
          FileFactory(withName: '.env', withContents: 'my_key=value'),
          FileFactory(withName: 'my_file.txt', withContents: 'my_key=value'),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archive = ZipDecoder().decodeBytes(zippedProject);
      final archiveNames = archive.map((file) => file.name).toList();

      expect(archiveNames, ['my_file.txt']);
    },
  );

  test(
    'Given a project directory with a hidden folder when zipping then the hidden folder content is not included in the final output.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [
          FileFactory(withName: 'my_file.txt', withContents: 'my_key=value'),
        ],
        withSubDirectories: [
          DirectoryFactory(
            withDirectoryName: '.hidden',
            withFiles: [
              FileFactory(withName: 'file1.txt', withContents: 'file1'),
            ],
          ),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archive = ZipDecoder().decodeBytes(zippedProject);
      final archiveNames = archive.map((file) => file.name).toList();

      expect(archiveNames, ['my_file.txt']);
    },
  );

  test(
    'Given a project directory beneath a parent path containing spaces when zipping then files are included in the zip file.',
    () async {
      await d.dir('Serverpod projects', [
        d.dir('my_project', [d.file('file1.txt', 'file1')]),
      ]).create();
      final projectDirectory = Directory(
        p.join(d.sandbox, 'Serverpod projects', 'my_project'),
      );

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      );

      final archive = ZipDecoder().decodeBytes(zippedProject);
      final archiveNames = archive.map((file) => file.name).toSet();

      expect(archiveNames, {'file1.txt'});
    },
  );

  test(
    'Given an excludeFile predicate that matches a file when zipping then that file is not included in the final output.',
    () async {
      final projectDirectory = DirectoryFactory(
        withFiles: [
          FileFactory(withName: 'pubspec.yaml', withContents: 'name: example'),
          FileFactory(withName: 'pubspec.lock', withContents: 'sdks: {}'),
        ],
        withSubDirectories: [
          DirectoryFactory(
            withDirectoryName: 'pkg',
            withFiles: [
              FileFactory(
                withName: 'pubspec.yaml',
                withContents: 'name: nested',
              ),
              FileFactory(withName: 'pubspec.lock', withContents: 'sdks: {}'),
            ],
          ),
        ],
      ).construct(testProjectPath);

      final zippedProject = await ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
        excludeFile: (relativePath) =>
            p.basename(relativePath) == 'pubspec.lock',
      );

      final archive = ZipDecoder().decodeBytes(zippedProject);
      final archiveNames = archive.map((file) => file.name).toSet();

      expect(archiveNames, {'pubspec.yaml', 'pkg/pubspec.yaml'});
    },
  );
}

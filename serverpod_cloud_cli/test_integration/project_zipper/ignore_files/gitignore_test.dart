import 'package:archive/archive_io.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:test/test.dart';

import '../../../test_utils/project_factory.dart';

void main() {
  final logger = VoidLogger();
  final commandLogger = CommandLogger(logger);
  final testProjectDirFactory = DirectoryFactory(
    withPath: 'test_integration',
  );

  setUp(() {
    testProjectDirFactory.construct();
  });

  tearDown(() {
    testProjectDirFactory.destruct();
  });

  test(
      'Given a project directory only containing file ignored by .gitignore when zipping project then empty project exception is thrown',
      () async {
    const String fileToIgnore = 'ignored_file.txt';
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(withName: '.gitignore', withContents: fileToIgnore),
        FileFactory(withName: fileToIgnore)
      ],
    ).construct();

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });

  test(
      'Given default ignored file included by .gitignore override when zipping project then file is included',
      () async {
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(withName: '.gitignore', withContents: '!.gitignore'),
      ],
    ).construct();

    final zippedProject = ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: commandLogger,
    );

    await expectLater(zippedProject, completion(isNotEmpty));
    final archive = ZipDecoder().decodeBytes(await zippedProject);

    expect(archive.files, hasLength(1));
    expect(archive.files.first.name, contains('.gitignore'));
  });

  test(
      'Given default ignored file in subdirectory included by subdirectory .gitignore override when zipping project then file is included',
      () async {
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withSubdirectories: [
        DirectoryFactory(
          withFiles: [
            FileFactory(withName: '.gitignore', withContents: '!.gitignore'),
          ],
        ),
      ],
    ).construct();

    final zippedProject = ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: commandLogger,
    );

    await expectLater(zippedProject, completion(isNotEmpty));
    final archive = ZipDecoder().decodeBytes(await zippedProject);

    expect(archive.files, hasLength(1));
    expect(archive.files.first.name, contains('.gitignore'));
  });

  test(
      'Given default ignored files in root and subdirectory and subdirectory file is included by subdirectory .gitignore override when zipping project then only the subdirectory file is included',
      () async {
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(withName: '.gitignore'),
      ],
      withSubdirectories: [
        DirectoryFactory(
          withFiles: [
            FileFactory(withName: '.gitignore', withContents: '!.gitignore'),
          ],
        ),
      ],
    ).construct();

    final zippedProject = ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: commandLogger,
    );

    await expectLater(zippedProject, completion(isNotEmpty));
    final archive = ZipDecoder().decodeBytes(await zippedProject);

    expect(archive.files, hasLength(1));
    expect(archive.files.first.name, contains('.gitignore'));
  });

  test(
      'Given only file in subdirectory ignored by .gitignore when zipping project then empty project exception is thrown',
      () async {
    const ignoredDirectoryName = 'ignoredDirectory';
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(
            withName: '.gitignore', withContents: '$ignoredDirectoryName/*'),
      ],
      withSubdirectories: [
        DirectoryFactory(
          withName: ignoredDirectoryName,
          withFiles: [
            FileFactory(withName: 'my_secret.txt'),
          ],
        ),
      ],
    ).construct();

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });
}

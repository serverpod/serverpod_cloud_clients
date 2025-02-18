import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../../test_utils/project_factory.dart';

void main() {
  final logger = VoidLogger();
  final commandLogger = CommandLogger(logger);
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
      'Given a project directory only containing file ignored by .scloudignore when zipping project then empty project exception is thrown',
      () async {
    const String fileToIgnore = 'ignored_file.txt';
    final projectDirectory = DirectoryFactory(
      withFiles: [
        FileFactory(withName: '.scloudignore', withContents: fileToIgnore),
        FileFactory(withName: fileToIgnore)
      ],
    ).construct(testProjectPath);

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });

  test(
      'Given default ignored file included by .scloudignore override when zipping project then file is included',
      () async {
    final projectDirectory = DirectoryFactory(
      withFiles: [
        FileFactory(withName: '.scloudignore', withContents: '!.scloudignore'),
      ],
    ).construct(testProjectPath);

    final zippedProject = ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: commandLogger,
    );

    await expectLater(zippedProject, completion(isNotEmpty));
    final archive = ZipDecoder().decodeBytes(await zippedProject);

    expect(archive.files, hasLength(1));
    expect(archive.files.first.name, contains('.scloudignore'));
  });

  test(
      'Given default ignored file in subdirectory included by subdirectory .scloudignore override when zipping project then file is included',
      () async {
    final projectDirectory = DirectoryFactory(
      withSubDirectories: [
        DirectoryFactory(
          withFiles: [
            FileFactory(
                withName: '.scloudignore', withContents: '!.scloudignore'),
          ],
        ),
      ],
    ).construct(testProjectPath);

    final zippedProject = ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: commandLogger,
    );

    await expectLater(zippedProject, completion(isNotEmpty));
    final archive = ZipDecoder().decodeBytes(await zippedProject);

    expect(archive.files, hasLength(1));
    expect(archive.files.first.name, contains('.scloudignore'));
  });

  test(
      'Given default ignored files in root and subdirectory and subdirectory file is included by subdirectory .scloudignore override when zipping project then only subdirectory file is included',
      () async {
    final projectDirectory = DirectoryFactory(
      withFiles: [
        FileFactory(withName: '.scloudignore'),
      ],
      withSubDirectories: [
        DirectoryFactory(
          withFiles: [
            FileFactory(
                withName: '.scloudignore', withContents: '!.scloudignore'),
          ],
        ),
      ],
    ).construct(testProjectPath);

    final zippedProject = ProjectZipper.zipProject(
      projectDirectory: projectDirectory,
      logger: commandLogger,
    );

    await expectLater(zippedProject, completion(isNotEmpty));
    final archive = ZipDecoder().decodeBytes(await zippedProject);

    expect(archive.files, hasLength(1));
    expect(archive.files.first.name, contains('.scloudignore'));
  });

  test(
      'Given only file in subdirectory ignored by .scloudignore when zipping project then empty project exception is thrown',
      () async {
    const ignoredDirectoryName = 'ignoredDirectory';
    final projectDirectory = DirectoryFactory(
      withFiles: [
        FileFactory(
            withName: '.scloudignore', withContents: '$ignoredDirectoryName/*'),
      ],
      withSubDirectories: [
        DirectoryFactory(
          withDirectoryName: ignoredDirectoryName,
          withFiles: [
            FileFactory(withName: 'my_secret.txt'),
          ],
        ),
      ],
    ).construct(testProjectPath);

    await expectLater(
      ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });
}

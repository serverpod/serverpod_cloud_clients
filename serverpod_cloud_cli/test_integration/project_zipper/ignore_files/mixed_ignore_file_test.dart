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
      'Given a project directory containing a file ignored by .gitignore but included by .scloudignore when zipping project then file is included',
      () async {
    const ignoredFileName = 'ignored_file.txt';
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(withName: ignoredFileName),
        FileFactory(withName: '.gitignore', withContents: ignoredFileName),
        FileFactory(
          withName: '.scloudignore',
          withContents: '!$ignoredFileName',
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
    expect(archive.files.first.name, contains(ignoredFileName));
  });

  test(
      'Given a project directory containing a file ignored by .scloudignore but included by .gitignore when zipping project then empty project exception is thrown',
      () {
    const ignoredFileName = 'ignored_file.txt';
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(withName: ignoredFileName),
        FileFactory(withName: '.scloudignore', withContents: ignoredFileName),
        FileFactory(
          withName: '.gitignore',
          withContents: '!$ignoredFileName',
        ),
      ],
    ).construct();

    expect(
      () => ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });
}

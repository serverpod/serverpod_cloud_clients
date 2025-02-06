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
      'Given a project directory only containing file ignored by default ignore rules when zipping project then empty project exception is thrown',
      () {
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withFiles: [
        FileFactory(withName: '.gitignore'),
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

  test(
      'Given only default ignored file in subdirectory when zipping project then empty project exception is thrown',
      () {
    final projectDirectory = DirectoryFactory(
      withParent: testProjectDirFactory,
      withSubdirectories: [
        DirectoryFactory(
          withFiles: [
            FileFactory(withName: '.gitignore'),
          ],
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

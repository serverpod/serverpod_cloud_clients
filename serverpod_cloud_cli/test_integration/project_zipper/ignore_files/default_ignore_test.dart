import 'dart:io';

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
      'Given a project directory only containing file ignored by default ignore rules when zipping project then empty project exception is thrown',
      () {
    final projectDirectory = DirectoryFactory(
      withFiles: [
        FileFactory(withName: '.gitignore'),
      ],
    ).construct(testProjectPath);

    expect(
      () => ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });

  test(
      'Given only default ignored file in subdirectory when zipping project then empty project exception is thrown',
      () {
    final projectDirectory = DirectoryFactory(
      withSubDirectories: [
        DirectoryFactory(
          withFiles: [
            FileFactory(withName: '.gitignore'),
          ],
        ),
      ],
    ).construct(testProjectPath);

    expect(
      () => ProjectZipper.zipProject(
        rootDirectory: projectDirectory,
        logger: commandLogger,
      ),
      throwsA(isA<EmptyProjectException>()),
    );
  });
}

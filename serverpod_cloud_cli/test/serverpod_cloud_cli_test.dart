import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:test/test.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/test_command_logger.dart';

void main() async {
  final logger = TestCommandLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse('0.0.1'),
  );

  tearDown(() {
    logger.clear();
  });

  group('Given a cli command runner when running the help command', () {
    setUp(() async {
      await cli.run(['help']);
    });

    test('then the help is printed.', () {
      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first.message,
        startsWith('Manage your Serverpod Cloud projects'),
      );
    });

    test('then the version command description included in the help message.',
        () {
      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first.message,
        contains('Prints the version of the Serverpod Cloud CLI.'),
      );
    });
  });

  test(
      'Given a cli command runner when running the version command then the version is printed.',
      () async {
    await cli.run(['version']);
    expect(logger.infoCalls, isNotEmpty);
    expect(
      logger.infoCalls.first,
      equalsInfoCall(
        message: 'Serverpod Cloud CLI version: $version',
      ),
    );
  });
}

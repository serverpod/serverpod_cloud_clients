import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';
import 'package:test/test.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/test_command_logger.dart';

void main() async {
  final logger = TestCommandLogger();

  final cli = CloudCliCommandRunner.create(logger: logger);

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
        message: 'Serverpod Cloud CLI version: $cliVersion',
      ),
    );
  });
  group(
      'Given a cli command runner '
      'when running any command with the auth token option ', () {
    setUp(() async {
      await cli.run(['version', '--token', 'test-token']);
    });

    test('then the auth token is set in the global configuration.', () {
      expect(
        cli.globalConfiguration.authToken,
        'test-token',
      );
    });

    test('then the auth token is set in the authentication key manager.',
        () async {
      await expectLater(
        cli.serviceProvider.cloudApiClient.authKeyProvider?.authHeaderValue,
        completion('Bearer test-token'),
      );
    });
  });
}

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/fake_cli_updater.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  const version = '999.0.0';
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse(version),
    cliUpdater: FakeCliUpdater(),
  );
  late String configDir;

  setUp(() async {
    await d.dir('config_dir').create();
    configDir = p.join(d.sandbox, 'config_dir');
  });

  tearDown(logger.clear);

  group('Given the cli command runner', () {
    group('when running --version', () {
      setUp(() async {
        await cli.run(['--version', '--config-dir', configDir]);
      });

      test('then the version is printed', () {
        expect(logger.infoCalls, [
          equalsInfoCall(message: 'Serverpod Cloud CLI version: $version'),
        ]);
      });
    });

    group('when running --version before a subcommand', () {
      setUp(() async {
        await cli.run([
          '--version',
          'project',
          'list',
          '--config-dir',
          configDir,
        ]);
      });

      test('then the version is printed', () {
        expect(logger.infoCalls, [
          equalsInfoCall(message: 'Serverpod Cloud CLI version: $version'),
        ]);
      });
    });

    group('when running --version with a mandatory option missing', () {
      setUp(() async {
        await cli.run([
          'project',
          'create',
          '--version',
          '--config-dir',
          configDir,
        ]);
      });

      test('then the version is printed', () {
        expect(logger.infoCalls, [
          equalsInfoCall(message: 'Serverpod Cloud CLI version: $version'),
        ]);
      });
    });
  });
}

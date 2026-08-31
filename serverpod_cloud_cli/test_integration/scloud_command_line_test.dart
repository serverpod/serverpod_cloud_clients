import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/scloud_version.dart';
import 'package:test/test.dart';

void main() {
  late Directory configDir;

  setUpAll(() async {
    configDir = await Directory.systemTemp.createTemp(
      'scloud_command_line_test_',
    );
    await File(
      p.join(configDir.path, ResourceManagerConstants.latestVersionFilePath),
    ).writeAsString(
      jsonEncode({
        'version': cliVersion.toString(),
        'valid_until': DateTime.now()
            .add(PackageVersionConstants.localStorageValidityTime)
            .millisecondsSinceEpoch,
      }),
    );
  });

  tearDownAll(() async {
    if (configDir.existsSync()) {
      configDir.deleteSync(recursive: true);
    }
  });

  Future<ProcessResult> runScloud(final List<String> args) {
    return Process.run(Platform.resolvedExecutable, [
      p.join('bin', 'serverpod_cloud_cli.dart'),
      ...args,
      '--config-dir',
      configDir.path,
      '--no-analytics',
      '--no-breaking-version-check',
    ]);
  }

  group('Given the scloud command line entrypoint', () {
    group('when running version', () {
      late ProcessResult result;

      setUpAll(() async {
        result = await runScloud(['version']);
      });

      test('then the process exits with code 0', () {
        expect(result.exitCode, 0);
      });

      test('then the version is printed to stdout', () {
        expect(
          result.stdout,
          contains('Serverpod Cloud CLI version: $cliVersion'),
        );
      });

      test('then stderr is empty', () {
        expect(result.stderr, isEmpty);
      });

      test('then no error is printed', () {
        expect(result.stdout, isNot(contains('ERROR:')));
      });
    });

    group('when running with the --help option', () {
      late ProcessResult result;

      setUpAll(() async {
        result = await runScloud(['--help']);
      });

      test('then the process exits with code 0', () {
        expect(result.exitCode, 0);
      });

      test('then the usage is printed to stdout', () {
        expect(result.stdout, contains('Manage your Serverpod Cloud projects'));
      });

      test('then stderr is empty', () {
        expect(result.stderr, isEmpty);
      });

      test('then no error is printed', () {
        expect(result.stdout, isNot(contains('ERROR:')));
      });
    });

    group('when running context set with a project id', () {
      late ProcessResult result;

      setUpAll(() async {
        result = await runScloud(['context', 'set', 'my-project']);
      });

      test('then the process exits with code 0', () {
        expect(result.exitCode, 0);
      });

      test('then a success message is printed to stdout', () {
        expect(
          result.stdout,
          contains('Set the global project context to "my-project".'),
        );
      });

      test('then stderr is empty', () {
        expect(result.stderr, isEmpty);
      });

      test('then no error is printed', () {
        expect(result.stdout, isNot(contains('ERROR:')));
      });
    });

    group('when running an unknown command', () {
      late ProcessResult result;

      setUpAll(() async {
        result = await runScloud(['not-a-command']);
      });

      test('then the process exits with code 1', () {
        expect(result.exitCode, ExitException.codeError);
      });

      test('then an error is printed to stderr for the unknown command', () {
        expect(result.stderr, contains('ERROR:'));
        expect(
          result.stderr,
          contains('Could not find a command named "not-a-command".'),
        );
      });

      test('then the usage is printed to stderr', () {
        expect(result.stderr, contains('Usage: scloud <command> [arguments]'));
      });

      test(
        'then the failure is not reported to stderr as an internal error',
        () {
          expect(result.stderr, isNot(contains('Yikes!')));
          expect(result.stderr, isNot(contains('#0')));
        },
      );

      test('then stdout is empty', () {
        expect(result.stdout, isEmpty);
      });
    });

    group('when running version with an unknown option', () {
      late ProcessResult result;

      setUpAll(() async {
        result = await runScloud(['version', '--bogus']);
      });

      test('then the process exits with code 1', () {
        expect(result.exitCode, ExitException.codeError);
      });

      test('then an error is printed to stderr for the unknown option', () {
        expect(result.stderr, contains('ERROR:'));
        expect(
          result.stderr,
          contains('Could not find an option named "--bogus".'),
        );
      });

      test('then the command usage is printed to stderr', () {
        expect(result.stderr, contains('Usage: scloud version [arguments]'));
      });

      test(
        'then the failure is not reported to stderr as an internal error',
        () {
          expect(result.stderr, isNot(contains('Yikes!')));
          expect(result.stderr, isNot(contains('#0')));
        },
      );

      test('then stdout is empty', () {
        expect(result.stdout, isEmpty);
      });
    });

    group('when running context set without a project id', () {
      late ProcessResult result;

      setUpAll(() async {
        result = await runScloud(['context', 'set']);
      });

      test('then the process exits with code 1', () {
        expect(result.exitCode, ExitException.codeError);
      });

      test('then an error is printed to stderr for the missing option', () {
        expect(result.stderr, contains('ERROR:'));
        expect(result.stderr, contains('Option `project` is mandatory.'));
      });

      test(
        'then the failure is not reported to stderr as an internal error',
        () {
          expect(result.stderr, isNot(contains('Yikes!')));
          expect(result.stderr, isNot(contains('#0')));
        },
      );

      test('then stdout is empty', () {
        expect(result.stdout, isEmpty);
      });
    });
  }, timeout: const Timeout(Duration(minutes: 1)));
}

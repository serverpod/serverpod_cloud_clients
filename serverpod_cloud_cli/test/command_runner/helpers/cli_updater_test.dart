import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_updater.dart';
import 'package:test/test.dart';

void main() {
  group('Given an environment without the update attempted variable', () {
    test('when reading the attempted version then returns null', () {
      expect(attemptedCliUpdateVersion(const {}), isNull);
    });
  });

  group('Given an environment with an empty update attempted variable', () {
    test('when reading the attempted version then returns null', () {
      expect(
        attemptedCliUpdateVersion(const {cliUpdateAttemptedEnvName: ''}),
        isNull,
      );
    });
  });

  group(
    'Given an environment with an unparsable update attempted variable',
    () {
      test('when reading the attempted version then returns null', () {
        expect(
          attemptedCliUpdateVersion(const {cliUpdateAttemptedEnvName: 'true'}),
          isNull,
        );
      });
    },
  );

  group('Given a CLI installed with dart install', () {
    const executable =
        '/Users/me/Library/Application Support/dart/install/app-bundles/'
        'serverpod_cloud_cli/hosted/0.37.0/bundle/bin/scloud';
    const invokedExecutable = 'scloud';
    const script = '/Users/me/projects/my_app/scloud';

    test('when resolving the installation then it is native', () {
      expect(
        resolveCliInstallation(
          resolvedExecutable: executable,
          scriptPath: script,
        ),
        CliInstallation.native,
      );
    });

    test('when resolving the install arguments then installs from pub', () {
      expect(
        installArguments(CliInstallation.native, version: Version(1, 2, 3)),
        ['install', 'serverpod_cloud_cli@1.2.3'],
      );
    });

    test('when resolving the rerun invocation then runs the invoked '
        'executable with only the arguments', () {
      final invocation = rerunInvocation(
        const ['deploy', '--project', 'abc'],
        installation: CliInstallation.native,
        invokedExecutable: invokedExecutable,
        resolvedExecutable: executable,
        scriptPath: script,
      );

      expect(invocation.executable, invokedExecutable);
      expect(invocation.args, ['deploy', '--project', 'abc']);
    });
  });

  group('Given a CLI activated with dart pub global activate', () {
    const executable = '/sdk/bin/dart';
    const script =
        '/Users/me/.pub-cache/global_packages/serverpod_cloud_cli/bin/'
        'serverpod_cloud_cli.dart-3.13.1.snapshot';

    test('when resolving the installation then it is pub global', () {
      expect(
        resolveCliInstallation(
          resolvedExecutable: executable,
          scriptPath: script,
        ),
        CliInstallation.pubGlobal,
      );
    });

    test('when resolving the install arguments then reactivates the '
        'package', () {
      expect(
        installArguments(CliInstallation.pubGlobal, version: Version(1, 2, 3)),
        ['pub', 'global', 'activate', 'serverpod_cloud_cli', '1.2.3'],
      );
    });

    test('when resolving the rerun invocation then runs the snapshot on the '
        'Dart VM', () {
      final invocation = rerunInvocation(
        const ['deploy', '--project', 'abc'],
        installation: CliInstallation.pubGlobal,
        invokedExecutable: 'dart',
        resolvedExecutable: executable,
        scriptPath: script,
      );

      expect(invocation.executable, executable);
      expect(invocation.args, [script, 'deploy', '--project', 'abc']);
    });
  });

  group('Given a CLI run from a source checkout', () {
    const executable = '/sdk/bin/dart';
    const script =
        '/repo/packages/serverpod_cloud_cli/bin/'
        'serverpod_cloud_cli.dart';

    test('when resolving the installation then it is source', () {
      expect(
        resolveCliInstallation(
          resolvedExecutable: executable,
          scriptPath: script,
        ),
        CliInstallation.source,
      );
    });

    test('when resolving the install arguments then throws a StateError', () {
      expect(
        () =>
            installArguments(CliInstallation.source, version: Version(1, 2, 3)),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Given a CLI activated from a local path', () {
    test('when resolving the installation then it is source', () {
      expect(
        resolveCliInstallation(
          resolvedExecutable: '/sdk/bin/dart',
          scriptPath:
              '/repo/packages/serverpod_cloud_cli/.dart_tool/pub/bin/'
              'serverpod_cloud_cli/serverpod_cloud_cli.dart-3.13.1.snapshot',
        ),
        CliInstallation.source,
      );
    });
  });

  group('Given an environment with a version in the update attempted '
      'variable', () {
    test('when reading the attempted version then returns that version', () {
      expect(
        attemptedCliUpdateVersion(const {cliUpdateAttemptedEnvName: '1.2.3'}),
        Version(1, 2, 3),
      );
    });

    test('when a later version is released then it does not match', () {
      final attempted = attemptedCliUpdateVersion(const {
        cliUpdateAttemptedEnvName: '1.2.3',
      });

      expect(attempted, isNot(Version(1, 3, 0)));
    });
  });
}

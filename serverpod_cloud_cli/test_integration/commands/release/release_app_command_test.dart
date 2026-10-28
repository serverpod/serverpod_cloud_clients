import 'package:args/command_runner.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/release/release_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
final _supportedPlatformNames = ReleasePlatformsOption.supportedPlatforms
    .map((platform) => platform.name)
    .join(', ');

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse('999.0.0'),
    serviceProvider: CloudCliServiceProvider(apiClientFactory: (_) => client),
  );

  tearDown(() {
    logger.clear();
  });

  test('Given release app command when instantiated then requires login', () {
    expect(CloudReleaseAppCommand(logger: logger).requireLogin, isTrue);
  });

  test('Given the platforms option '
      'then its help text lists the supported platforms', () {
    expect(
      const ReleasePlatformsOption().helpText,
      contains('Supported platforms: $_supportedPlatformNames.'),
    );
  });

  group('Given a workspace with a Serverpod server and Flutter app', () {
    setUp(() async {
      await ProjectFactory.serverpodAppWorkspace().create();
      await d.dir('monorepo', [
        d.dir('project_flutter', [
          d.dir('lib', [d.file('main.dart', 'void main() {}')]),
          d.dir('android', [d.file('build.gradle.kts', '')]),
          d.dir('windows', [d.file('CMakeLists.txt', '')]),
        ]),
      ]).create();
    });

    group('when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the command completes', () async {
        await expectLater(commandResult, completes);
      });

      test('then the zipped archive size is reported', () async {
        await commandResult;

        expect(
          logger.successCalls.map((call) => call.message),
          contains(startsWith('The app was zipped (')),
        );
      });
    });

    test('when releasing the app with --platforms android '
        'then the zipped archive size is reported', () async {
      await cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
        '--platforms',
        'android',
      ]);

      expect(
        logger.successCalls.map((call) => call.message),
        contains(startsWith('The app was zipped (')),
      );
    });

    group('when releasing the app with --platforms android,ios', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android,ios',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the missing platform is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message: 'The app has no code for the platforms: ios.',
              hint:
                  'Add them with "flutter create --platforms=ios ." '
                  'in the app directory, or leave them out of --platforms.',
            ),
          ),
        );
      });
    });

    test('when releasing the app with --platforms android,linux,windows '
        'then a UsageException names the unsupported platforms', () async {
      await expectLater(
        cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android,linux,windows',
        ]),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains(
              'Releasing for linux, windows is not supported yet. '
              'Supported platforms: $_supportedPlatformNames.',
            ),
          ),
        ),
      );
    });

    test('when releasing the app with an unknown platform '
        'then a UsageException names the unknown platform', () async {
      await expectLater(
        cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'fuchsia',
        ]),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains(
              'Failed to resolve option `platforms`: FormatException: '
              '"fuchsia" is not in android|ios|linux|macos|windows.',
            ),
          ),
        ),
      );
    });

    group('and a second Flutter app '
        'and project.appDir in scloud.yaml names the first app', () {
      setUp(() async {
        await d.dir('monorepo', [
          d.file(
            'pubspec.yaml',
            ProjectFactory.serverpodAppWorkspaceRootPubspec(['project_admin']),
          ),
          d.dir('project_admin', [
            d.file(
              'pubspec.yaml',
              ProjectFactory.flutterAppPubspec(
                withPackageName: 'project_admin',
              ),
            ),
          ]),
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appDir: "../project_flutter"
'''),
          ]),
        ]).create();
      });

      test('when releasing the app '
          'then the configured app is zipped', () async {
        await cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);

        expect(
          logger.successCalls.map((call) => call.message),
          contains(startsWith('The app was zipped (')),
        );
      });
    });

    group('and project.appDir in scloud.yaml names a missing directory', () {
      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appDir: "../missing_app"
'''),
          ]),
        ]).create();
      });

      group('when releasing the app', () {
        late Future<void> commandResult;

        setUp(() {
          commandResult = cli.run([
            'release',
            'app',
            '--project',
            _projectId,
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
          ]);
        });

        test('then the command throws ErrorExitException', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then the missing directory is logged', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    'The app directory '
                    '${p.join(d.sandbox, 'monorepo', 'missing_app')} '
                    'set by project.appDir in '
                    '${p.join(d.sandbox, 'monorepo', 'project_server', 'scloud.yaml')} '
                    'does not exist.',
              ),
            ),
          );
        });
      });

      test('when releasing the app with --app-dir '
          'then the --app-dir app is zipped', () async {
        await cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--app-dir',
          p.join(d.sandbox, 'monorepo', 'project_flutter'),
        ]);

        expect(
          logger.successCalls.map((call) => call.message),
          contains(startsWith('The app was zipped')),
        );
      });
    });

    test('when releasing the app with --app-dir '
        'then the zipped archive size is reported', () async {
      await cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'monorepo', 'project_flutter'),
      ]);

      expect(
        logger.successCalls.map((call) => call.message),
        contains(startsWith('The app was zipped (')),
      );
    });
  });

  test('Given a non-workspace Flutter app '
      'when releasing the app with --app-dir '
      'then the zipped archive size is reported', () async {
    await ProjectFactory.nonWorkspaceFlutterAppDir(
      contents: [
        d.dir('lib', [d.file('main.dart', 'void main() {}')]),
      ],
    ).create();

    await cli.run([
      'release',
      'app',
      '--project',
      _projectId,
      '--app-dir',
      p.join(d.sandbox, 'project_flutter'),
    ]);

    expect(
      logger.successCalls.map((call) => call.message),
      contains(startsWith('The app was zipped')),
    );
  });

  test('Given a non-workspace Serverpod server project '
      'and a Flutter app near the server directory '
      'when releasing the app '
      'then the zipped archive size is reported', () async {
    await ProjectFactory.serverpodServerDir().create();
    await ProjectFactory.nonWorkspaceFlutterAppDir(
      contents: [
        d.dir('lib', [d.file('main.dart', 'void main() {}')]),
      ],
    ).create();

    await cli.run([
      'release',
      'app',
      '--project',
      _projectId,
      '--project-dir',
      p.join(d.sandbox, ProjectFactory.defaultDirectoryName),
    ]);

    expect(
      logger.successCalls.map((call) => call.message),
      contains(startsWith('The app was zipped')),
    );
  });

  group('Given a non-workspace Serverpod server project '
      'without a Flutter app near the server directory '
      'when releasing the app', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.serverpodServerDir().create();

      commandResult = cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, ProjectFactory.defaultDirectoryName),
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the missing app is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message: 'No Flutter app found.',
            hint:
                'Select the Flutter app directory with the --app-dir option, '
                'or with project.appDir in scloud.yaml.',
          ),
        ),
      );
    });
  });
}

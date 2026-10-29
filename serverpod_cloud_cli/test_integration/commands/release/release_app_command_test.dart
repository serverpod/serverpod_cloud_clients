import 'package:archive/archive.dart';
import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
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
import '../../../test_utils/recording_file_uploader.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
const _appUploadDescription = 'app-upload-description';
final _supportedPlatformNames = ReleasePlatformsOption.supportedPlatforms
    .map((platform) => platform.name)
    .join(', ');

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final fileUploader = RecordingFileUploader();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse('999.0.0'),
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (_) => client,
      fileUploaderFactory: fileUploader.factory,
    ),
  );

  setUpAll(() {
    registerFallbackValue(<AppPlatform>[]);
  });

  setUp(() {
    when(
      () => client.appBuilds.createBuilds(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        platforms: any(named: 'platforms'),
        flutterAppDir: any(named: 'flutterAppDir'),
        archiveSize: any(named: 'archiveSize'),
        versionName: any(named: 'versionName'),
        commitHash: any(named: 'commitHash'),
        commitMessage: any(named: 'commitMessage'),
        branch: any(named: 'branch'),
      ),
    ).thenAnswer(
      (invocation) async => AppBuildsUploadBuilder()
          .withPlatforms(
            invocation.namedArguments[#platforms] as List<AppPlatform>,
          )
          .withUploadDescription(_appUploadDescription)
          .build(),
    );
  });

  tearDown(() {
    logger.clear();
    fileUploader.clear();
    reset(client.appBuilds);
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

      test('then an Android build is requested for the app directory '
          'in the archive and the archive size', () async {
        await commandResult;

        final archiveSize = verify(
          () => client.appBuilds.createBuilds(
            cloudCapsuleId: _projectId,
            platforms: [AppPlatform.android],
            flutterAppDir: 'project_flutter',
            archiveSize: captureAny(named: 'archiveSize'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).captured.single;
        expect(archiveSize, fileUploader.uploads.single.data.length);
      });

      test('then no version name is sent', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            versionName: null,
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });

      test('then the archive is uploaded with the upload description '
          'of the build', () async {
        await commandResult;

        expect(
          fileUploader.uploads.single.uploadDescription,
          _appUploadDescription,
        );
      });

      test('then the archive holds the app with its Android code '
          'but not its Windows code', () async {
        await commandResult;

        final fileNames = _uploadedArchive(
          fileUploader.uploads.single,
        ).files.map((file) => file.name);
        expect(
          fileNames,
          containsAll([
            'project_flutter/lib/main.dart',
            'project_flutter/android/build.gradle.kts',
          ]),
        );
        expect(
          fileNames,
          isNot(contains('project_flutter/windows/CMakeLists.txt')),
        );
      });

      test('then the upload is reported with the Android build', () async {
        await commandResult;

        expect(
          logger.successCalls.map((call) => call.message),
          contains(
            matches(
              RegExp(r'^The app was uploaded for the builds: android \S+\.$'),
            ),
          ),
        );
      });
    });

    test('and a version with a build number in the app pubspec '
        'when releasing the app '
        'then the version name is sent without the build number', () async {
      await d.dir('monorepo', [
        d.dir('project_flutter', [
          d.file(
            'pubspec.yaml',
            ProjectFactory.serverpodFlutterAppPubspec(withVersion: '1.2.3+4'),
          ),
        ]),
      ]).create();

      await cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
      ]);

      verify(
        () => client.appBuilds.createBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platforms: any(named: 'platforms'),
          flutterAppDir: any(named: 'flutterAppDir'),
          archiveSize: any(named: 'archiveSize'),
          versionName: '1.2.3',
          commitHash: any(named: 'commitHash'),
          commitMessage: any(named: 'commitMessage'),
          branch: any(named: 'branch'),
        ),
      ).called(1);
    });

    group('and iOS code when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_flutter', [
            d.dir('ios', [d.file('Podfile', '')]),
          ]),
        ]).create();

        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then a build is requested for each platform', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            cloudCapsuleId: _projectId,
            platforms: [AppPlatform.android, AppPlatform.ios],
            flutterAppDir: 'project_flutter',
            archiveSize: any(named: 'archiveSize'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });

      test('then one archive with the code of both platforms '
          'is uploaded', () async {
        await commandResult;

        final fileNames = _uploadedArchive(
          fileUploader.uploads.single,
        ).files.map((file) => file.name);
        expect(
          fileNames,
          containsAll([
            'project_flutter/android/build.gradle.kts',
            'project_flutter/ios/Podfile',
          ]),
        );
      });

      test('then the upload is reported with both builds', () async {
        await commandResult;

        expect(
          logger.successCalls.map((call) => call.message),
          contains(
            matches(
              RegExp(
                r'^The app was uploaded for the builds: android \S+, ios \S+\.$',
              ),
            ),
          ),
        );
      });
    });

    test('when releasing the app with --platforms android '
        'then the upload is reported', () async {
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
        contains(startsWith('The app was uploaded for the builds: ')),
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

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appBuilds.createBuilds(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        );
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
          'then the configured app is uploaded', () async {
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
          contains(startsWith('The app was uploaded for the builds: ')),
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
          'then the --app-dir app is uploaded', () async {
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
          contains(startsWith('The app was uploaded for the builds: ')),
        );
      });
    });

    test('when releasing the app with --app-dir '
        'then the upload is reported', () async {
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
        contains(startsWith('The app was uploaded for the builds: ')),
      );
    });
  });

  group('Given a non-workspace Flutter app with Android code', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          d.dir('lib', [d.file('main.dart', 'void main() {}')]),
          d.dir('android', [d.file('build.gradle.kts', '')]),
        ],
      ).create();
    });

    test('when releasing the app with --app-dir '
        'then the build is requested for the archive root', () async {
      await cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'project_flutter'),
      ]);

      verify(
        () => client.appBuilds.createBuilds(
          cloudCapsuleId: _projectId,
          platforms: [AppPlatform.android],
          flutterAppDir: '.',
          archiveSize: any(named: 'archiveSize'),
          versionName: any(named: 'versionName'),
          commitHash: any(named: 'commitHash'),
          commitMessage: any(named: 'commitMessage'),
          branch: any(named: 'branch'),
        ),
      ).called(1);
    });

    group('and app publishing disabled '
        'when releasing the app with --app-dir', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.createBuilds(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).thenThrow(
          AppPublishingDisabledException(
            message: 'App publishing is not available in this environment yet.',
          ),
        );

        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--app-dir',
          p.join(d.sandbox, 'project_flutter'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the error is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'App publishing is not available in this environment yet.',
            ),
          ),
        );
      });

      test('then nothing is uploaded', () async {
        await commandResult.catchError((_) {});

        expect(fileUploader.uploads, isEmpty);
      });
    });

    test('and an archive above the upload limit '
        'when releasing the app with --app-dir '
        'then the error is logged with a hint', () async {
      when(
        () => client.appBuilds.createBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platforms: any(named: 'platforms'),
          flutterAppDir: any(named: 'flutterAppDir'),
          archiveSize: any(named: 'archiveSize'),
          versionName: any(named: 'versionName'),
          commitHash: any(named: 'commitHash'),
          commitMessage: any(named: 'commitMessage'),
          branch: any(named: 'branch'),
        ),
      ).thenThrow(
        UploadTooLargeException(
          message: 'The app archive exceeds the upload limit.',
          sizeBytes: 2,
          maxSizeBytes: 1,
        ),
      );

      await cli
          .run([
            'release',
            'app',
            '--project',
            _projectId,
            '--app-dir',
            p.join(d.sandbox, 'project_flutter'),
          ])
          .catchError((_) {});

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message: 'The app archive exceeds the upload limit.',
            hint: 'Exclude files from the app with a .scloudignore file.',
          ),
        ),
      );
    });
  });

  group('Given a non-workspace Flutter app '
      'without code for a supported platform '
      'when releasing the app with --app-dir', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          d.dir('windows', [d.file('CMakeLists.txt', '')]),
        ],
      ).create();

      commandResult = cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'project_flutter'),
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the missing platforms are logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message:
                'The app has no code for the platforms: '
                '$_supportedPlatformNames.',
            hint:
                'Add one with "flutter create --platforms=android ." '
                'in the app directory.',
          ),
        ),
      );
    });
  });

  test('Given a non-workspace Serverpod server project '
      'and a Flutter app near the server directory '
      'when releasing the app '
      'then the upload is reported', () async {
    await ProjectFactory.serverpodServerDir().create();
    await ProjectFactory.nonWorkspaceFlutterAppDir(
      contents: [
        d.dir('android', [d.file('build.gradle.kts', '')]),
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
      contains(startsWith('The app was uploaded for the builds: ')),
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

Archive _uploadedArchive(RecordedUpload upload) {
  return ZipDecoder().decodeBytes(upload.data);
}

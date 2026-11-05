import 'package:archive/archive.dart';
import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../test/util/inline_tui/helpers/fake_terminal.dart';
import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/recording_file_uploader.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
const _appUploadDescription = 'app-upload-description';
final _supportedPlatformNames = AppPublishPlatformsOption.supportedPlatforms
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
    registerFallbackValue(const Uuid().v4obj());
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

  test('Given app publish command when instantiated then requires login', () {
    expect(CloudAppPublishCommand(logger: logger).requireLogin, isTrue);
  });

  test('Given the platforms option '
      'then its help text lists the supported platforms', () {
    expect(
      const AppPublishPlatformsOption().helpText,
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

    group('when releasing the app with --no-await', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--no-await',
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

      test('then the publishing to Android is reported', () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          contains('Publishing the app to Android'),
        );
      });

      test('then the builds are not followed', () async {
        await commandResult;

        verifyNever(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        );
      });

      test('then the command to follow the builds is shown', () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          contains(matches(RegExp(r'^Follow it: \S+ app show \S+$'))),
        );
      });
    });

    group('and builds that succeed when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            AppBuildDetailBuilder()
                .withBuild(
                  AppBuildSummaryBuilder()
                      .withPlatform(AppPlatform.android)
                      .withStatus(AppBuildStatus.running)
                      .build(),
                )
                .build(),
            AppBuildDetailBuilder()
                .withBuild(
                  AppBuildSummaryBuilder()
                      .withPlatform(AppPlatform.android)
                      .withStatus(AppBuildStatus.succeeded)
                      .build(),
                )
                .build(),
          ]),
        );

        when(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
            stepIndex: any(named: 'stepIndex'),
          ),
        ).thenAnswer(
          (_) async =>
              [for (var line = 1; line <= 7; line++) 'line $line\n'].join(),
        );

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the command to follow the builds is shown', () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          contains(matches(RegExp(r'^Follow it: \S+ app show \S+$'))),
        );
      });

      test('then the build is followed', () async {
        await commandResult;

        verify(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: _projectId,
            buildId: any(named: 'buildId'),
          ),
        ).called(1);
      });

      test('then the final status line shows every stage done', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            'Android  ✓ Queued    ✓ Built     ✓ Uploaded → Play internal\n',
          ),
        );
      });

      test('then the last five lines of the build log scroll below '
          'the status line', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            '→ Play internal\n'
            'line 3\n'
            'line 4\n'
            'line 5\n'
            'line 6\n'
            'line 7',
          ),
        );
      });

      test('then the build log is cleared', () async {
        await commandResult;

        expect(
          _lastRender(logger.inlineTerminal as FakeTerminal),
          'Android  ✓ Queued    ✓ Built     ✓ Uploaded → Play internal\n',
        );
      });

      test('then the publication is reported', () async {
        await commandResult;

        expect(
          logger.successCalls.map((call) => call.message),
          contains('Published the app to Android.'),
        );
      });
    });

    test('and no interactive terminal '
        'when releasing the app '
        'then each status change is printed as a line', () async {
      logger.inlineTerminal = FakeTerminal(hasTerminal: false);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          AppBuildDetailBuilder()
              .withBuild(
                AppBuildSummaryBuilder()
                    .withPlatform(AppPlatform.android)
                    .withStatus(AppBuildStatus.running)
                    .build(),
              )
              .build(),
          AppBuildDetailBuilder()
              .withBuild(
                AppBuildSummaryBuilder()
                    .withPlatform(AppPlatform.android)
                    .withStatus(AppBuildStatus.succeeded)
                    .build(),
              )
              .build(),
        ]),
      );

      await cli.run([
        'app',
        'publish',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
      ]);

      expect(logger.lineCalls.map((call) => call.line), [
        'Android  ⠋ Queueing  ● Build     ● Upload → Play internal',
        'Android  ✓ Queued    ⠋ Building  ● Upload → Play internal',
        'Android  ✓ Queued    ✓ Built     ✓ Uploaded → Play internal',
      ]);
    });

    group('and a build tail that closes before the build ends '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        final statuses = [AppBuildStatus.queued, AppBuildStatus.succeeded];
        var connection = 0;
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppBuildDetailBuilder()
                .withBuild(
                  AppBuildSummaryBuilder()
                      .withPlatform(AppPlatform.android)
                      .withStatus(statuses[connection++])
                      .build(),
                )
                .withSteps([])
                .build(),
          ),
        );

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the build is followed again', () async {
        await commandResult;

        verify(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: _projectId,
            buildId: any(named: 'buildId'),
          ),
        ).called(2);
      });

      test('then the publication is reported', () async {
        await commandResult;

        expect(
          logger.successCalls.map((call) => call.message),
          contains('Published the app to Android.'),
        );
      });
    });

    group('and a step log that cannot be fetched when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppBuildDetailBuilder()
                .withBuild(
                  AppBuildSummaryBuilder()
                      .withPlatform(AppPlatform.android)
                      .withStatus(AppBuildStatus.succeeded)
                      .build(),
                )
                .withSteps([
                  AppBuildStepInfoBuilder()
                      .withIndex(0)
                      .withName('Build')
                      .build(),
                  AppBuildStepInfoBuilder()
                      .withIndex(1)
                      .withName('Upload')
                      .build(),
                ])
                .build(),
          ),
        );
        when(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
            stepIndex: 0,
          ),
        ).thenThrow(Exception('Connection reset'));
        when(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
            stepIndex: 1,
          ),
        ).thenAnswer((_) async => 'Uploaded app-release.aab\n');

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test(
        'then the error is shown in the log while following the build',
        () async {
          await commandResult;

          expect(
            (logger.inlineTerminal as FakeTerminal).output,
            contains('Failed to fetch the log of step 0 of the app build'),
          );
        },
      );

      test('then the log goes on with the next step', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            '--- Upload (Succeeded) ---\n'
            'Uploaded app-release.aab',
          ),
        );
      });

      test('then the publication is reported', () async {
        await commandResult;

        expect(
          logger.successCalls.map((call) => call.message),
          contains('Published the app to Android.'),
        );
      });
    });

    group('and a build that fails when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            AppBuildDetailBuilder()
                .withBuild(
                  AppBuildSummaryBuilder()
                      .withPlatform(AppPlatform.android)
                      .withStatus(AppBuildStatus.failed)
                      .withMessage('Gradle task assembleRelease failed.')
                      .build(),
                )
                .withSteps([
                  AppBuildStepInfoBuilder()
                      .withStatus(AppBuildStepStatus.failed)
                      .build(),
                ])
                .build(),
          ),
        );
        when(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
            stepIndex: any(named: 'stepIndex'),
          ),
        ).thenAnswer(
          (_) async =>
              [for (var line = 1; line <= 7; line++) 'line $line\n'].join(),
        );

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the failed stage is shown', () async {
        await commandResult.catchError((_) {});

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            'Android  ✓ Queued    ✗ Build     ● Upload → Play internal\n',
          ),
        );
      });

      test(
        'then the build log is kept in full below the status line',
        () async {
          await commandResult.catchError((_) {});

          expect(
            _lastRender(logger.inlineTerminal as FakeTerminal),
            'Android  ✓ Queued    ✗ Build     ● Upload → Play internal\n'
            '--- Build (Failed) ---\n'
            '${[for (var line = 1; line <= 7; line++) 'line $line\n'].join()}',
          );
        },
      );

      test('then the failure is logged with its message', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'The Android build failed: '
                  'Gradle task assembleRelease failed.',
            ),
          ),
        );
      });
    });

    group('and an upload that fails when releasing the app', () {
      final upload = AppBuildsUploadBuilder().withPlatforms([
        AppPlatform.android,
      ]).build();
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
        ).thenAnswer((_) async => upload);
        when(
          () => client.appBuilds.cancelBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenAnswer((_) async {});
        fileUploader.uploadResponse = false;

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--no-await',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the build is cancelled', () async {
        await commandResult.catchError((_) {});

        verify(
          () => client.appBuilds.cancelBuild(
            cloudCapsuleId: _projectId,
            buildId: upload.builds.single.buildId,
          ),
        ).called(1);
      });

      test('then the upload is not reported as successful', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls.map((call) => call.message),
          isNot(contains(startsWith('The app was uploaded for the builds: '))),
        );
      });
    });

    group('and an upload that fails and a build that cannot be cancelled '
        'when releasing the app', () {
      final upload = AppBuildsUploadBuilder().withPlatforms([
        AppPlatform.android,
      ]).build();
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
        ).thenAnswer((_) async => upload);
        when(
          () => client.appBuilds.cancelBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenThrow(Exception('Connection refused'));
        fileUploader.uploadResponse = false;

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--no-await',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the build that was not cancelled is logged as a warning '
          'with the reason', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.warningCalls,
          contains(
            equalsWarningCall(
              message:
                  'Failed to cancel the app build '
                  '${upload.builds.single.buildId}: '
                  'Exception: Connection refused',
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
        'app',
        'publish',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
        '--no-await',
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

    group('and iOS code and builds that succeed when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_flutter', [
            d.dir('ios', [d.file('Podfile', '')]),
          ]),
        ]).create();

        final platformOfBuild = <UuidValue, AppPlatform>{};
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
        ).thenAnswer((invocation) async {
          final upload = AppBuildsUploadBuilder()
              .withPlatforms(
                invocation.namedArguments[#platforms] as List<AppPlatform>,
              )
              .withUploadDescription(_appUploadDescription)
              .build();
          for (final build in upload.builds) {
            platformOfBuild[build.buildId] = build.platform;
          }
          return upload;
        });
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
          ),
        ).thenAnswer(
          (invocation) => Stream.value(
            AppBuildDetailBuilder()
                .withBuild(
                  AppBuildSummaryBuilder()
                      .withPlatform(
                        platformOfBuild[invocation.namedArguments[#buildId]]!,
                      )
                      .withStatus(AppBuildStatus.succeeded)
                      .build(),
                )
                .build(),
          ),
        );
        when(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
            stepIndex: any(named: 'stepIndex'),
          ),
        ).thenAnswer((_) async => 'Built the app\n');

        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then each log heading names its platform', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          allOf(
            contains('--- Android: Build (Succeeded) ---'),
            contains('--- iOS: Build (Succeeded) ---'),
          ),
        );
      });
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
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--no-await',
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

      test('then the publishing to both platforms is reported', () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          contains('Publishing the app to iOS and Android'),
        );
      });
    });

    test('when releasing the app with --platforms android '
        'then the upload is reported', () async {
      await cli.run([
        'app',
        'publish',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
        '--platforms',
        'android',
        '--no-await',
      ]);

      expect(
        logger.infoCalls.map((call) => call.message),
        contains(startsWith('Publishing ')),
      );
    });

    group('when releasing the app with --platforms android,ios', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android,ios',
          '--no-await',
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
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android,linux,windows',
          '--no-await',
        ]),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains(
              'Publishing for linux, windows is not supported yet. '
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
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'fuchsia',
          '--no-await',
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
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--no-await',
        ]);

        expect(
          logger.infoCalls.map((call) => call.message),
          contains(startsWith('Publishing ')),
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
            'app',
            'publish',
            '--project',
            _projectId,
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
            '--no-await',
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
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--app-dir',
          p.join(d.sandbox, 'monorepo', 'project_flutter'),
          '--no-await',
        ]);

        expect(
          logger.infoCalls.map((call) => call.message),
          contains(startsWith('Publishing ')),
        );
      });
    });

    test('when releasing the app with --app-dir '
        'then the upload is reported', () async {
      await cli.run([
        'app',
        'publish',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'monorepo', 'project_flutter'),
        '--no-await',
      ]);

      expect(
        logger.infoCalls.map((call) => call.message),
        contains(startsWith('Publishing ')),
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
        'app',
        'publish',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'project_flutter'),
        '--no-await',
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
          'app',
          'publish',
          '--project',
          _projectId,
          '--app-dir',
          p.join(d.sandbox, 'project_flutter'),
          '--no-await',
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
            'app',
            'publish',
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
        'app',
        'publish',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'project_flutter'),
        '--no-await',
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
      'app',
      'publish',
      '--project',
      _projectId,
      '--project-dir',
      p.join(d.sandbox, ProjectFactory.defaultDirectoryName),
      '--no-await',
    ]);

    expect(
      logger.infoCalls.map((call) => call.message),
      contains(startsWith('Publishing ')),
    );
  });

  group('Given a non-workspace Serverpod server project '
      'without a Flutter app near the server directory '
      'when releasing the app', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.serverpodServerDir().create();

      commandResult = cli.run([
        'app',
        'publish',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, ProjectFactory.defaultDirectoryName),
        '--no-await',
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

String _lastRender(FakeTerminal terminal) {
  final output = terminal.output.replaceAll('\x1b[?25h', '');
  return output.substring(output.lastIndexOf('\x1b[0J') + '\x1b[0J'.length);
}

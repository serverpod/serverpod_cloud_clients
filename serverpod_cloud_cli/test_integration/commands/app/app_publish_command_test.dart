import 'dart:io';

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
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart'
    show getConsoleBaseUrl;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../test/util/inline_tui/helpers/fake_terminal.dart';
import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/push_current_dir.dart';
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
    registerFallbackValue(<AppPlatform, String>{});
    registerFallbackValue(const Uuid().v4obj());
  });

  setUp(() {
    when(
      () => client.appBuilds.createBuilds(
        appIdentifiers: any(named: 'appIdentifiers'),
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        platforms: any(named: 'platforms'),
        flutterAppDir: any(named: 'flutterAppDir'),
        archiveSize: any(named: 'archiveSize'),
        flutterVersion: any(named: 'flutterVersion'),
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
    reset(client.appPublishing);
  });

  test('Given app publish command when instantiated then requires login', () {
    expect(CloudAppPublishCommand(logger: logger).requireLogin, isTrue);
  });

  for (final (inputs, expected) in [
    (['IOS'], [AppPlatform.ios]),
    (['Android'], [AppPlatform.android]),
    ([' iOs , ANDROID '], [AppPlatform.android, AppPlatform.ios]),
    (['IOS', 'android'], [AppPlatform.android, AppPlatform.ios]),
    (['ios,IOS'], [AppPlatform.ios]),
  ]) {
    test('Given platform arguments $inputs when publishing '
        'then builds use the canonical platforms $expected', () async {
      await ProjectFactory.serverpodAppWorkspace(
        extraContents: [
          d.dir('project_flutter', [
            ProjectFactory.flutterAndroidDir(),
            ProjectFactory.flutterIosDir(),
          ]),
        ],
      ).create();

      await cli.run([
        'app',
        'publish',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
        '--no-await',
        for (final input in inputs) ...['--platforms', input],
      ]);

      final platforms = verify(
        () => client.appBuilds.createBuilds(
          appIdentifiers: any(named: 'appIdentifiers'),
          cloudCapsuleId: _projectId,
          platforms: captureAny(named: 'platforms'),
          flutterAppDir: any(named: 'flutterAppDir'),
          archiveSize: any(named: 'archiveSize'),
          flutterVersion: any(named: 'flutterVersion'),
          versionName: any(named: 'versionName'),
          commitHash: any(named: 'commitHash'),
          commitMessage: any(named: 'commitMessage'),
          branch: any(named: 'branch'),
        ),
      ).captured.single;
      expect(platforms, expected);
    });
  }

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
          ProjectFactory.flutterAndroidDir(),
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
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: _projectId,
            platforms: [AppPlatform.android],
            flutterAppDir: 'project_flutter',
            archiveSize: captureAny(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).captured.single;
        expect(archiveSize, fileUploader.uploads.single.data.length);
      });

      test(
        "then the Flutter version the app's pubspec requires is sent",
        () async {
          await commandResult;

          expect(_sentFlutterVersion(client), '3.29.0');
        },
      );

      test('then no version name is sent', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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

      test('then the Android package name is shown', () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          contains('Android package name: com.acme.app'),
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
          contains(
            matches(
              RegExp(r'^Follow it: \S+ app show \S+ --project my-project-id$'),
            ),
          ),
        );
      });

      test('then no .scloudignore is written in the app package', () async {
        await commandResult;

        await expectLater(
          d.dir('monorepo', [
            d.dir('project_flutter', [d.nothing('.scloudignore')]),
          ]).validate(),
          completes,
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
          contains(
            matches(
              RegExp(r'^Follow it: \S+ app show \S+ --project my-project-id$'),
            ),
          ),
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

    group('and an Android package name set in scloud.yaml '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appIdentifiers:
    android: "com.acme.configured"
'''),
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

      test('then the configured package name is sent '
          'instead of the one the app declares', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            appIdentifiers: {AppPlatform.android: 'com.acme.configured'},
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });
    });

    group('when releasing the app with --flutter-version', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--flutter-version',
          '3.38.4',
          '--no-await',
        ]);
      });

      test('then the Flutter version is sent', () async {
        await commandResult;

        expect(_sentFlutterVersion(client), '3.38.4');
      });

      test('then the Flutter version is shown', () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          contains('Flutter version: 3.38.4'),
        );
      });
    });

    group('and a Flutter version set in scloud.yaml '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  flutterSdk: "3.38.3"
'''),
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

      test('then the configured Flutter version is sent', () async {
        await commandResult;

        expect(_sentFlutterVersion(client), '3.38.3');
      });
    });

    group('and a Flutter version pinned in .tool-versions at the workspace '
        'root when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.file('.tool-versions', 'flutter 3.38.1-stable\n'),
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

      test('then the pinned Flutter version is sent', () async {
        await commandResult;

        expect(_sentFlutterVersion(client), '3.38.1');
      });
    });

    group('and a Flutter SDK range in the pubspec of the app '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_flutter', [
            d.file(
              'pubspec.yaml',
              ProjectFactory.serverpodFlutterAppPubspec(
                withFlutterConstraint: '">=3.29.0"',
              ),
            ),
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

      test('then no Flutter version is sent', () async {
        await commandResult;

        expect(_sentFlutterVersion(client), isNull);
      });
    });

    group('and a pubspec.lock that cannot be parsed '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [d.file('pubspec.lock', 'sdks: [')]).create();

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

      test('then the lockfile failure is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls.map((call) => call.message),
          contains(startsWith('Failed to parse pubspec.lock')),
        );
      });

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        _verifyNoBuildRequested(client);
      });
    });

    group('when releasing the app with an invalid --flutter-version', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--flutter-version',
          '^3.38.0',
          '--no-await',
        ]);
      });

      test('then the invalid version is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'Unsupported Flutter version "^3.38.0" '
                  '(from --flutter-version flag).',
              hint: 'Use a Flutter release version such as 3.38.4.',
            ),
          ),
        );
      });

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        _verifyNoBuildRequested(client);
      });
    });

    group('when releasing the app with a --flutter-version below the '
        "Flutter SDK constraint of the app's packages", () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'publish',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--flutter-version',
          '3.27.0',
          '--no-await',
        ]);
      });

      test('then the version and the constraint are logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'The Flutter version 3.27.0 (from --flutter-version flag) '
                  'is below the Flutter SDK constraint "3.29.0" of the '
                  "app's packages (from pubspec.lock).",
              hint:
                  'Request Flutter 3.29.0 or later, or change the Flutter '
                  'SDK constraints of the app.',
            ),
          ),
        );
      });

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        _verifyNoBuildRequested(client);
      });
    });

    group('and an Android package name set in scloud.yaml '
        'and an Android app module that takes it from a variable '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appIdentifiers:
    android: "com.acme.configured"
'''),
          ]),
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [
                d.file(
                  'build.gradle.kts',
                  r'android { defaultConfig { applicationId = "${appId}" } }',
                ),
              ]),
            ]),
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

      test('then the app is published', () async {
        await expectLater(commandResult, completes);
      });
    });

    group('and iOS code and an iOS bundle ID set in scloud.yaml '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appIdentifiers:
    ios: "com.acme.configured"
'''),
          ]),
          d.dir('project_flutter', [ProjectFactory.flutterIosDir()]),
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

      test('then the configured bundle ID is sent with the package name '
          'the app declares', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            appIdentifiers: {
              AppPlatform.android: 'com.acme.app',
              AppPlatform.ios: 'com.acme.configured',
            },
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });
    });

    group('and an iOS bundle ID set in scloud.yaml for an app without iOS '
        'code when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appIdentifiers:
    ios: "com.acme.configured"
'''),
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

      test('then only the Android package name is sent', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            appIdentifiers: {AppPlatform.android: 'com.acme.app'},
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });
    });

    group('and an Android package name set in scloud.yaml '
        'when releasing the app with --app-dir', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appIdentifiers:
    android: "com.acme.configured"
'''),
          ]),
        ]).create();

        commandResult = cli.run([
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
      });

      test('then the configured package name is sent', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            appIdentifiers: {AppPlatform.android: 'com.acme.configured'},
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });
    });

    group('and an incomplete publishing setup', () {
      setUp(() {
        when(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).thenThrow(
          AppPlatformNotSetUpException(
            message:
                'The publishing setup is incomplete. Finish the setup under '
                'App stores in the Serverpod Cloud console.',
          ),
        );
      });

      group('and Google Play access without an upload keystore '
          'when releasing the app', () {
        late Future<void> commandResult;

        setUp(() {
          _stubSetup(
            client,
            AppPublishingSetupBuilder().withGooglePlayAccess().build(),
          );
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

        test('then the missing keystore is logged '
            'with a link to the Google Play setup guide', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    "Android isn't set up yet: it needs an upload keystore. "
                    'Finish it here:\n${_googlePlaySetupUrl()}',
              ),
            ),
          );
        });

        test('then nothing is uploaded', () async {
          await commandResult.catchError((_) {});

          expect(fileUploader.uploads, isEmpty);
        });
      });

      group('and only an upload keystore, with Google Play access still being '
          'created, when releasing the app', () {
        late Future<void> commandResult;

        setUp(() {
          _stubSetup(
            client,
            AppPublishingSetupBuilder()
                .withNothingSetUp()
                .withAndroidKeystore()
                .build(),
          );
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

        test('then only the pending Android access is logged, '
            'without a link', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    "Android isn't set up yet: Serverpod Cloud is still "
                    'creating Google Play access for the project. This needs '
                    'nothing from you. Publish again once it is ready.',
              ),
            ),
          );
        });
      });

      group('and neither an upload keystore nor Google Play access '
          'when releasing the app', () {
        late Future<void> commandResult;

        setUp(() {
          _stubSetup(client, AppPublishingSetupBuilder().build());
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

        test('then both are logged '
            'with a link to the Google Play setup guide', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    "Android isn't set up yet: it needs an upload keystore, "
                    'and Serverpod Cloud is still creating Google Play access '
                    'for the project. Finish it here:\n${_googlePlaySetupUrl()}',
              ),
            ),
          );
        });
      });

      group('and a publishing setup with no gap when releasing the app', () {
        late Future<void> commandResult;

        setUp(() {
          _stubSetup(
            client,
            AppPublishingSetupBuilder()
                .withGooglePlayAccess()
                .withAndroidKeystore()
                .build(),
          );
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

        test('then the platform is logged '
            'with a link to its setup guide', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    "Android isn't set up yet. "
                    'Finish it here:\n${_googlePlaySetupUrl()}',
              ),
            ),
          );
        });
      });

      group('and a publishing setup that cannot be read '
          'when releasing the app', () {
        late Future<void> commandResult;

        setUp(() {
          when(
            () => client.appPublishing.getSetup(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenThrow(Exception('Connection lost'));
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

        test('then the platform is logged '
            'with a link to its setup guide', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    "Android isn't set up yet. "
                    'Finish it here:\n${_googlePlaySetupUrl()}',
              ),
            ),
          );
        });
      });

      group('and an iOS app without an App Store Connect key '
          'when releasing the iOS app', () {
        late Future<void> commandResult;

        setUp(() async {
          await d.dir('monorepo', [
            d.dir('project_flutter', [ProjectFactory.flutterIosDir()]),
          ]).create();
          _stubSetup(
            client,
            AppPublishingSetupBuilder().withIosStore(null).build(),
          );
          commandResult = cli.run([
            'app',
            'publish',
            '--project',
            _projectId,
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
            '--no-await',
            '--platforms',
            'ios',
          ]);
        });

        test('then the missing key is logged '
            'with a link to the App Store setup guide', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    "iOS isn't set up yet: it needs an App Store Connect key. "
                    'Finish it here:\n'
                    '${getConsoleBaseUrl()}/project/$_projectId'
                    '/app-stores/appStore?setup=appStore',
              ),
            ),
          );
        });
      });

      group('and iOS set up but no upload keystore '
          'when releasing the iOS and Android apps', () {
        late Future<void> commandResult;

        setUp(() async {
          await d.dir('monorepo', [
            d.dir('project_flutter', [ProjectFactory.flutterIosDir()]),
          ]).create();
          _stubSetup(
            client,
            AppPublishingSetupBuilder().withGooglePlayAccess().build(),
          );
          commandResult = cli.run([
            'app',
            'publish',
            '--project',
            _projectId,
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
            '--no-await',
            '--platforms',
            'ios,android',
          ]);
        });

        test('then only the Android setup is logged', () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls.single.message,
            "Android isn't set up yet: it needs an upload keystore. "
            'Finish it here:\n${_googlePlaySetupUrl()}',
          );
        });
      });
    });

    group('and a plan whose app builds for the month are used '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).thenThrow(
          AppBuildAllowanceExceededException(
            message:
                'All 5 app builds the plan allows this month are used. The '
                'allowance resets on 2026-12-01 (UTC).',
          ),
        );

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

      test('then the used allowance is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'All 5 app builds the plan allows this month are used. '
                  'The allowance resets on 2026-12-01 (UTC).',
            ),
          ),
        );
      });
    });

    group('and an Android app module without an applicationId '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [d.file('build.gradle.kts', 'android {}')]),
            ]),
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

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the missing package name is logged with a hint', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'The Android package name was not found: '
                  'android/app/build.gradle.kts sets no applicationId.',
              hint:
                  'Set applicationId for the app in '
                  'android/app/build.gradle.kts, or set '
                  'project.appIdentifiers.android in scloud.yaml.',
            ),
          ),
        );
      });

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        );
      });
    });

    group("and Flutter's placeholder package name in the app module "
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_flutter', [
            ProjectFactory.flutterAndroidDir(
              applicationId: 'com.example.project_flutter',
            ),
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

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the placeholder is logged with the file to change', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message:
                  'The Android package name com.example.project_flutter is '
                  "Flutter's placeholder: android/app/build.gradle.kts sets "
                  'applicationId to it.',
              hint:
                  'Set applicationId in android/app/build.gradle.kts to the '
                  "app's own Android package name, or set "
                  'project.appIdentifiers.android in scloud.yaml.',
            ),
          ),
        );
      });

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        );
      });
    });

    group("and Flutter's placeholder package name set in scloud.yaml "
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "$_projectId"
  appIdentifiers:
    android: "com.example.app"
'''),
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

      test(
        'then the placeholder is logged with the setting to change',
        () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls,
            contains(
              equalsErrorCall(
                message:
                    'The Android package name com.example.app is '
                    "Flutter's placeholder: scloud.yaml sets "
                    'project.appIdentifiers.android to it.',
                hint:
                    'Set project.appIdentifiers.android in scloud.yaml to the '
                    "app's own Android package name.",
              ),
            ),
          );
        },
      );

      test('then no build is requested', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        );
      });
    });

    group('and an Android app module without an applicationId '
        'and a scloud.yml configuration file when releasing the app', () {
      late Future<void> commandResult;

      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yml', '''
project:
  projectId: "$_projectId"
'''),
          ]),
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [d.file('build.gradle.kts', 'android {}')]),
            ]),
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

      test(
        'then the hint names the configuration file that was read',
        () async {
          await commandResult.catchError((_) {});

          expect(
            logger.errorCalls.map((call) => call.hint),
            contains(
              'Set applicationId for the app in android/app/build.gradle.kts, '
              'or set project.appIdentifiers.android in scloud.yml.',
            ),
          );
        },
      );
    });

    group('and a package name the server refuses when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).thenThrow(
          InvalidValueException(
            message: 'The Android package name "com.acme.app" is not valid.',
          ),
        );

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

      test('then the refusal is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls.map((call) => call.message),
          contains('The Android package name "com.acme.app" is not valid.'),
        );
      });

      test('then nothing is uploaded', () async {
        await commandResult.catchError((_) {});

        expect(fileUploader.uploads, isEmpty);
      });
    });

    group('and a package name that differs from the recorded one '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).thenAnswer(
          (_) async => AppBuildsUploadBuilder()
              .withPlatforms([AppPlatform.android])
              .withUploadDescription(_appUploadDescription)
              .withAppIdentifierChanges([
                AppIdentifierChange(
                  platform: AppPlatform.android,
                  previous: 'com.acme.old',
                  current: 'com.acme.app',
                ),
              ])
              .build(),
        );

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

      test('then the change is logged as a warning', () async {
        await commandResult;

        expect(
          logger.warningCalls.map((call) => call.message),
          contains(
            'The Android package name of the project changed from '
            '"com.acme.old" to "com.acme.app".',
          ),
        );
      });

      test('then the archive is uploaded', () async {
        await commandResult;

        expect(fileUploader.uploads, hasLength(1));
      });
    });

    group('and a server that reports no app identifier changes '
        'when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).thenAnswer(
          (_) async => AppBuildsUploadBuilder()
              .withPlatforms([AppPlatform.android])
              .withUploadDescription(_appUploadDescription)
              .withAppIdentifierChanges(null)
              .build(),
        );

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

      test('then no warning is logged', () async {
        await commandResult;

        expect(logger.warningCalls, isEmpty);
      });

      test('then the archive is uploaded', () async {
        await commandResult;

        expect(fileUploader.uploads, hasLength(1));
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
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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
          appIdentifiers: any(named: 'appIdentifiers'),
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platforms: any(named: 'platforms'),
          flutterAppDir: any(named: 'flutterAppDir'),
          archiveSize: any(named: 'archiveSize'),
          flutterVersion: any(named: 'flutterVersion'),
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
          d.dir('project_flutter', [ProjectFactory.flutterIosDir()]),
        ]).create();

        final platformOfBuild = <UuidValue, AppPlatform>{};
        when(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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
            ProjectFactory.flutterIosDir(bundleId: 'com.acme.ios'),
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
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: _projectId,
            platforms: [AppPlatform.android, AppPlatform.ios],
            flutterAppDir: 'project_flutter',
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        ).called(1);
      });

      test('then the app identifier of each platform is sent', () async {
        await commandResult;

        verify(
          () => client.appBuilds.createBuilds(
            appIdentifiers: {
              AppPlatform.android: 'com.acme.app',
              AppPlatform.ios: 'com.acme.ios',
            },
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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
              'Invalid platform "linux". Supported platforms: android, ios.',
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
              'Invalid platform "fuchsia". Supported platforms: android, ios.',
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

  test(
    'Given --app-dir points to a Dart package '
    'when publishing then the error names the invalid app directory',
    () async {
      await d.dir('plain_package', [
        d.file(
          'pubspec.yaml',
          'name: plain_package\nenvironment:\n  sdk: ^3.10.0\n',
        ),
      ]).create();
      final appDirectory = p.join(d.sandbox, 'plain_package');

      await expectLater(
        cli.run(['app', 'publish', _projectId, '--app-dir', appDirectory]),
        throwsA(isA<ErrorExitException>()),
      );

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message: 'The directory $appDirectory is not a Flutter app.',
            hint: 'Select a Flutter app with --app-dir.',
          ),
        ),
      );
      expect(fileUploader.uploads, isEmpty);
    },
  );

  group('Given a non-workspace Flutter app with Android code', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          d.dir('lib', [d.file('main.dart', 'void main() {}')]),
          ProjectFactory.flutterAndroidDir(),
        ],
      ).create();
    });

    test('when publishing from the app directory '
        'then --app-dir is not required', () async {
      pushCurrentDirectory(p.join(d.sandbox, 'project_flutter'));

      await cli.run(['app', 'publish', _projectId, '--no-await']);

      expect(fileUploader.uploads, hasLength(1));
    }, tags: ['concurrency_one']);

    test(
      'when previewing the upload with --wet-run and --output '
      'then the archive is saved without requesting builds or uploading',
      () async {
        final outputPath = p.join(d.sandbox, 'app.zip');

        await cli.run([
          'app',
          'publish',
          _projectId,
          '--app-dir',
          p.join(d.sandbox, 'project_flutter'),
          '--wet-run',
          '--show-files',
          '--output',
          outputPath,
        ]);

        expect(fileUploader.uploads, isEmpty);
        verifyNever(
          () => client.appBuilds.createBuilds(
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
            versionName: any(named: 'versionName'),
            commitHash: any(named: 'commitHash'),
            commitMessage: any(named: 'commitMessage'),
            branch: any(named: 'branch'),
          ),
        );
        final archive = ZipDecoder().decodeBytes(
          await File(outputPath).readAsBytes(),
        );
        expect(archive.findFile('pubspec.yaml'), isNotNull);
        expect(
          logger.successCalls.map((call) => call.message),
          contains('Wet run complete. No app was uploaded or builds started.'),
        );
      },
    );

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
          appIdentifiers: any(named: 'appIdentifiers'),
          cloudCapsuleId: _projectId,
          platforms: [AppPlatform.android],
          flutterAppDir: '.',
          archiveSize: any(named: 'archiveSize'),
          flutterVersion: any(named: 'flutterVersion'),
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
            appIdentifiers: any(named: 'appIdentifiers'),
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            platforms: any(named: 'platforms'),
            flutterAppDir: any(named: 'flutterAppDir'),
            archiveSize: any(named: 'archiveSize'),
            flutterVersion: any(named: 'flutterVersion'),
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
          appIdentifiers: any(named: 'appIdentifiers'),
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platforms: any(named: 'platforms'),
          flutterAppDir: any(named: 'flutterAppDir'),
          archiveSize: any(named: 'archiveSize'),
          flutterVersion: any(named: 'flutterVersion'),
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
      contents: [ProjectFactory.flutterAndroidDir()],
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

String? _sentFlutterVersion(ClientMock client) {
  return verify(
        () => client.appBuilds.createBuilds(
          appIdentifiers: any(named: 'appIdentifiers'),
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platforms: any(named: 'platforms'),
          flutterAppDir: any(named: 'flutterAppDir'),
          archiveSize: any(named: 'archiveSize'),
          flutterVersion: captureAny(named: 'flutterVersion'),
          versionName: any(named: 'versionName'),
          commitHash: any(named: 'commitHash'),
          commitMessage: any(named: 'commitMessage'),
          branch: any(named: 'branch'),
        ),
      ).captured.single
      as String?;
}

void _verifyNoBuildRequested(ClientMock client) {
  verifyNever(
    () => client.appBuilds.createBuilds(
      appIdentifiers: any(named: 'appIdentifiers'),
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      platforms: any(named: 'platforms'),
      flutterAppDir: any(named: 'flutterAppDir'),
      archiveSize: any(named: 'archiveSize'),
      flutterVersion: any(named: 'flutterVersion'),
      versionName: any(named: 'versionName'),
      commitHash: any(named: 'commitHash'),
      commitMessage: any(named: 'commitMessage'),
      branch: any(named: 'branch'),
    ),
  );
}

/// The console URL of the Google Play setup guide of the test project.
String _googlePlaySetupUrl() =>
    '${getConsoleBaseUrl()}/project/$_projectId'
    '/app-stores/googlePlay?setup=googlePlay';

void _stubSetup(ClientMock client, AppPublishingSetup setup) {
  when(
    () => client.appPublishing.getSetup(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer((_) async => setup);
}

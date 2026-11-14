import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

import '../../../test/util/inline_tui/helpers/fake_terminal.dart';
import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
final _uploadId = const Uuid().v4obj();

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

  setUpAll(() {
    registerFallbackValue(const Uuid().v4obj());
  });

  tearDown(() {
    logger.clear();
    reset(client.appBuilds);
  });

  test('Given app show command when instantiated then requires login', () {
    expect(CloudAppShowCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given an upload with a running Android build that then succeeds '
      'when showing the upload', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.running)
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
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
      logger.inlineTerminal = FakeTerminal(hasTerminal: false);

      commandResult = cli.run([
        'app',
        'show',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);
    });

    test('then the command completes', () async {
      await expectLater(commandResult, completes);
    });

    test('then the builds of the upload are fetched in the project', () async {
      await commandResult;

      verify(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).called(1);
    });

    test('then the build is followed', () async {
      await commandResult;

      verify(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: _projectId,
          buildId: build.id,
        ),
      ).called(1);
    });

    test(
      'then the stage lines are not preceded by a publishing line',
      () async {
        await commandResult;

        expect(
          logger.infoCalls.map((call) => call.message),
          isNot(contains(startsWith('Publishing '))),
        );
      },
    );

    test('then each stage is printed as it starts and as it ends', () async {
      await commandResult;

      expect(logger.lineCalls.map((call) => call.line), [
        'Android build queuing...',
        startsWith('✓ Android build queued.'),
        'Android build preparing...',
        startsWith('✓ Android build prepared.'),
        startsWith('✓ Android build built.'),
        startsWith('✓ Android build uploaded.'),
      ]);
    });

    test('then the upload is reported as published', () async {
      await commandResult;

      expect(
        logger.successCalls,
        contains(
          equalsSuccessCall(
            message: 'Uploaded the app to Google Play.',
            newParagraph: true,
          ),
        ),
      );
    });
  });

  group('Given an upload whose Android and iOS builds have succeeded '
      'when showing the upload', () {
    final android = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.succeeded)
        .build();
    final ios = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.ios)
        .withStatus(AppBuildStatus.succeeded)
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios, android]);
      when(
        () => client.appBuilds.getBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer((invocation) async {
        final buildId = invocation.namedArguments[#buildId] as UuidValue;
        return AppBuildDetailBuilder()
            .withBuild(buildId == ios.id ? ios : android)
            .build();
      });

      commandResult = cli.run([
        'app',
        'show',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);
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

    test('then the stage lines of each build are printed', () async {
      await commandResult;

      expect(logger.lineCalls.map((call) => call.line), [
        startsWith('✓ iOS build queued.'),
        startsWith('✓ iOS build prepared.'),
        startsWith('✓ iOS build built.'),
        startsWith('✓ iOS build uploaded.'),
        startsWith('✓ Android build queued.'),
        startsWith('✓ Android build prepared.'),
        startsWith('✓ Android build built.'),
        startsWith('✓ Android build uploaded.'),
      ]);
    });

    test('then the upload is reported as published', () async {
      await commandResult;

      expect(
        logger.successCalls,
        contains(
          equalsSuccessCall(
            message: 'Uploaded the app to TestFlight and Google Play.',
            newParagraph: true,
          ),
        ),
      );
    });
  });

  group('Given an upload whose Android build has failed '
      'when showing the upload', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.failed)
        .withMessage('Gradle task assembleRelease failed.')
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.getBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) async => AppBuildDetailBuilder().withBuild(build).build(),
      );

      commandResult = cli.run([
        'app',
        'show',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the failed stage is printed', () async {
      await commandResult.catchError((_) {});

      expect(logger.lineCalls.map((call) => call.line), [
        startsWith('✓ Android build queued.'),
        startsWith('✓ Android build prepared.'),
        startsWith('✗ Android build failed while building.'),
      ]);
    });

    test('then the failure points to the build log', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message:
                'The Android build failed. Find out why in the logs: '
                'scloud app log ${build.uploadId} '
                '--platform android --project $_projectId',
          ),
        ),
      );
    });
  });

  test(
    'Given a publish with an uploaded iOS build and refused Android build '
    'when showing it then the success and failure are both reported',
    () async {
      final ios = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.ios)
          .build();
      final android = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.android)
          .withStatus(AppBuildStatus.failed)
          .build();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [ios, android]);
      for (final build in [ios, android]) {
        when(
          () => client.appBuilds.getBuild(
            cloudCapsuleId: _projectId,
            buildId: build.id,
          ),
        ).thenAnswer(
          (_) async => AppBuildDetailBuilder().withBuild(build).build(),
        );
      }

      await expectLater(
        cli.run(['app', 'show', _uploadId.uuid, '--project', _projectId]),
        throwsA(isA<ErrorExitException>()),
      );

      expect(
        logger.successCalls.map((call) => call.message),
        contains('Uploaded the app to TestFlight.'),
      );
      expect(
        logger.errorCalls.map((call) => call.message),
        contains(
          'The Android build failed. Find out why in the logs: '
          'scloud app log ${android.uploadId} '
          '--platform android --project $_projectId',
        ),
      );
    },
  );

  test('Given a build that was built but not uploaded '
      'when showing it then the artifacts command is supplied', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.builtNotUploaded)
        .build();
    when(
      () => client.appBuilds.getUploadBuilds(
        cloudCapsuleId: _projectId,
        uploadId: _uploadId,
      ),
    ).thenAnswer((_) async => [build]);
    when(
      () => client.appBuilds.getBuild(
        cloudCapsuleId: _projectId,
        buildId: build.id,
      ),
    ).thenAnswer((_) async => AppBuildDetailBuilder().withBuild(build).build());

    await expectLater(
      cli.run(['app', 'show', _uploadId.uuid, '--project', _projectId]),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.infoCalls.map((call) => call.message),
      contains(
        contains('app artifacts ${build.uploadId} --project $_projectId'),
      ),
    );
  });

  group('Given an upload whose Android build has waited ten minutes for a '
      'build machine and then succeeds', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.waiting)
        .withCreatedAt(DateTime.now().subtract(const Duration(minutes: 10)))
        .build();

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
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
    });

    test('and no interactive terminal '
        'when showing the upload '
        'then a note says the build waits for a machine and continues '
        'when following stops', () async {
      logger.inlineTerminal = FakeTerminal(hasTerminal: false);

      await cli.run(['app', 'show', _uploadId.uuid, '--project', _projectId]);

      expect(logger.infoCalls.map((call) => call.message), [
        'Waiting for a build machine to be ready. This can take a while.',
        'Press Ctrl+C to stop following. '
            'The build continues in Serverpod Cloud.',
      ]);
    });

    test(
      'and an interactive terminal '
      'when showing the upload '
      'then the note shows below the stage lines while the build waits',
      () async {
        await cli.run(['app', 'show', _uploadId.uuid, '--project', _projectId]);

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains('Android build queuing...'),
        );
        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            '\nWaiting for a build machine to be ready. '
            'This can take a while.\n'
            'Press Ctrl+C to stop following. '
            'The build continues in Serverpod Cloud.',
          ),
        );
      },
    );
  });

  group('Given an upload whose Android build keeps waiting for a build '
      'machine when interrupting the follow', () {
    late Future<void> commandResult;

    setUp(() async {
      final build = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.android)
          .withStatus(AppBuildStatus.waiting)
          .build();
      final terminal = FakeTerminal();
      logger.inlineTerminal = terminal;
      final followed = Completer<void>();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer((_) {
        followed.complete();
        return StreamController<AppBuildDetail>().stream;
      });

      commandResult = cli.run([
        'app',
        'show',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);
      await followed.future;
      terminal.sendInterrupt();
    });

    test('then the command throws UserAbortException', () async {
      await expectLater(commandResult, throwsA(isA<UserAbortException>()));
    });

    test('then the build is said to continue', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.infoCalls.map((call) => call.message),
        contains('The app build continues in Serverpod Cloud.'),
      );
    });

    test('then the command to follow the build again is shown', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.terminalCommandCalls.single.command,
        'scloud app show $_uploadId --project $_projectId',
      );
    });
  });

  group('Given an unknown upload when showing the upload', () {
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenThrow(NotFoundException(message: 'App upload not found'));

      commandResult = cli.run([
        'app',
        'show',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the missing upload is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(equalsErrorCall(message: 'App upload not found')),
      );
    });
  });

  group('Given an upload whose ended build is gone '
      'when showing the upload', () {
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [AppBuildSummaryBuilder().build()]);
      when(
        () => client.appBuilds.getBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenThrow(NotFoundException(message: 'App build not found'));

      commandResult = cli.run([
        'app',
        'show',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the missing build is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(equalsErrorCall(message: 'App build not found')),
      );
    });
  });

  test('Given an upload id that is not a UUID '
      'when showing the upload '
      'then throws UsageException', () async {
    final result = cli.run([
      'app',
      'show',
      'not-a-uuid',
      '--project',
      _projectId,
    ]);

    await expectLater(result, throwsA(isA<UsageException>()));
  });
}

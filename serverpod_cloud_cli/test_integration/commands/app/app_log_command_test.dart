import 'dart:convert';

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
import 'package:yaml/yaml.dart';

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

  test('Given app log command when instantiated then requires login', () {
    expect(CloudAppLogCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given an upload with an Android build and a running iOS build '
      'that then succeeds', () {
    final android = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .build();
    final ios = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.ios)
        .withStatus(AppBuildStatus.running)
        .build();

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios, android]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          AppBuildDetailBuilder().withBuild(ios).withSteps([]).build(),
          AppBuildDetailBuilder().withBuild(ios).withSteps([
            AppBuildStepInfoBuilder().withIndex(0).withName('Build').build(),
            AppBuildStepInfoBuilder()
                .withIndex(1)
                .withName('Publishing')
                .withStatus(AppBuildStepStatus.running)
                .build(),
          ]).build(),
          AppBuildDetailBuilder()
              .withBuild(ios.copyWith(status: AppBuildStatus.succeeded))
              .withSteps([
                AppBuildStepInfoBuilder()
                    .withIndex(0)
                    .withName('Build')
                    .build(),
                AppBuildStepInfoBuilder()
                    .withIndex(1)
                    .withName('Publishing')
                    .build(),
              ])
              .build(),
        ]),
      );
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: 0,
        ),
      ).thenAnswer((_) async => 'Running pod install\nBuilt Runner.app\n');
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: 1,
        ),
      ).thenAnswer((_) async => 'Uploaded Runner.ipa\n');
    });

    group('when streaming the iOS build log', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'log',
          _uploadId.uuid,
          '--platform',
          'ios',
          '--project',
          _projectId,
        ]);
      });

      test('then the command completes', () async {
        await expectLater(commandResult, completes);
      });

      test('then the iOS build of the upload is followed', () async {
        await commandResult;

        verify(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: _projectId,
            buildId: ios.id,
          ),
        ).called(1);
      });

      test('then the log of each step is fetched once', () async {
        await commandResult;

        verify(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: _projectId,
            buildId: ios.id,
            stepIndex: 0,
          ),
        ).called(1);
        verify(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: _projectId,
            buildId: ios.id,
            stepIndex: 1,
          ),
        ).called(1);
      });

      test('then the step logs are printed in run order', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '--- Build (Succeeded) ---',
            'Running pod install',
            'Built Runner.app',
            '--- Publishing (Succeeded) ---',
            'Uploaded Runner.ipa',
          ]),
        );
      });

      test(
        'then a step that ended in several updates is printed once',
        () async {
          await commandResult;

          expect(
            logger.lineCalls.where(
              (call) => call.line == '--- Build (Succeeded) ---',
            ),
            hasLength(1),
          );
        },
      );
    });

    group('when streaming the iOS build log as json', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'log',
          _uploadId.uuid,
          '--platform',
          'ios',
          '--project',
          _projectId,
          '--format',
          'json',
        ]);
      });

      test('then one object is written per step', () async {
        await commandResult;

        final steps = logger.rawCalls
            .map((call) => jsonDecode(call.content) as Map<String, dynamic>)
            .toList();
        expect(steps.map((step) => step['name']), ['Build', 'Publishing']);
        expect(steps.map((step) => step['status']), ['succeeded', 'succeeded']);
        expect(steps.map((step) => step['log']), [
          'Running pod install\nBuilt Runner.app\n',
          'Uploaded Runner.ipa\n',
        ]);
      });

      test('then no text lines are printed', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
      });
    });

    group('when streaming the iOS build log as yaml', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'log',
          _uploadId.uuid,
          '--platform',
          'ios',
          '--project',
          _projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then one document is written per step', () async {
        await commandResult;

        final steps = logger.rawCalls
            .map((call) => loadYaml(call.content) as YamlMap)
            .toList();
        expect(steps.map((step) => step['name']), ['Build', 'Publishing']);
        expect(steps.map((step) => step['status']), ['succeeded', 'succeeded']);
      });
    });

    group('when streaming the Android build log', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'log',
          _uploadId.uuid,
          '--platform',
          'android',
          '--project',
          _projectId,
        ]);
      });

      test('then the Android build of the upload is followed', () async {
        await commandResult;

        verify(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: _projectId,
            buildId: android.id,
          ),
        ).called(1);
      });
    });
  });

  group('Given an iOS build with a skipped step '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppBuildDetailBuilder().withBuild(ios).withSteps([
            AppBuildStepInfoBuilder()
                .withName('Publishing')
                .withStatus(AppBuildStepStatus.skipped)
                .build(),
          ]).build(),
        ),
      );

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the log of the skipped step is not fetched', () async {
      await commandResult;

      verifyNever(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: any(named: 'stepIndex'),
        ),
      );
    });

    test('then the skipped step is printed', () async {
      await commandResult;

      expect(
        logger.lineCalls.map((call) => call.line),
        contains('--- Publishing (Skipped) ---'),
      );
    });
  });

  group('Given an upload with only an Android build '
      'when streaming the iOS build log', () {
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer(
        (_) async => [
          AppBuildSummaryBuilder().withPlatform(AppPlatform.android).build(),
        ],
      );

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the missing iOS build is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(message: 'The upload $_uploadId has no iOS build.'),
        ),
      );
    });

    test('then no log lines are printed', () async {
      await commandResult.catchError((_) {});

      expect(logger.lineCalls, isEmpty);
    });
  });

  group('Given an upload that does not exist '
      'when streaming the iOS build log', () {
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
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
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

  group('Given an iOS build whose step log cannot be fetched '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(AppBuildDetailBuilder().withBuild(ios).build()),
      );
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: any(named: 'stepIndex'),
        ),
      ).thenThrow(Exception('Connection refused'));

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the failed fetch is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls.map((call) => call.message),
        contains(
          'Failed to fetch the log of step 0 of the app build ${ios.id}.',
        ),
      );
    });
  });

  group('Given an iOS build whose last step is skipped while the first step '
      'runs when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.ios)
        .withStatus(AppBuildStatus.running)
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          AppBuildDetailBuilder().withBuild(ios).withSteps([
            AppBuildStepInfoBuilder()
                .withIndex(0)
                .withName('Build')
                .withStatus(AppBuildStepStatus.running)
                .build(),
            AppBuildStepInfoBuilder()
                .withIndex(1)
                .withName('Publishing')
                .withStatus(AppBuildStepStatus.skipped)
                .build(),
          ]).build(),
          AppBuildDetailBuilder()
              .withBuild(ios.copyWith(status: AppBuildStatus.succeeded))
              .withSteps([
                AppBuildStepInfoBuilder()
                    .withIndex(0)
                    .withName('Build')
                    .build(),
                AppBuildStepInfoBuilder()
                    .withIndex(1)
                    .withName('Publishing')
                    .withStatus(AppBuildStepStatus.skipped)
                    .build(),
              ])
              .build(),
        ]),
      );
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: 0,
        ),
      ).thenAnswer((_) async => 'Built Runner.app\n');

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the steps are printed in run order', () async {
      await commandResult;

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder([
          '--- Build (Succeeded) ---',
          'Built Runner.app',
          '--- Publishing (Skipped) ---',
        ]),
      );
    });
  });

  group('Given an iOS build that ends while a step still shows running '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.ios)
        .withStatus(AppBuildStatus.running)
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          AppBuildDetailBuilder().withBuild(ios).withSteps([
            AppBuildStepInfoBuilder()
                .withIndex(0)
                .withName('Build')
                .withStatus(AppBuildStepStatus.running)
                .build(),
          ]).build(),
          AppBuildDetailBuilder()
              .withBuild(ios.copyWith(status: AppBuildStatus.failed))
              .withSteps([
                AppBuildStepInfoBuilder()
                    .withIndex(0)
                    .withName('Build')
                    .withStatus(AppBuildStepStatus.running)
                    .build(),
                AppBuildStepInfoBuilder()
                    .withIndex(1)
                    .withName('Publishing')
                    .withStatus(AppBuildStepStatus.failed)
                    .build(),
                AppBuildStepInfoBuilder()
                    .withIndex(2)
                    .withName('Cleanup')
                    .withStatus(AppBuildStepStatus.pending)
                    .withStartedAt(null)
                    .build(),
              ])
              .build(),
        ]),
      );
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: 0,
        ),
      ).thenAnswer((_) async => 'Running pod install\n');
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: 1,
        ),
      ).thenAnswer((_) async => 'Upload rejected\n');

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then every step is printed in run order', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder([
          '--- Build (Running) ---',
          'Running pod install',
          '--- Publishing (Failed) ---',
          'Upload rejected',
          '--- Cleanup (Pending) ---',
        ]),
      );
    });

    test(
      'then the log of the step that never started is not fetched',
      () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appBuilds.getStepLog(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            buildId: any(named: 'buildId'),
            stepIndex: 2,
          ),
        );
      },
    );
  });

  group('Given an iOS build that fails before any step runs '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.ios)
        .withStatus(AppBuildStatus.failed)
        .withMessage('No build machine is available')
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppBuildDetailBuilder().withBuild(ios).withSteps([]).build(),
        ),
      );

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the failure reason is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls.map((call) => call.message),
        contains('The iOS build failed: No build machine is available'),
      );
    });

    test('then no log lines are printed', () async {
      await commandResult.catchError((_) {});

      expect(logger.lineCalls, isEmpty);
    });
  });

  group('Given an iOS build that is cancelled while queued '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.ios)
        .withStatus(AppBuildStatus.cancelled)
        .build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppBuildDetailBuilder().withBuild(ios).withSteps([]).build(),
        ),
      );

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the cancellation is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls.map((call) => call.message),
        contains('The iOS build was cancelled.'),
      );
    });
  });

  group('Given an iOS build that cannot be followed '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer((_) => Stream.error(Exception('Connection refused')));

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the failed follow is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls.map((call) => call.message),
        contains('Failed to follow the app build ${ios.id}.'),
      );
    });
  });

  group('Given an iOS build whose step is gone '
      'when streaming the iOS build log', () {
    final ios = AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build();
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          uploadId: any(named: 'uploadId'),
        ),
      ).thenAnswer((_) async => [ios]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(AppBuildDetailBuilder().withBuild(ios).build()),
      );
      when(
        () => client.appBuilds.getStepLog(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          buildId: any(named: 'buildId'),
          stepIndex: any(named: 'stepIndex'),
        ),
      ).thenThrow(NotFoundException(message: 'App build step not found'));

      commandResult = cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--platform',
        'ios',
        '--project',
        _projectId,
      ]);
    });

    test('then the server message is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(equalsErrorCall(message: 'App build step not found')),
      );
    });
  });
}

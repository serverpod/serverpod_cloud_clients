import 'package:config/config.dart' show UsageException;
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

    test('then the publishing is reported', () async {
      await commandResult;

      expect(
        logger.infoCalls.map((call) => call.message),
        contains('Publishing 1.4.2 to Android'),
      );
    });

    test('then a status line is printed on every change', () async {
      await commandResult;

      expect(logger.lineCalls.map((call) => call.line), [
        'Android  ⠋ Queueing  ● Build     ● Upload → Play internal',
        'Android  ✓ Queued    ⠋ Building  ● Upload → Play internal',
        'Android  ✓ Queued    ✓ Built     ✓ Uploaded → Play internal',
      ]);
    });

    test('then the upload is reported as published', () async {
      await commandResult;

      expect(
        logger.successCalls,
        contains(
          equalsSuccessCall(
            message: 'Published 1.4.2 to Android.',
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

    test('then their final status lines are printed', () async {
      await commandResult;

      expect(logger.lineCalls.map((call) => call.line), [
        'iOS      ✓ Queued    ✓ Built     ✓ Uploaded → TestFlight',
        'Android  ✓ Queued    ✓ Built     ✓ Uploaded → Play internal',
      ]);
    });

    test('then the upload is reported as published', () async {
      await commandResult;

      expect(
        logger.successCalls,
        contains(
          equalsSuccessCall(
            message: 'Published 1.4.2 to iOS and Android.',
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
        'Android  ✓ Queued    ✗ Build     ● Upload → Play internal',
      ]);
    });

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

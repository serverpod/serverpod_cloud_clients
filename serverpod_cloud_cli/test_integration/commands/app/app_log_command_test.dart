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
import '../../../test/util/inline_tui/helpers/fake_terminal.dart';

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

  setUp(() {
    logger.inlineTerminal = FakeTerminal();
  });

  tearDown(() {
    logger.clear();
    reset(client.appBuilds);
  });

  test('Given app log command when instantiated then requires login', () {
    expect(CloudAppLogCommand(logger: logger).requireLogin, isTrue);
  });

  for (final (input, platform) in [
    ('IOS', AppPlatform.ios),
    ('iOs', AppPlatform.ios),
    ('Android', AppPlatform.android),
    (' ANDROID ', AppPlatform.android),
  ]) {
    test('Given platform $input when logging a multi-platform upload '
        'then the $platform build is streamed', () async {
      final ios = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.ios)
          .build();
      final android = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.android)
          .build();
      final selected = platform == AppPlatform.ios ? ios : android;
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [ios, android]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: _projectId,
          buildId: selected.id,
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppBuildDetailBuilder().withBuild(selected).withSteps([]).build(),
        ),
      );

      await cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--project',
        _projectId,
        '--platform',
        input,
      ]);

      verify(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: _projectId,
          buildId: selected.id,
        ),
      ).called(1);
    });
  }

  for (final status in [
    null,
    AppBuildStatus.queued,
    AppBuildStatus.waiting,
    AppBuildStatus.running,
  ]) {
    test(
      'Given a build watch whose last status is $status '
      'when reconnects stop reporting the build then logging fails',
      () async {
        final build = AppBuildSummaryBuilder()
            .withStatus(status ?? AppBuildStatus.running)
            .build();
        when(
          () => client.appBuilds.getUploadBuilds(
            cloudCapsuleId: _projectId,
            uploadId: _uploadId,
          ),
        ).thenAnswer((_) async => [build]);
        var reported = false;
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: _projectId,
            buildId: build.id,
          ),
        ).thenAnswer((_) {
          if (status != null && !reported) {
            reported = true;
            return Stream.value(
              AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
            );
          }
          return const Stream.empty();
        });

        await expectLater(
          cli.run(['app', 'log', _uploadId.uuid, '--project', _projectId]),
          throwsA(isA<ErrorExitException>()),
        );

        expect(
          logger.errorCalls.map((call) => call.message),
          contains(
            status == null
                ? 'The iOS build did not report its status.'
                : 'The iOS build did not finish.',
          ),
        );
      },
    );
  }

  test('Given a queued build without logs when logging with --no-watch '
      'then it prints nothing and exits without following', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.queued)
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
    ).thenAnswer(
      (_) async =>
          AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
    ]);

    expect(logger.lineCalls, isEmpty);
    expect(logger.infoCalls, isEmpty);
    expect((logger.inlineTerminal as FakeTerminal).output, isEmpty);
    verify(
      () => client.appBuilds.getBuild(
        cloudCapsuleId: _projectId,
        buildId: build.id,
      ),
    ).called(1);
    verifyNever(
      () => client.appBuilds.tailBuild(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        buildId: any(named: 'buildId'),
      ),
    );
  });

  test('Given a running build with a skipped step '
      'when logging with --no-watch as text '
      'then the step heading is printed', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.running)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.skipped)
            .build(),
      ]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
    ]);

    expect(logger.lineCalls.map((call) => call.line), [
      '--- Build (Skipped) ---',
    ]);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    );
  });

  test('Given a running build with a skipped step '
      'when logging with --no-watch as json '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.running)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.skipped)
            .build(),
      ]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'json',
    ]);

    final payload = jsonDecode(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'skipped');
    expect(payload['log'], isNull);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    );
  });

  test('Given a running build with a skipped step '
      'when logging with --no-watch as yaml '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.running)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.skipped)
            .build(),
      ]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'yaml',
    ]);

    final payload = loadYaml(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'skipped');
    expect(payload['log'], isNull);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    );
  });

  test('Given a finished build with a skipped step '
      'when logging with --no-watch as text '
      'then the step heading is printed', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.skipped)
            .build(),
      ]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
    ]);

    expect(logger.lineCalls.map((call) => call.line), [
      '--- Build (Skipped) ---',
    ]);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    );
  });

  test('Given a finished build with a skipped step '
      'when logging with --no-watch as json '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.skipped)
            .build(),
      ]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'json',
    ]);

    final payload = jsonDecode(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'skipped');
    expect(payload['log'], isNull);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    );
  });

  test('Given a finished build with a skipped step '
      'when logging with --no-watch as yaml '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.skipped)
            .build(),
      ]).build(),
    );

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'yaml',
    ]);

    final payload = loadYaml(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'skipped');
    expect(payload['log'], isNull);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    );
  });

  test('Given a finished build whose step log was discarded '
      'when logging with --no-watch as text '
      'then the step heading is printed', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => null);

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
    ]);

    expect(logger.lineCalls.map((call) => call.line), [
      '--- Build (Succeeded) ---',
    ]);
  });

  test('Given a finished build whose step log was discarded '
      'when logging with --no-watch as json '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => null);

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'json',
    ]);

    final payload = jsonDecode(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'succeeded');
    expect(payload['log'], isNull);
  });

  test('Given a finished build whose step log was discarded '
      'when logging with --no-watch as yaml '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => null);

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'yaml',
    ]);

    final payload = loadYaml(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'succeeded');
    expect(payload['log'], isNull);
  });

  test('Given a finished build whose step log is empty '
      'when logging with --no-watch as text '
      'then the step heading is printed', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => '');

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
    ]);

    expect(logger.lineCalls.map((call) => call.line), [
      '--- Build (Succeeded) ---',
    ]);
  });

  test('Given a finished build whose step log is empty '
      'when logging with --no-watch as json '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => '');

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'json',
    ]);

    final payload = jsonDecode(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'succeeded');
    expect(payload['log'], '');
  });

  test('Given a finished build whose step log is empty '
      'when logging with --no-watch as yaml '
      'then the step is included', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.succeeded)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => '');

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'yaml',
    ]);

    final payload = loadYaml(logger.rawCalls.single.content) as Map;
    expect(payload['status'], 'succeeded');
    expect(payload['log'], '');
  });

  test('Given an ended step followed by a running step '
      'when logging with --no-watch as text '
      'then the ended step log is printed and the command exits', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.running)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
        AppBuildStepInfoBuilder()
            .withIndex(1)
            .withStatus(AppBuildStepStatus.running)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => 'Compiling the app');

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
    ]);

    expect(logger.lineCalls.map((call) => call.line), [
      '--- Build (Succeeded) ---',
      'Compiling the app',
    ]);
    expect(logger.infoCalls, isEmpty);
    expect((logger.inlineTerminal as FakeTerminal).output, isEmpty);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 1,
      ),
    );
    verifyNever(
      () => client.appBuilds.tailBuild(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        buildId: any(named: 'buildId'),
      ),
    );
  });

  test('Given an ended step followed by a running step '
      'when logging with --no-watch as json '
      'then the ended step log is printed and the command exits', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.running)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
        AppBuildStepInfoBuilder()
            .withIndex(1)
            .withStatus(AppBuildStepStatus.running)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => 'Compiling the app');

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'json',
    ]);

    final payload = jsonDecode(logger.rawCalls.single.content) as Map;
    expect(payload['log'], 'Compiling the app');
    expect(payload['status'], 'succeeded');
    expect(logger.lineCalls, isEmpty);
    expect(logger.infoCalls, isEmpty);
    expect((logger.inlineTerminal as FakeTerminal).output, isEmpty);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 1,
      ),
    );
    verifyNever(
      () => client.appBuilds.tailBuild(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        buildId: any(named: 'buildId'),
      ),
    );
  });

  test('Given an ended step followed by a running step '
      'when logging with --no-watch as yaml '
      'then the ended step log is printed and the command exits', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.running)
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
    ).thenAnswer(
      (_) async => AppBuildDetailBuilder().withBuild(build).withSteps([
        AppBuildStepInfoBuilder()
            .withStatus(AppBuildStepStatus.succeeded)
            .build(),
        AppBuildStepInfoBuilder()
            .withIndex(1)
            .withStatus(AppBuildStepStatus.running)
            .build(),
      ]).build(),
    );
    when(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 0,
      ),
    ).thenAnswer((_) async => 'Compiling the app');

    await cli.run([
      'app',
      'log',
      _uploadId.uuid,
      '--project',
      _projectId,
      '--no-watch',
      '--format',
      'yaml',
    ]);

    final payload = loadYaml(logger.rawCalls.single.content) as Map;
    expect(payload['log'], 'Compiling the app');
    expect(payload['status'], 'succeeded');
    expect(logger.lineCalls, isEmpty);
    expect(logger.infoCalls, isEmpty);
    expect((logger.inlineTerminal as FakeTerminal).output, isEmpty);
    verifyNever(
      () => client.appBuilds.getStepLog(
        cloudCapsuleId: _projectId,
        buildId: build.id,
        stepIndex: 1,
      ),
    );
    verifyNever(
      () => client.appBuilds.tailBuild(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        buildId: any(named: 'buildId'),
      ),
    );
  });

  test('Given a failed build when logging with --no-watch '
      'then its failure is still reported', () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.failed)
        .withMessage('Compilation failed')
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
    ).thenAnswer(
      (_) async =>
          AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
    );

    await expectLater(
      cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--project',
        _projectId,
        '--no-watch',
      ]),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.map((call) => call.message),
      contains('The iOS build failed.'),
    );
  });

  test('Given a build that failed because the Apple team has no room for '
      'another certificate when logging with --no-watch '
      'then the failure names the certificate limit and links to '
      "Apple's certificates page", () async {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.failed)
        .withFailureReason(AppBuildFailureReason.signingCertificateLimitReached)
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
    ).thenAnswer(
      (_) async =>
          AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
    );

    await expectLater(
      cli.run([
        'app',
        'log',
        _uploadId.uuid,
        '--project',
        _projectId,
        '--no-watch',
      ]),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.map((call) => call.message),
      contains(
        allOf(
          startsWith(
            'The iOS build failed. '
            'Apple has no room for another certificate.\n',
          ),
          endsWith(
            '\nOpen Certificates: '
            'https://developer.apple.com/account/resources/certificates/list',
          ),
        ),
      ),
    );
  });

  test('Given redirected output when watching logs '
      'then no terminal indicator or banner is written', () async {
    final terminal = FakeTerminal(hasTerminal: false);
    logger.inlineTerminal = terminal;
    final build = AppBuildSummaryBuilder().build();
    when(
      () => client.appBuilds.getUploadBuilds(
        cloudCapsuleId: _projectId,
        uploadId: _uploadId,
      ),
    ).thenAnswer((_) async => [build]);
    when(
      () => client.appBuilds.tailBuild(
        cloudCapsuleId: _projectId,
        buildId: build.id,
      ),
    ).thenAnswer(
      (_) => Stream.value(
        AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
      ),
    );

    await cli.run(['app', 'log', _uploadId.uuid, '--project', _projectId]);

    expect(terminal.output, isEmpty);
    expect(logger.infoCalls, isEmpty);
  });

  for (final fails in [false, true]) {
    test(
      'Given an interactive terminal when watching logs '
      'then the waiting indicator is cleared when the stream ${fails ? 'fails' : 'ends'}',
      () async {
        final build = AppBuildSummaryBuilder().build();
        when(
          () => client.appBuilds.getUploadBuilds(
            cloudCapsuleId: _projectId,
            uploadId: _uploadId,
          ),
        ).thenAnswer((_) async => [build]);
        when(
          () => client.appBuilds.tailBuild(
            cloudCapsuleId: _projectId,
            buildId: build.id,
          ),
        ).thenAnswer(
          (_) => fails
              ? Stream.error(Exception('Unavailable'))
              : Stream.value(
                  AppBuildDetailBuilder()
                      .withBuild(build)
                      .withSteps([])
                      .build(),
                ),
        );

        final result = cli.run([
          'app',
          'log',
          _uploadId.uuid,
          '--project',
          _projectId,
          '--watch',
        ]);
        if (fails) {
          await expectLater(result, throwsA(isA<ErrorExitException>()));
        } else {
          await result;
        }

        final terminal = logger.inlineTerminal as FakeTerminal;
        expect(terminal.output, contains('Waiting for build logs'));
        expect(terminal.output, endsWith('\x1b[0J'));
      },
    );
  }

  for (final platform in AppPlatform.values) {
    test('Given a $platform-only upload when logging without --platform '
        'then its build is streamed', () async {
      final build = AppBuildSummaryBuilder().withPlatform(platform).build();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: _projectId,
          buildId: build.id,
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppBuildDetailBuilder().withBuild(build).withSteps([]).build(),
        ),
      );

      await cli.run(['app', 'log', _uploadId.uuid, '--project', _projectId]);

      verify(
        () => client.appBuilds.tailBuild(
          cloudCapsuleId: _projectId,
          buildId: build.id,
        ),
      ).called(1);
    });
  }

  test('Given a multi-platform upload when logging without --platform '
      'then the error requests a platform', () async {
    when(
      () => client.appBuilds.getUploadBuilds(
        cloudCapsuleId: _projectId,
        uploadId: _uploadId,
      ),
    ).thenAnswer(
      (_) async => [
        AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build(),
        AppBuildSummaryBuilder().withPlatform(AppPlatform.android).build(),
      ],
    );

    await expectLater(
      cli.run(['app', 'log', _uploadId.uuid, '--project', _projectId]),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls,
      contains(
        equalsErrorCall(
          message: 'The upload $_uploadId has builds for multiple platforms.',
          hint: 'Select a platform with --platform ios or --platform android.',
        ),
      ),
    );
    verifyNever(
      () => client.appBuilds.tailBuild(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        buildId: any(named: 'buildId'),
      ),
    );
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

    test('then the failure is logged without the build message', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls.map((call) => call.message),
        contains('The iOS build failed.'),
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

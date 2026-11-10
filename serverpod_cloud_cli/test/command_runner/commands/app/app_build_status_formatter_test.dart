import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_build_status_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('Given no build detail '
      'when formatting the iOS status line '
      'then the queue stage is active and the others are pending', () {
    expect(
      AppBuildStatusFormatter.line(AppPlatform.ios, null),
      'iOS      ⠋ Queueing  ● Build     ● Upload → TestFlight',
    );
  });

  test('Given a succeeded Android build '
      'when formatting its status line '
      'then every stage is done', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder()
              .withPlatform(AppPlatform.android)
              .withStatus(AppBuildStatus.succeeded)
              .build(),
        )
        .build();

    expect(
      AppBuildStatusFormatter.line(AppPlatform.android, detail),
      'Android  ✓ Queued    ✓ Built     ✓ Uploaded → Play internal',
    );
  });

  test('Given iOS and Android builds in different stages '
      'when formatting their status lines '
      'then their stage columns line up', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder()
              .withPlatform(AppPlatform.android)
              .withStatus(AppBuildStatus.succeeded)
              .build(),
        )
        .build();

    final iosLine = AppBuildStatusFormatter.line(AppPlatform.ios, null);
    final androidLine = AppBuildStatusFormatter.line(
      AppPlatform.android,
      detail,
    );

    expect(iosLine.indexOf('● Build'), androidLine.indexOf('✓ Built'));
    expect(iosLine.indexOf('● Upload'), androidLine.indexOf('✓ Uploaded'));
  });

  test('Given a running build '
      'when formatting its status line at a later spinner frame '
      'then the active stage shows that frame', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.running).build(),
        )
        .withSteps([])
        .build();

    expect(
      AppBuildStatusFormatter.line(AppPlatform.ios, detail, spinnerFrame: 1),
      'iOS      ✓ Queued    ⠙ Building  ● Upload → TestFlight',
    );
  });

  test('Given a waiting build '
      'when getting its stage states '
      'then the queue stage is active', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.waiting).build(),
        )
        .withSteps([])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.active,
      AppBuildStageState.pending,
      AppBuildStageState.pending,
    ]);
  });

  test('Given a running build before its publish stage '
      'when getting its stage states '
      'then the build stage is active', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.running).build(),
        )
        .withSteps([
          AppBuildStepInfo(
            index: 0,
            name: 'Build iOS app',
            stage: AppBuildStage.build,
            status: AppBuildStepStatus.running,
          ),
          AppBuildStepInfo(
            index: 1,
            name: 'Upload to TestFlight',
            stage: AppBuildStage.publish,
            status: AppBuildStepStatus.pending,
          ),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.active,
      AppBuildStageState.pending,
    ]);
  });

  test('Given a running build in its publish stage '
      'when getting its stage states '
      'then the upload stage is active', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.running).build(),
        )
        .withSteps([
          AppBuildStepInfo(
            index: 0,
            name: 'Upload to TestFlight',
            stage: AppBuildStage.publish,
            status: AppBuildStepStatus.running,
          ),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.done,
      AppBuildStageState.active,
    ]);
  });

  test('Given a build that failed before its publish stage '
      'when getting its stage states '
      'then the build stage failed', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.failed).build(),
        )
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.failed,
      AppBuildStageState.pending,
    ]);
  });

  test('Given a build the store refused '
      'when getting its stage states '
      'then the upload stage failed', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder()
              .withStatus(AppBuildStatus.builtNotUploaded)
              .build(),
        )
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.done,
      AppBuildStageState.failed,
    ]);
  });

  test('Given a build the store refused '
      'when getting its error '
      'then it was built but not uploaded, with the message', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withMessage('Step "Publish to Google Play" exited with code 1')
        .build();

    expect(
      AppBuildStatusFormatter.summaryError(AppPlatform.android, build),
      'The Android build was built but not uploaded to the store: '
      'Step "Publish to Google Play" exited with code 1',
    );
  });

  test('Given a build cancelled in the queue '
      'when getting its stage states '
      'then the queue stage failed', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder()
              .withStatus(AppBuildStatus.cancelled)
              .withStartedAt(null)
              .build(),
        )
        .withSteps([])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.failed,
      AppBuildStageState.pending,
      AppBuildStageState.pending,
    ]);
  });

  test('Given two platforms '
      'when naming them '
      'then they are joined in display order', () {
    expect(
      AppBuildStatusFormatter.platformNames([
        AppPlatform.android,
        AppPlatform.ios,
      ]),
      'iOS and Android',
    );
  });

  test('Given a failed step '
      'when heading its log '
      'then the heading names the step and its status', () {
    expect(
      AppBuildStatusFormatter.stepLogHeading(
        AppBuildStepInfoBuilder()
            .withName('Build')
            .withStatus(AppBuildStepStatus.failed)
            .build(),
      ),
      '--- Build (Failed) ---',
    );
  });

  test('Given a step '
      'when heading its log with a platform '
      'then the heading names the platform before the step', () {
    expect(
      AppBuildStatusFormatter.stepLogHeading(
        AppBuildStepInfoBuilder().withName('Build').build(),
        platform: AppPlatform.ios,
      ),
      '--- iOS: Build (Succeeded) ---',
    );
  });
}

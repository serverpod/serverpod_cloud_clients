import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/release/release_build_status.dart';
import 'package:test/test.dart';

void main() {
  test('Given no build detail '
      'when formatting the iOS status line '
      'then the queue stage is active and the others are pending', () {
    expect(
      ReleaseBuildStatus.line(AppPlatform.ios, null),
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
      ReleaseBuildStatus.line(AppPlatform.android, detail),
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

    final iosLine = ReleaseBuildStatus.line(AppPlatform.ios, null);
    final androidLine = ReleaseBuildStatus.line(AppPlatform.android, detail);

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
      ReleaseBuildStatus.line(AppPlatform.ios, detail, spinnerFrame: 1),
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

    expect(ReleaseBuildStatus.stageStates(detail), [
      ReleaseStageState.active,
      ReleaseStageState.pending,
      ReleaseStageState.pending,
    ]);
  });

  test('Given a running build before its publishing step '
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
            status: AppBuildStepStatus.running,
          ),
          AppBuildStepInfo(
            index: 1,
            name: ReleaseBuildStatus.publishingStepName,
            status: AppBuildStepStatus.pending,
          ),
        ])
        .build();

    expect(ReleaseBuildStatus.stageStates(detail), [
      ReleaseStageState.done,
      ReleaseStageState.active,
      ReleaseStageState.pending,
    ]);
  });

  test('Given a running build in its publishing step '
      'when getting its stage states '
      'then the upload stage is active', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.running).build(),
        )
        .withSteps([
          AppBuildStepInfo(
            index: 0,
            name: ReleaseBuildStatus.publishingStepName,
            status: AppBuildStepStatus.running,
          ),
        ])
        .build();

    expect(ReleaseBuildStatus.stageStates(detail), [
      ReleaseStageState.done,
      ReleaseStageState.done,
      ReleaseStageState.active,
    ]);
  });

  test('Given a build that failed before its publishing step '
      'when getting its stage states '
      'then the build stage failed', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.failed).build(),
        )
        .build();

    expect(ReleaseBuildStatus.stageStates(detail), [
      ReleaseStageState.done,
      ReleaseStageState.failed,
      ReleaseStageState.pending,
    ]);
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

    expect(ReleaseBuildStatus.stageStates(detail), [
      ReleaseStageState.failed,
      ReleaseStageState.pending,
      ReleaseStageState.pending,
    ]);
  });

  test('Given two platforms '
      'when naming them '
      'then they are joined in display order', () {
    expect(
      ReleaseBuildStatus.platformNames([AppPlatform.android, AppPlatform.ios]),
      'iOS and Android',
    );
  });
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_build_status_formatter.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_build_step_lines.dart';
import 'package:test/test.dart';

void main() {
  test('Given an Android build without a detail '
      'when getting the active lines '
      'then the build is queuing', () {
    final steps = AppBuildStepLines([AppPlatform.android]);

    expect(steps.activeLines.map((line) => line.text), [
      'Android build queuing...',
    ]);
  });

  group('Given an Android build running a build step', () {
    late AppBuildStepLines steps;
    late List<AppBuildStepLine> ended;

    setUp(() {
      steps = AppBuildStepLines([AppPlatform.android]);
      ended = steps.update(
        AppBuildDetailBuilder()
            .withBuild(
              AppBuildSummaryBuilder()
                  .withPlatform(AppPlatform.android)
                  .withStatus(AppBuildStatus.running)
                  .build(),
            )
            .withSteps([
              AppBuildStepInfoBuilder()
                  .withStage(AppBuildStage.build)
                  .withStatus(AppBuildStepStatus.running)
                  .build(),
            ])
            .build(),
      );
    });

    test('when updating then the queue and prepare stages end, in order', () {
      expect(ended.map((line) => line.text), [
        'Android build queued.',
        'Android build prepared.',
      ]);
    });

    test('when getting the active lines then the build is building', () {
      expect(steps.activeLines.map((line) => line.text), [
        'Android build building...',
      ]);
    });

    test('and then succeeding '
        'when updating '
        'then only the build and upload stages end', () {
      final later = steps.update(
        AppBuildDetailBuilder()
            .withBuild(
              AppBuildSummaryBuilder()
                  .withPlatform(AppPlatform.android)
                  .withStatus(AppBuildStatus.succeeded)
                  .build(),
            )
            .build(),
      );

      expect(later.map((line) => line.text), [
        'Android build built.',
        'Android build uploaded.',
      ]);
    });
  });

  group('Given an Android build that failed in its build stage', () {
    late AppBuildStepLines steps;
    late List<AppBuildStepLine> ended;

    setUp(() {
      steps = AppBuildStepLines([AppPlatform.android]);
      ended = steps.update(
        AppBuildDetailBuilder()
            .withBuild(
              AppBuildSummaryBuilder()
                  .withPlatform(AppPlatform.android)
                  .withStatus(AppBuildStatus.failed)
                  .build(),
            )
            .withSteps([
              AppBuildStepInfoBuilder()
                  .withStage(AppBuildStage.build)
                  .withStatus(AppBuildStepStatus.failed)
                  .build(),
            ])
            .build(),
      );
    });

    test('when updating then the last line is the failed build stage', () {
      expect(ended.map((line) => (line.text, line.state)), [
        ('Android build queued.', AppBuildStageState.done),
        ('Android build prepared.', AppBuildStageState.done),
        ('Android build failed while building.', AppBuildStageState.failed),
      ]);
    });

    test('when getting the active lines then the build has none', () {
      expect(steps.activeLines, isEmpty);
    });
  });

  test('Given iOS and Android builds without a detail '
      'when getting the active lines '
      'then they are in platform order', () {
    final steps = AppBuildStepLines([AppPlatform.ios, AppPlatform.android]);

    expect(steps.activeLines.map((line) => line.text), [
      'iOS build queuing...',
      'Android build queuing...',
    ]);
  });

  test('Given a stage line that ran for a minute '
      'when getting its elapsed time '
      'then it is a minute', () {
    final startedAt = DateTime.utc(2026, 11, 13, 10);
    final line = AppBuildStepLine(
      platform: AppPlatform.ios,
      state: AppBuildStageState.done,
      text: 'iOS build queued.',
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 1)),
    );

    expect(line.elapsed(DateTime.utc(2027)), const Duration(minutes: 1));
  });

  group('Given an Android build that left the queue before any step is '
      'listed', () {
    final createdAt = DateTime.utc(2026, 11, 13, 10);
    final seenAt = createdAt.add(const Duration(minutes: 10));
    late AppBuildStepLines steps;
    late List<AppBuildStepLine> ended;

    setUp(() {
      steps = AppBuildStepLines([AppPlatform.android], clock: () => seenAt);
      ended = steps.update(
        AppBuildDetailBuilder()
            .withBuild(
              AppBuildSummaryBuilder()
                  .withPlatform(AppPlatform.android)
                  .withStatus(AppBuildStatus.running)
                  .withCreatedAt(createdAt)
                  .withStartedAt(createdAt.add(const Duration(seconds: 4)))
                  .withEndedAt(null)
                  .build(),
            )
            .withSteps([])
            .build(),
      );
    });

    test('when updating '
        'then the queue stage lasted until the change was seen', () {
      expect(ended.single.text, 'Android build queued.');
      expect(ended.single.elapsed(seenAt), const Duration(minutes: 10));
    });

    test('when getting the active lines '
        'then the prepare stage started when the change was seen', () {
      expect(steps.activeLines.single.startedAt, seenAt);
    });
  });

  group(
    'Given an Android build waiting for a build machine for two minutes',
    () {
      final createdAt = DateTime.utc(2026, 11, 13, 10);
      late AppBuildStepLines steps;

      setUp(() {
        steps = AppBuildStepLines([
          AppPlatform.android,
        ], clock: () => createdAt.add(const Duration(minutes: 2)));
        steps.update(
          AppBuildDetailBuilder()
              .withBuild(
                AppBuildSummaryBuilder()
                    .withPlatform(AppPlatform.android)
                    .withStatus(AppBuildStatus.waiting)
                    .withCreatedAt(createdAt)
                    .build(),
              )
              .withSteps([])
              .build(),
        );
      });

      test('when getting the builds queued for a minute '
          'then it is the build', () {
        expect(
          steps.queuedFor(const Duration(minutes: 1)).map((b) => b.platform),
          [AppPlatform.android],
        );
      });

      test('when getting the builds queued for three minutes '
          'then there are none', () {
        expect(steps.queuedFor(const Duration(minutes: 3)), isEmpty);
      });
    },
  );

  test('Given an Android build requested two minutes ago that left the queue '
      'when getting the builds queued for a minute '
      'then there are none', () {
    final createdAt = DateTime.utc(2026, 11, 13, 10);
    final steps = AppBuildStepLines([
      AppPlatform.android,
    ], clock: () => createdAt.add(const Duration(minutes: 2)));
    steps.update(
      AppBuildDetailBuilder()
          .withBuild(
            AppBuildSummaryBuilder()
                .withPlatform(AppPlatform.android)
                .withStatus(AppBuildStatus.running)
                .withCreatedAt(createdAt)
                .build(),
          )
          .build(),
    );

    expect(steps.queuedFor(const Duration(minutes: 1)), isEmpty);
  });

  test('Given an Android build without a detail '
      'when getting the builds queued for no time '
      'then there are none', () {
    final steps = AppBuildStepLines([AppPlatform.android]);

    expect(steps.queuedFor(Duration.zero), isEmpty);
  });
}

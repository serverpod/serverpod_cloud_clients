import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_build_status_formatter.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';
import 'package:test/test.dart';

void main() {
  test('Given an active prepare stage '
      'when getting its text '
      'then it says the build is preparing', () {
    expect(
      AppBuildStatusFormatter.stageText(
        AppPlatform.android,
        1,
        AppBuildStageState.active,
      ),
      'Android build preparing...',
    );
  });

  test('Given a done queue stage '
      'when getting its text '
      'then it says the build is queued', () {
    expect(
      AppBuildStatusFormatter.stageText(
        AppPlatform.ios,
        0,
        AppBuildStageState.done,
      ),
      'iOS build queued.',
    );
  });

  test('Given a failed build stage '
      'when getting its text '
      'then it says the build failed while building', () {
    expect(
      AppBuildStatusFormatter.stageText(
        AppPlatform.android,
        2,
        AppBuildStageState.failed,
      ),
      'Android build failed while building.',
    );
  });

  test('Given a failed queue stage of a cancelled build '
      'when getting its text '
      'then it says the build was cancelled while queuing', () {
    expect(
      AppBuildStatusFormatter.stageText(
        AppPlatform.android,
        0,
        AppBuildStageState.failed,
        cancelled: true,
      ),
      'Android build cancelled while queuing.',
    );
  });

  group('Given a build handed to the build service at once that waited ten '
      'minutes for a machine', () {
    final createdAt = DateTime.utc(2026, 11, 13, 10);
    final handedOverAt = createdAt.add(const Duration(seconds: 4));
    final prepareStartedAt = createdAt.add(const Duration(minutes: 10));
    final buildStartedAt = createdAt.add(const Duration(minutes: 12));
    final buildEndedAt = createdAt.add(const Duration(minutes: 20));
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder()
              .withCreatedAt(createdAt)
              .withStartedAt(handedOverAt)
              .withEndedAt(buildEndedAt)
              .build(),
        )
        .withSteps([
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.upload)
              .withStartedAt(prepareStartedAt)
              .withEndedAt(buildStartedAt)
              .build(),
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.build)
              .withStartedAt(buildStartedAt)
              .withEndedAt(buildEndedAt)
              .build(),
        ])
        .build();

    test('when getting the queue stage times '
        'then it runs from the request until the machine starts', () {
      expect(AppBuildStatusFormatter.stageStartedAt(detail, 0), createdAt);
      expect(AppBuildStatusFormatter.stageEndedAt(detail, 0), prepareStartedAt);
    });

    test('when getting the prepare stage times '
        'then they are those of its step', () {
      expect(
        AppBuildStatusFormatter.stageStartedAt(detail, 1),
        prepareStartedAt,
      );
      expect(AppBuildStatusFormatter.stageEndedAt(detail, 1), buildStartedAt);
    });

    test('when getting the build stage times '
        'then they are those of its step', () {
      expect(AppBuildStatusFormatter.stageStartedAt(detail, 2), buildStartedAt);
      expect(AppBuildStatusFormatter.stageEndedAt(detail, 2), buildEndedAt);
    });
  });

  group('Given a build without prepare steps', () {
    final createdAt = DateTime.utc(2026, 11, 13, 10);
    final buildStartedAt = createdAt.add(const Duration(minutes: 3));
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder()
              .withCreatedAt(createdAt)
              .withStartedAt(createdAt.add(const Duration(seconds: 4)))
              .build(),
        )
        .withSteps([
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.build)
              .withStartedAt(buildStartedAt)
              .build(),
        ])
        .build();

    test('when getting the prepare stage times '
        'then it starts and ends when the first build step starts', () {
      expect(AppBuildStatusFormatter.stageStartedAt(detail, 1), buildStartedAt);
      expect(AppBuildStatusFormatter.stageEndedAt(detail, 1), buildStartedAt);
    });
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
      AppBuildStageState.pending,
    ]);
  });

  test('Given a running build in its upload stage '
      'when getting its stage states '
      'then the prepare stage is active', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.running).build(),
        )
        .withSteps([
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.upload)
              .withStatus(AppBuildStepStatus.running)
              .build(),
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.build)
              .withStatus(AppBuildStepStatus.pending)
              .build(),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.active,
      AppBuildStageState.pending,
      AppBuildStageState.pending,
    ]);
  });

  test('Given a build that failed in its upload stage '
      'when getting its stage states '
      'then the prepare stage failed', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.failed).build(),
        )
        .withSteps([
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.upload)
              .withStatus(AppBuildStepStatus.failed)
              .build(),
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.build)
              .withStatus(AppBuildStepStatus.skipped)
              .build(),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.failed,
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
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.build)
              .withStatus(AppBuildStepStatus.running)
              .build(),
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.publish)
              .withStatus(AppBuildStepStatus.pending)
              .build(),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
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
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.publish)
              .withStatus(AppBuildStepStatus.running)
              .build(),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
      AppBuildStageState.done,
      AppBuildStageState.done,
      AppBuildStageState.active,
    ]);
  });

  test('Given a build that failed in its build stage '
      'when getting its stage states '
      'then the build stage failed', () {
    final detail = AppBuildDetailBuilder()
        .withBuild(
          AppBuildSummaryBuilder().withStatus(AppBuildStatus.failed).build(),
        )
        .withSteps([
          AppBuildStepInfoBuilder()
              .withStage(AppBuildStage.build)
              .withStatus(AppBuildStepStatus.failed)
              .build(),
        ])
        .build();

    expect(AppBuildStatusFormatter.stageStates(detail), [
      AppBuildStageState.done,
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
      AppBuildStageState.done,
      AppBuildStageState.failed,
    ]);
  });

  test('Given a build the store refused '
      'when getting its error '
      'then it was built but not uploaded, without the build message', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withMessage('Step "Publish to Google Play" exited with code 1')
        .build();

    expect(
      AppBuildStatusFormatter.summaryError(AppPlatform.android, build),
      'The Android build was built but not uploaded to the store.',
    );
  });

  test('Given a build that failed for an unknown reason '
      'when getting its advice error '
      'then it only says the build failed', () {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.failed)
        .withFailureReason(AppBuildFailureReason.unknown)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.ios,
        build,
        projectId: 'project-id',
        baseCommand: 'scloud',
      ),
      'The iOS build failed.',
    );
  });

  test('Given a build whose API key Apple rejected '
      'when getting its advice error '
      'then it links to the setup guide of the project in the console', () {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.failed)
        .withFailureReason(AppBuildFailureReason.storeKeyRejected)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.ios,
        build,
        projectId: 'project-id',
        baseCommand: 'scloud',
      ),
      endsWith(
        '\nOpen setup: ${getAppStoreSetupUrl('project-id', AppPlatform.ios)}',
      ),
    );
  });

  test('Given a build the store refused as signed for debugging '
      'when getting its advice error '
      'then it names app doctor with the base command', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withFailureReason(AppBuildFailureReason.debugSigned)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.android,
        build,
        projectId: 'project-id',
        baseCommand: 'serverpod cloud',
      ),
      contains('Run serverpod cloud app doctor to see what to change.'),
    );
  });

  test('Given an Android build the store refused for permission '
      'when getting its advice error '
      'then it links to the setup guide of the project in the console', () {
    final build = AppBuildSummaryBuilder()
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withFailureReason(AppBuildFailureReason.storePermissionDenied)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.android,
        build,
        projectId: 'project-id',
        baseCommand: 'scloud',
      ),
      endsWith(
        '\nOpen setup: '
        '${getAppStoreSetupUrl('project-id', AppPlatform.android)}',
      ),
    );
  });

  test('Given an iOS build the store refused for permission '
      'when getting its advice error '
      'then it links to the API keys of App Store Connect', () {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withFailureReason(AppBuildFailureReason.storePermissionDenied)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.ios,
        build,
        projectId: 'project-id',
        baseCommand: 'scloud',
      ),
      endsWith(
        '\nOpen App Store Connect: '
        'https://appstoreconnect.apple.com/access/integrations/api',
      ),
    );
  });

  test('Given an Android build the store has no app for '
      'when getting its advice error '
      'then it ends with the command to download the build', () {
    final build = AppBuildSummaryBuilder()
        .withUploadId(
          UuidValue.fromString('43f78985-c5e5-47c9-8cee-eb028076d670'),
        )
        .withPlatform(AppPlatform.android)
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withFailureReason(AppBuildFailureReason.storeAppNotFound)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.android,
        build,
        projectId: 'project-id',
        baseCommand: 'scloud',
      ),
      endsWith(
        "Later builds upload on their own.\n"
        'Download build: scloud app artifacts '
        '43f78985-c5e5-47c9-8cee-eb028076d670 --project project-id',
      ),
    );
  });

  test('Given an iOS build the store has no app for '
      'when getting its advice error '
      'then it links to the apps of App Store Connect', () {
    final build = AppBuildSummaryBuilder()
        .withStatus(AppBuildStatus.builtNotUploaded)
        .withFailureReason(AppBuildFailureReason.storeAppNotFound)
        .build();

    expect(
      AppBuildStatusFormatter.adviceError(
        AppPlatform.ios,
        build,
        projectId: 'project-id',
        baseCommand: 'scloud',
      ),
      endsWith(
        '\nOpen App Store Connect: https://appstoreconnect.apple.com/apps',
      ),
    );
  });

  group('Given a log command', () {
    const logCommand = 'scloud app log upload-id --platform android';

    test('and a failed build '
        'when getting its follow error '
        'then it points to the log instead of the build message', () {
      final build = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.failed)
          .withMessage('Step 6 script `Build Android app bundle` exited')
          .build();

      expect(
        AppBuildStatusFormatter.followError(
          AppPlatform.android,
          build,
          logCommand: logCommand,
          projectId: 'project-id',
          baseCommand: 'scloud',
        ),
        'The Android build failed. Find out why in the logs: $logCommand',
      );
    });

    test('and a build that failed because the Apple team has no room for '
        'another certificate '
        'when getting its follow error '
        "then it names the certificate limit and links to Apple's "
        'certificates page, then points to the log', () {
      final build = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.failed)
          .withFailureReason(
            AppBuildFailureReason.signingCertificateLimitReached,
          )
          .build();

      expect(
        AppBuildStatusFormatter.followError(
          AppPlatform.ios,
          build,
          logCommand: logCommand,
          projectId: 'project-id',
          baseCommand: 'scloud',
        ),
        'The iOS build failed. Apple has no room for another certificate.\n'
        'Your Apple team already has as many distribution certificates as '
        'Apple allows. Revoke a Distribution certificate no one on your team '
        "still uses, then publish again. If you're not sure, ask your team's "
        'admin before you revoke it. Your apps on the App Store and '
        'TestFlight are not affected.\n'
        'Open Certificates: '
        'https://developer.apple.com/account/resources/certificates/list\n'
        'Read the log: $logCommand',
      );
    });

    test('and a build the store refused '
        'when getting its follow error '
        'then it was built but not uploaded, pointing to the log', () {
      final build = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.builtNotUploaded)
          .build();

      expect(
        AppBuildStatusFormatter.followError(
          AppPlatform.android,
          build,
          logCommand: logCommand,
          projectId: 'project-id',
          baseCommand: 'scloud',
        ),
        'The Android build was built but not uploaded to the store. '
        'Find out why in the logs: $logCommand',
      );
    });

    test('and a running build '
        'when getting its follow error '
        'then it did not finish, pointing to the log', () {
      final build = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.running)
          .build();

      expect(
        AppBuildStatusFormatter.followError(
          AppPlatform.android,
          build,
          logCommand: logCommand,
          projectId: 'project-id',
          baseCommand: 'scloud',
        ),
        'The Android build did not finish. Find out why in the logs: '
        '$logCommand',
      );
    });

    test('and a cancelled build '
        'when getting its follow error '
        'then it was cancelled, without the log', () {
      final build = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.cancelled)
          .build();

      expect(
        AppBuildStatusFormatter.followError(
          AppPlatform.android,
          build,
          logCommand: logCommand,
          projectId: 'project-id',
          baseCommand: 'scloud',
        ),
        'The Android build was cancelled.',
      );
    });

    test('and a build that succeeded '
        'when getting its follow error '
        'then there is none', () {
      final build = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.succeeded)
          .build();

      expect(
        AppBuildStatusFormatter.followError(
          AppPlatform.android,
          build,
          logCommand: logCommand,
          projectId: 'project-id',
          baseCommand: 'scloud',
        ),
        isNull,
      );
    });
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

  test('Given a build waiting for a build machine '
      'when getting the long queue note '
      'then it says the build waits for a machine and continues', () {
    expect(
      AppBuildStatusFormatter.longQueueNote([
        AppBuildSummaryBuilder().withStatus(AppBuildStatus.waiting).build(),
      ], buildCount: 1),
      [
        'Waiting for a build machine to be ready. This can take a while.',
        'Press Ctrl+C to stop following. '
            'The build continues in Serverpod Cloud.',
      ],
    );
  });

  test('Given a build queued behind other builds of two followed builds '
      'when getting the long queue note '
      'then it says it waits for other builds and the builds continue', () {
    expect(
      AppBuildStatusFormatter.longQueueNote([
        AppBuildSummaryBuilder().withStatus(AppBuildStatus.queued).build(),
      ], buildCount: 2),
      [
        'Waiting for other app builds of the account to end. '
            'This can take a while.',
        'Press Ctrl+C to stop following. '
            'The builds continue in Serverpod Cloud.',
      ],
    );
  });
}

import 'package:ground_control_client/ground_control_client.dart'
    hide AppBuildStepLog;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_build_step_log.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_doctor_check.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_status_row.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_upload_row.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_ui.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an upload whose builds have different build numbers', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const AppUploadListTextUi(utc: true),
        data: [
          AppUploadRow(
            uploadId: const Uuid().v4obj(),
            versionName: '1.4.2',
            platforms: [AppPlatform.ios, AppPlatform.android],
            status: AppBuildStatus.succeeded,
            createdAt: DateTime.now(),
            builds: [
              AppBuildSummaryBuilder().withBuildNumber('37').build(),
              AppBuildSummaryBuilder()
                  .withPlatform(AppPlatform.android)
                  .withBuildNumber('38')
                  .build(),
            ],
          ),
        ],
      );
      stdout = io.stdout;
    });

    test('when rendered then the version lists both build numbers', () {
      expect(stdout, contains('1.4.2 (37, 38)'));
    });
  });

  group('Given an upload without a version name or build number', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const AppUploadListTextUi(utc: true),
        data: [
          AppUploadRow(
            uploadId: const Uuid().v4obj(),
            versionName: null,
            platforms: [AppPlatform.ios],
            status: AppBuildStatus.queued,
            createdAt: DateTime.now(),
            builds: [
              AppBuildSummaryBuilder()
                  .withVersionName(null)
                  .withBuildNumber(null)
                  .build(),
            ],
          ),
        ],
      );
      stdout = io.stdout;
    });

    test('when rendered then the row has an empty version', () {
      expect(
        stdout.split('\n'),
        contains(matches(RegExp(r'^[0-9a-f-]{36} \| +\| iOS '))),
      );
    });
  });

  group('Given no uploads', () {
    test('when rendered then no publishes are shown', () async {
      final io = await renderCommandUi(
        const AppUploadListTextUi(utc: true),
        data: <AppUploadRow>[],
      );

      expect(io.stdout, contains('No publishes yet.'));
    });
  });

  group('Given iOS builds', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const AppBuildListTextUi(utc: true, platforms: [AppPlatform.ios]),
        data: [AppBuildSummaryBuilder().build()],
      );
      stdout = io.stdout;
    });

    test('when rendered for iOS then there is no Platform column', () {
      expect(stdout, isNot(contains('Platform')));
    });
  });

  group('Given iOS and Android builds', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const AppBuildListTextUi(
          utc: true,
          platforms: [AppPlatform.ios, AppPlatform.android],
        ),
        data: [
          AppBuildSummaryBuilder().build(),
          AppBuildSummaryBuilder().withPlatform(AppPlatform.android).build(),
        ],
      );
      stdout = io.stdout;
    });

    test('when rendered for iOS and Android '
        'then each row names its platform', () {
      expect(
        stdout.split('\n'),
        containsAllInOrder([
          contains('Platform'),
          anything,
          contains('iOS'),
          contains('Android'),
        ]),
      );
    });
  });

  group('Given no builds', () {
    test('when rendered for iOS and Android '
        'then no iOS or Android publishes are shown', () async {
      final io = await renderCommandUi(
        const AppBuildListTextUi(
          utc: true,
          platforms: [AppPlatform.ios, AppPlatform.android],
        ),
        data: <AppBuildSummary>[],
      );

      expect(io.stdout, contains('No iOS or Android publishes yet.'));
    });
  });

  group('Given a build created 8 days ago', () {
    test('when rendered in UTC '
        'then Started shows the labelled timestamp', () async {
      final createdAt = DateTime.now().toUtc().subtract(
        const Duration(days: 8),
      );
      final io = await renderCommandUi(
        const AppBuildListTextUi(utc: true, platforms: [AppPlatform.ios]),
        data: [AppBuildSummaryBuilder().withCreatedAt(createdAt).build()],
      );

      expect(
        io.stdout,
        contains(
          '${createdAt.toIso8601String().substring(0, 10)} '
          '${createdAt.toIso8601String().substring(11, 19)} (UTC)',
        ),
      );
    });
  });

  group('Given a platform whose latest build ended more than 7 days ago', () {
    test('when rendering the status in UTC '
        'then the state shows the labelled timestamp', () async {
      final io = await renderCommandUi(
        const AppStatusTextUi(
          utc: true,
          baseCommand: 'scloud',
          projectId: 'my-project-id',
        ),
        data: [
          AppStatusRow(
            platform: AppPlatform.ios,
            store: AppStore.appStore,
            latestBuild: AppBuildSummaryBuilder()
                .withCreatedAt(DateTime.utc(2026, 1, 15, 8, 50))
                .withStartedAt(DateTime.utc(2026, 1, 15, 8, 52))
                .withEndedAt(DateTime.utc(2026, 1, 15, 9, 15, 5))
                .build(),
          ),
        ],
      );

      expect(io.stdout, contains('Uploaded · 2026-01-15 09:15:05 (UTC)'));
    });
  });

  group('Given a AppLogTextUi', () {
    test('when rendered with a log of Windows line endings '
        'then each line is printed once', () async {
      final io = await renderCommandUi(
        const AppLogTextUi(),
        data: Stream.value(
          AppBuildStepLog(
            step: AppBuildStepInfoBuilder().withName('Build').build(),
            log: 'Running pod install\r\nBuilt Runner.app\r\n',
          ),
        ),
      );

      expect(
        io.stdout,
        '--- Build (Succeeded) ---\n'
        'Running pod install\n'
        'Built Runner.app\n',
      );
    });

    test('when rendered with a step without a log '
        'then only its header is printed', () async {
      final io = await renderCommandUi(
        const AppLogTextUi(),
        data: Stream.value(
          AppBuildStepLog(
            step: AppBuildStepInfoBuilder().withName('Build').build(),
          ),
        ),
      );

      expect(io.stdout, '--- Build (Succeeded) ---\n');
    });
  });

  group('Given app doctor checks with one failed check', () {
    late String stdout;
    late String stderr;

    setUp(() async {
      final io = await renderCommandUi(
        const AppDoctorTextUi(),
        data: const [
          AppDoctorCheck(
            platform: FlutterPlatform.ios,
            kind: AppDoctorCheckKind.appIdentifier,
            status: AppDoctorCheckStatus.passed,
            detail: 'com.acme.app',
          ),
          AppDoctorCheck(
            platform: FlutterPlatform.ios,
            kind: AppDoctorCheckKind.exportCompliance,
            status: AppDoctorCheckStatus.failed,
            detail: 'ios/Runner/Info.plist is missing.',
            hint: 'Recreate the ios project.',
          ),
        ],
      );
      stdout = io.stdout;
      stderr = io.stderr;
    });

    test(
      'when rendered then the summary says one check failed and asks to fix it',
      () {
        expect(
          stderr,
          contains('1 check failed. Fix it before you publish the app.'),
        );
      },
    );

    test('when rendered then the hint follows the failed check', () {
      expect(
        stdout,
        contains(
          '  ✗ Export compliance: ios/Runner/Info.plist is missing.\n'
          '    Recreate the ios project.',
        ),
      );
    });
  });

  group('Given app doctor checks with one warning and no failure', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const AppDoctorTextUi(),
        data: const [
          AppDoctorCheck(
            platform: null,
            kind: AppDoctorCheckKind.flutterVersion,
            status: AppDoctorCheckStatus.warning,
            detail: 'No Flutter version is requested.',
            hint: 'Set project.flutterSdk.',
          ),
        ],
      );
      stdout = io.stdout;
    });

    test('when rendered then the warning is marked under the app', () {
      expect(
        stdout,
        contains('App\n  ! Flutter version: No Flutter version is requested.'),
      );
    });

    test('when rendered then the summary is the number of warnings', () {
      expect(stdout, contains('\n1 warning found\n'));
      expect(stdout, isNot(contains('No issues found')));
    });
  });

  group('Given app doctor checks with two warnings and no failure', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const AppDoctorTextUi(),
        data: const [
          AppDoctorCheck(
            platform: null,
            kind: AppDoctorCheckKind.flutterVersion,
            status: AppDoctorCheckStatus.warning,
            detail: 'No Flutter version is requested.',
          ),
          AppDoctorCheck(
            platform: FlutterPlatform.ios,
            kind: AppDoctorCheckKind.exportCompliance,
            status: AppDoctorCheckStatus.warning,
            detail: 'Exempt encryption is assumed.',
          ),
        ],
      );
      stdout = io.stdout;
    });

    test('when rendered then the summary counts both warnings', () {
      expect(stdout, contains('\n2 warnings found\n'));
    });
  });
}

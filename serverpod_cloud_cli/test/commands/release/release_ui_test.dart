import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/release/app_upload_row.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/release/release_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an upload whose builds have different build numbers', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const ReleaseUploadListTextUi(utc: true),
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
        const ReleaseUploadListTextUi(utc: true),
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

    test('when rendered then the row starts with an empty version', () {
      expect(stdout.split('\n'), contains(matches(RegExp(r'^ +\| iOS '))));
    });
  });

  group('Given no uploads', () {
    test('when rendered then no publishes are shown', () async {
      final io = await renderCommandUi(
        const ReleaseUploadListTextUi(utc: true),
        data: <AppUploadRow>[],
      );

      expect(io.stdout, contains('No publishes yet.'));
    });
  });

  group('Given iOS builds', () {
    late String stdout;

    setUp(() async {
      final io = await renderCommandUi(
        const ReleaseBuildListTextUi(utc: true, platforms: [AppPlatform.ios]),
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
        const ReleaseBuildListTextUi(
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
        const ReleaseBuildListTextUi(
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
        const ReleaseBuildListTextUi(utc: true, platforms: [AppPlatform.ios]),
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
}

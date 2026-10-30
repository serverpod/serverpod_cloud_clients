import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildsUpload,
        AppPlatform,
        AppPublishingDisabledException,
        Client,
        InvalidValueException,
        NotFoundException,
        UploadTooLargeException,
        UuidValue;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';

abstract class ReleaseOperations {
  /// Requests a build of the Flutter app in [flutterAppDir] of the archive
  /// for each of [platforms] in project [projectId], and returns the build
  /// ids with the upload description for an archive of [archiveSize] bytes.
  ///
  /// [versionName] is the app version the builds are made with.
  ///
  /// Throws [FailureException] if the request fails.
  static Future<AppBuildsUpload> createBuilds(
    Client cloudApiClient, {
    required String projectId,
    required List<FlutterPlatform> platforms,
    required String flutterAppDir,
    required int archiveSize,
    String? versionName,
    GitMetadata? gitMetadata,
  }) async {
    final appPlatforms = platforms.map(_appPlatform).toList();

    try {
      return await cloudApiClient.appBuilds.createBuilds(
        cloudCapsuleId: projectId,
        platforms: appPlatforms,
        flutterAppDir: flutterAppDir,
        archiveSize: archiveSize,
        versionName: versionName,
        commitHash: gitMetadata?.commitHash,
        commitMessage: gitMetadata?.commitMessage,
        branch: gitMetadata?.branch,
      );
    } on UploadTooLargeException catch (e) {
      throw FailureException(
        error: e.message,
        hint: 'Exclude files from the app with a .scloudignore file.',
      );
    } on AppPublishingDisabledException catch (e) {
      throw FailureException(error: e.message);
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to request the app builds.',
      );
    }
  }

  /// Cancels the app builds [buildIds] of project [projectId]. A build that
  /// no longer exists is skipped.
  ///
  /// Throws [FailureException] if a build cannot be cancelled, after trying
  /// to cancel all of them.
  static Future<void> cancelBuilds(
    Client cloudApiClient, {
    required String projectId,
    required List<UuidValue> buildIds,
  }) async {
    final errors = <String>[];
    for (final buildId in buildIds) {
      try {
        await cloudApiClient.appBuilds.cancelBuild(
          cloudCapsuleId: projectId,
          buildId: buildId,
        );
      } on NotFoundException {
        continue;
      } on Exception {
        errors.add('Failed to cancel the app build $buildId.');
      }
    }
    if (errors.isNotEmpty) {
      throw FailureException(errors: errors);
    }
  }

  static AppPlatform _appPlatform(FlutterPlatform platform) {
    return switch (platform) {
      FlutterPlatform.android => AppPlatform.android,
      FlutterPlatform.ios => AppPlatform.ios,
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw FailureException(
        error: 'Releasing for ${platform.name} is not supported yet.',
      ),
    };
  }
}

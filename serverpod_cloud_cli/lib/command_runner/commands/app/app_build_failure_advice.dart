import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildFailureReason, AppPlatform;
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';

/// What went wrong with an app build and what the user can do about it, in
/// the words the console uses for the same failure.
class AppBuildFailureAdvice {
  static const _appleCertificates =
      'https://developer.apple.com/account/resources/certificates/list';
  static const _appStoreConnectApps = 'https://appstoreconnect.apple.com/apps';
  static const _appStoreConnectApiKeys =
      'https://appstoreconnect.apple.com/access/integrations/api';
  static const _playConsole = 'https://play.google.com/console';

  /// What went wrong, as one sentence without a final period.
  final String title;

  /// What to do about it.
  final String description;

  /// The page to fix it on, if any, with the name of the button that opens
  /// it in the console.
  final ({String label, String url})? link;

  /// Whether the fix is to download the build and upload it to the store by
  /// hand.
  final bool downloadsBuild;

  const AppBuildFailureAdvice._({
    required this.title,
    required this.description,
    this.link,
    this.downloadsBuild = false,
  });

  /// The advice for a [platform] build of project [projectId] that failed
  /// for [reason], or null when there is nothing more to say than that it
  /// failed. Commands are named with [baseCommand].
  static AppBuildFailureAdvice? of(
    AppBuildFailureReason? reason,
    AppPlatform platform, {
    required String projectId,
    required String baseCommand,
  }) {
    final android = platform == AppPlatform.android;
    final setup = (
      label: 'Open setup',
      url: getAppStoreSetupUrl(projectId, platform),
    );
    return switch (reason) {
      null || AppBuildFailureReason.unknown => null,
      AppBuildFailureReason.storeAppNotFound when android =>
        const AppBuildFailureAdvice._(
          title: "Google Play doesn't know this app yet",
          description:
              "Create the app in Play Console if you haven't. A new app "
              'takes its first build by hand: download this build and upload '
              'it there once. Later builds upload on their own.',
          downloadsBuild: true,
        ),
      AppBuildFailureReason.storeAppNotFound => const AppBuildFailureAdvice._(
        title: 'App Store Connect has no app for this bundle ID',
        description: 'Create the app in App Store Connect, then publish again.',
        link: (label: 'Open App Store Connect', url: _appStoreConnectApps),
      ),
      AppBuildFailureReason.storePermissionDenied when android =>
        AppBuildFailureAdvice._(
          title: "We can't upload this app",
          description:
              'Invite it in Play Console with release permissions, then '
              'publish again.',
          link: setup,
        ),
      AppBuildFailureReason.storePermissionDenied =>
        const AppBuildFailureAdvice._(
          title: "Your API key can't upload this app",
          description:
              'Give the key App Manager access in App Store Connect, then '
              'publish again.',
          link: (label: 'Open App Store Connect', url: _appStoreConnectApiKeys),
        ),
      AppBuildFailureReason.storeKeyRejected => AppBuildFailureAdvice._(
        title: 'Apple rejected your API key',
        description:
            'The key was revoked or is wrong. Add a new key and use it for '
            'this project.',
        link: setup,
      ),
      AppBuildFailureReason.versionAlreadyUploaded =>
        const AppBuildFailureAdvice._(
          title: 'This build number is already taken',
          description:
              'Raise the number after the + in your pubspec.yaml version, '
              'like 1.0.0+5, then publish again.',
        ),
      AppBuildFailureReason.debugSigned => AppBuildFailureAdvice._(
        title: 'This build is signed for debugging',
        description:
            "Release signing isn't set up in your Android project. Run "
            '$baseCommand app doctor to see what to change.',
      ),
      AppBuildFailureReason.wrongSigningKey => const AppBuildFailureAdvice._(
        title: 'Google Play expects a different upload key',
        description:
            "This build is signed with a key Google Play doesn't accept for "
            'this app. Use the upload key the app had before, or ask Google '
            'Play to reset it.',
        link: (label: 'Open Play Console', url: _playConsole),
      ),
      AppBuildFailureReason.signingCertificateLimitReached =>
        const AppBuildFailureAdvice._(
          title: 'Apple has no room for another certificate',
          description:
              'Your Apple team already has as many distribution certificates '
              "as Apple allows. Revoke a Distribution certificate no one on "
              "your team still uses, then publish again. If you're not sure, "
              "ask your team's admin before you revoke it. Your apps on the "
              'App Store and TestFlight are not affected.',
          link: (label: 'Open Certificates', url: _appleCertificates),
        ),
      AppBuildFailureReason.signingFailed => AppBuildFailureAdvice._(
        title: "We couldn't sign the app",
        description:
            'Check that your API key has App Manager access and your bundle '
            'ID is registered, then publish again.',
        link: setup,
      ),
      AppBuildFailureReason.dependenciesNotResolved =>
        const AppBuildFailureAdvice._(
          title: "Your app's packages couldn't be fetched",
          description:
              'Run flutter pub get in your app, fix what it reports, then '
              'publish again.',
        ),
      AppBuildFailureReason.compileFailed => const AppBuildFailureAdvice._(
        title: "Your app didn't compile",
        description:
            'Fix the error in your app, then publish again. The log has the '
            'full output.',
      ),
      AppBuildFailureReason.timedOut => const AppBuildFailureAdvice._(
        title: 'The build took too long',
        description:
            'Builds stop after 60 minutes. Publish again, and tell us if it '
            'keeps happening.',
      ),
      AppBuildFailureReason.droppedByBuildService =>
        const AppBuildFailureAdvice._(
          title: 'We lost this build',
          description: 'This one is on us. Publish again.',
        ),
    };
  }
}

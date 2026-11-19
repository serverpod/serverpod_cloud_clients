import '../protocol/protocol.dart' show AppBuildFailureReason, AppPlatform;

const _appleCertificates =
    'https://developer.apple.com/account/resources/certificates/list';
const _appStoreConnectApps = 'https://appstoreconnect.apple.com/apps';
const _appStoreConnectApiKeys =
    'https://appstoreconnect.apple.com/access/integrations/api';
const _playConsole = 'https://play.google.com/console';

/// What went wrong with an app build and what the user can do about it.
class AppBuildFailureAdvice {
  /// What went wrong, as one sentence without a final period.
  final String title;

  /// What to do about it.
  final String description;

  /// The action that helps fix it, or null when the fix is in the user's
  /// own app.
  final AppBuildFailureAction? action;

  /// The steps to fix it, in order, with button names in `**bold**`. Empty
  /// when [description] says it all.
  final List<String> steps;

  const AppBuildFailureAdvice({
    required this.title,
    required this.description,
    this.action,
    this.steps = const [],
  });
}

/// An action that helps the user fix a failed app build.
sealed class AppBuildFailureAction {
  /// The name of the button that runs the action.
  final String label;

  const AppBuildFailureAction(this.label);
}

/// Opens the app store setup of the project.
class OpenSetupAction extends AppBuildFailureAction {
  const OpenSetupAction() : super('Open setup');
}

/// Downloads the build, so the user can upload it to the store by hand.
class DownloadBuildAction extends AppBuildFailureAction {
  const DownloadBuildAction() : super('Download build');
}

/// Opens [url], a page outside Serverpod Cloud.
class OpenLinkAction extends AppBuildFailureAction {
  /// The page to open.
  final String url;

  const OpenLinkAction({required String label, required this.url})
    : super(label);
}

/// The advice for an app build that failed for this reason.
extension AppBuildFailureReasonAdvice on AppBuildFailureReason {
  /// The advice for a [platform] build that failed for this reason, or null
  /// when there is nothing more to say than that it failed. Commands are
  /// named with [baseCommand].
  AppBuildFailureAdvice? adviceFor(
    AppPlatform platform, {
    required String baseCommand,
  }) {
    final android = platform == AppPlatform.android;
    return switch (this) {
      AppBuildFailureReason.unknown => null,
      AppBuildFailureReason.storeAppNotFound when android =>
        const AppBuildFailureAdvice(
          title: "Google Play doesn't know this app yet",
          description:
              "Create the app in Play Console if you haven't. A new app takes "
              'its first build by hand: download this build and upload it '
              'there once. Later builds upload on their own.',
          action: DownloadBuildAction(),
        ),
      AppBuildFailureReason.storeAppNotFound => const AppBuildFailureAdvice(
        title: 'App Store Connect has no app for this bundle ID',
        description: 'Create the app in App Store Connect, then publish again.',
        action: OpenLinkAction(
          label: 'Open App Store Connect',
          url: _appStoreConnectApps,
        ),
      ),
      AppBuildFailureReason.storePermissionDenied when android =>
        const AppBuildFailureAdvice(
          title: "Our service account can't upload this app",
          description:
              'Invite it in Play Console with release permissions, then '
              'publish again.',
          action: OpenSetupAction(),
        ),
      AppBuildFailureReason.storePermissionDenied => const AppBuildFailureAdvice(
        title: "Your API key doesn't have permission to upload this app",
        description:
            "A key's access can't be changed once it's created. Generate a new "
            'key with App Manager access in App Store Connect, use it for '
            'this project in setup, then publish again.',
        action: OpenLinkAction(
          label: 'Open App Store Connect',
          url: _appStoreConnectApiKeys,
        ),
      ),
      AppBuildFailureReason.storeKeyRejected => const AppBuildFailureAdvice(
        title: 'Apple rejected your API key',
        description:
            'The key was revoked or is wrong. Add a new key and use it for '
            'this project.',
        action: OpenSetupAction(),
      ),
      AppBuildFailureReason.versionAlreadyUploaded =>
        const AppBuildFailureAdvice(
          title: 'This build number is already taken',
          description:
              'Raise the number after the + in your pubspec.yaml version, '
              'like 1.0.0+5, then publish again.',
        ),
      AppBuildFailureReason.debugSigned => AppBuildFailureAdvice(
        title: 'This build is signed for debugging',
        description:
            "Release signing isn't set up in your Android project. Run "
            '$baseCommand app doctor to see what to change.',
      ),
      AppBuildFailureReason.wrongSigningKey => const AppBuildFailureAdvice(
        title: 'Google Play expects a different upload key',
        description:
            "This build is signed with a key Google Play doesn't accept for "
            'this app. Use the upload key the app had before, or ask Google '
            'Play to reset it.',
        action: OpenLinkAction(label: 'Open Play Console', url: _playConsole),
      ),
      AppBuildFailureReason.signingCertificateLimitReached =>
        const AppBuildFailureAdvice(
          title: 'Apple has no room for another certificate',
          description:
              'Your Apple team already has as many distribution certificates '
              'as Apple allows. Remove one you no longer use, then publish '
              'again. Your apps on the App Store and TestFlight are not '
              'affected.',
          action: OpenLinkAction(
            label: 'Open Certificates',
            url: _appleCertificates,
          ),
          steps: [
            'Click **Open Certificates** and sign in to Apple.',
            'Find a certificate of type **Distribution** that no one on your '
                "team still uses. If you're not sure, ask your team's admin "
                'before you revoke it.',
            'Click it, then click **Revoke**.',
            'Come back and publish again.',
          ],
        ),
      AppBuildFailureReason.signingFailed => const AppBuildFailureAdvice(
        title: "We couldn't sign the app",
        description:
            'Check that your API key has App Manager access and your bundle '
            'ID is registered, then publish again.',
        action: OpenSetupAction(),
      ),
      AppBuildFailureReason.dependenciesNotResolved =>
        const AppBuildFailureAdvice(
          title: "Your app's packages couldn't be fetched",
          description:
              'Run flutter pub get in your app, fix what it reports, then '
              'publish again.',
        ),
      AppBuildFailureReason.compileFailed => const AppBuildFailureAdvice(
        title: "Your app didn't compile",
        description:
            'Fix the error below in your app, then publish again. The log has '
            'the full output.',
      ),
      AppBuildFailureReason.timedOut => const AppBuildFailureAdvice(
        title: 'The build took too long',
        description:
            'Builds stop after 60 minutes. Publish again, and tell us if it '
            'keeps happening.',
      ),
      AppBuildFailureReason.droppedByBuildService =>
        const AppBuildFailureAdvice(
          title: 'We lost this build',
          description: 'This one is on us. Publish again.',
        ),
    };
  }
}

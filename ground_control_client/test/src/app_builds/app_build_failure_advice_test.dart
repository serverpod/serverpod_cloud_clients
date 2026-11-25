import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';

const _baseCommand = 'serverpod cloud';
const _appleCertificates =
    'https://developer.apple.com/account/resources/certificates/list';
const _appStoreConnectApps = 'https://appstoreconnect.apple.com/apps';
const _appStoreConnectApiKeys =
    'https://appstoreconnect.apple.com/access/integrations/api';
const _playConsole = 'https://play.google.com/console';

void main() {
  group('Given a build that failed without a known reason', () {
    test('when advising '
        'then there is no advice', () {
      expect(
        AppBuildFailureReason.unknown.adviceFor(
          AppPlatform.ios,
          baseCommand: _baseCommand,
        ),
        isNull,
      );
    });
  });

  group('Given the store does not know the app', () {
    test('when the Android package name and invited user are given '
        'then the advice ends with both', () {
      final advice = AppBuildFailureReason.storeAppNotFound.adviceFor(
        AppPlatform.android,
        baseCommand: _baseCommand,
        androidPackageName: 'com.example.app',
        invitedUserEmail: 'user@example.com',
      );

      expect(
        advice?.description,
        endsWith(
          '\n\nPackage name: com.example.app\nInvited user: user@example.com',
        ),
      );
    });

    test('when only the invited user is given '
        'then the advice leaves out the package name line', () {
      final advice = AppBuildFailureReason.storeAppNotFound.adviceFor(
        AppPlatform.android,
        baseCommand: _baseCommand,
        invitedUserEmail: 'user@example.com',
      );

      expect(advice?.description, isNot(contains('Package name:')));
    });

    test('when neither is given '
        'then the advice has no list of values', () {
      final advice = AppBuildFailureReason.storeAppNotFound.adviceFor(
        AppPlatform.android,
        baseCommand: _baseCommand,
      );

      expect(advice?.description, isNot(contains('\n')));
    });

    test('when the build is for iOS '
        'then App Store Connect apps are opened', () {
      final advice = AppBuildFailureReason.storeAppNotFound.adviceFor(
        AppPlatform.ios,
        baseCommand: _baseCommand,
      );

      expect(_linkOf(advice), _appStoreConnectApps);
    });
  });

  group('Given the store denied the upload', () {
    test('when the build is for Android '
        'then the setup is opened to invite the service account', () {
      final advice = AppBuildFailureReason.storePermissionDenied.adviceFor(
        AppPlatform.android,
        baseCommand: _baseCommand,
      );

      expect(advice?.action, isA<OpenSetupAction>());
    });

    test('when the build is for iOS '
        'then the API key page is opened', () {
      final advice = AppBuildFailureReason.storePermissionDenied.adviceFor(
        AppPlatform.ios,
        baseCommand: _baseCommand,
      );

      expect(_linkOf(advice), _appStoreConnectApiKeys);
    });
  });

  group('Given Apple has no room for another certificate', () {
    final advice = AppBuildFailureReason.signingCertificateLimitReached
        .adviceFor(AppPlatform.ios, baseCommand: _baseCommand);

    test('when advising '
        'then the certificates page is opened', () {
      expect(_linkOf(advice), _appleCertificates);
    });

    test('when advising '
        'then there are steps to free a certificate', () {
      expect(advice?.steps, isNotEmpty);
    });
  });

  group('Given Google Play expects a different upload key', () {
    test('when advising '
        'then Play Console is opened', () {
      final advice = AppBuildFailureReason.wrongSigningKey.adviceFor(
        AppPlatform.android,
        baseCommand: _baseCommand,
      );

      expect(_linkOf(advice), _playConsole);
    });
  });

  group('Given a build signed for debugging', () {
    test('when advising '
        'then the doctor command is named with the base command', () {
      final advice = AppBuildFailureReason.debugSigned.adviceFor(
        AppPlatform.android,
        baseCommand: 'scloud',
      );

      expect(advice?.description, contains('scloud app doctor'));
    });
  });

  group('Given a failure the user fixes in their own app', () {
    for (final reason in [
      AppBuildFailureReason.versionAlreadyUploaded,
      AppBuildFailureReason.debugSigned,
      AppBuildFailureReason.dependenciesNotResolved,
      AppBuildFailureReason.compileFailed,
      AppBuildFailureReason.timedOut,
      AppBuildFailureReason.droppedByBuildService,
    ]) {
      test('when the reason is ${reason.name} '
          'then advice is given without an action', () {
        final advice = reason.adviceFor(
          AppPlatform.ios,
          baseCommand: _baseCommand,
        );

        expect(advice, isNotNull);
        expect(advice?.action, isNull);
      });
    }
  });

  group('Given a failure fixed in the setup', () {
    for (final reason in [
      AppBuildFailureReason.storeKeyRejected,
      AppBuildFailureReason.signingFailed,
    ]) {
      test('when the reason is ${reason.name} '
          'then the setup is opened', () {
        expect(
          reason.adviceFor(AppPlatform.ios, baseCommand: _baseCommand)?.action,
          isA<OpenSetupAction>(),
        );
      });
    }
  });
}

String? _linkOf(AppBuildFailureAdvice? advice) {
  return switch (advice?.action) {
    OpenLinkAction(:final url) => url,
    _ => null,
  };
}

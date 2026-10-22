import 'package:ground_control_client/ground_control_client.dart';

import 'app_readiness_item_builder.dart';

/// Builds an [AppPlatformInfo]. The default is iOS, turned off, with
/// nothing reported or set.
class AppPlatformInfoBuilder {
  AppPlatform _platform;
  bool _enabled;
  String? _appIdentifier;
  List<AppCredentialInfo> _credentials;
  List<AppReadinessItem>? _readiness;
  AppBuildSummary? _latestBuild;

  AppPlatformInfoBuilder()
    : _platform = AppPlatform.ios,
      _enabled = false,
      _credentials = [];

  AppPlatformInfoBuilder withIosReady() {
    _platform = AppPlatform.ios;
    _enabled = true;
    _appIdentifier = 'app.acme';
    _credentials = [
      AppCredentialInfo(
        kind: AppCredentialKind.appStoreConnectApiKey,
        setAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    _readiness = null;
    return this;
  }

  AppPlatformInfoBuilder withAndroidReady() {
    _platform = AppPlatform.android;
    _enabled = true;
    _appIdentifier = 'com.acme.app';
    _credentials = [
      AppCredentialInfo(
        kind: AppCredentialKind.playServiceAccountKey,
        setAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AppCredentialInfo(
        kind: AppCredentialKind.androidUploadKeystore,
        setAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    _readiness = null;
    return this;
  }

  AppPlatformInfoBuilder withAndroidMissingKeystore() {
    withAndroidReady();
    _credentials = _credentials
        .where((c) => c.kind != AppCredentialKind.androidUploadKeystore)
        .toList();
    return this;
  }

  AppPlatformInfoBuilder withPlatform(AppPlatform platform) {
    _platform = platform;
    return this;
  }

  AppPlatformInfoBuilder withEnabled(bool enabled) {
    _enabled = enabled;
    return this;
  }

  AppPlatformInfoBuilder withAppIdentifier(String? appIdentifier) {
    _appIdentifier = appIdentifier;
    return this;
  }

  AppPlatformInfoBuilder withCredentials(List<AppCredentialInfo> credentials) {
    _credentials = credentials;
    return this;
  }

  AppPlatformInfoBuilder withReadiness(List<AppReadinessItem> readiness) {
    _readiness = readiness;
    return this;
  }

  AppPlatformInfoBuilder withLatestBuild(AppBuildSummary? latestBuild) {
    _latestBuild = latestBuild;
    return this;
  }

  AppPlatformInfo build() {
    final readiness = _readiness ?? _readinessFromState();
    return AppPlatformInfo(
      platform: _platform,
      enabled: _enabled,
      appIdentifier: _appIdentifier,
      credentials: _credentials,
      ready: readiness.every((i) => i.done),
      readiness: readiness,
      latestBuild: _latestBuild,
    );
  }

  List<AppReadinessItem> _readinessFromState() {
    final kinds = _credentials.map((c) => c.kind).toSet();
    return switch (_platform) {
      AppPlatform.ios => [
        AppReadinessItemBuilder()
            .withTitle('Bundle ID reported')
            .withDone(_appIdentifier != null)
            .build(),
        AppReadinessItemBuilder()
            .withKey(AppReadinessKey.credentialsValid)
            .withTitle('App Store Connect API key')
            .withAction(
              'Create a team API key with the App Manager role and add its '
              '.p8 file, key ID and issuer ID.',
            )
            .withUrl(
              'https://appstoreconnect.apple.com/access/integrations/api',
            )
            .withDone(kinds.contains(AppCredentialKind.appStoreConnectApiKey))
            .build(),
      ],
      AppPlatform.android => [
        AppReadinessItemBuilder()
            .withTitle('Package name reported')
            .withDone(_appIdentifier != null)
            .build(),
        AppReadinessItemBuilder()
            .withKey(AppReadinessKey.credentialsValid)
            .withTitle('Google Play service account key')
            .withAction(
              'Create a service account with release access to the app in '
              'Play Console and add its JSON key.',
            )
            .withUrl('https://play.google.com/console/')
            .withDone(kinds.contains(AppCredentialKind.playServiceAccountKey))
            .build(),
        AppReadinessItemBuilder()
            .withKey(AppReadinessKey.keystoreSet)
            .withTitle('Upload keystore')
            .withAction(
              'Add the upload keystore the app bundle is signed with, '
              'together with its passwords and key alias.',
            )
            .withUrl(
              'https://docs.flutter.dev/deployment/android#signing-the-app',
            )
            .withDone(kinds.contains(AppCredentialKind.androidUploadKeystore))
            .build(),
      ],
    };
  }
}

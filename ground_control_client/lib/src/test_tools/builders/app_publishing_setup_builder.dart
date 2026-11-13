import 'package:ground_control_client/ground_control_client.dart';

class AppPublishingSetupBuilder {
  AppStoreAccess? _iosStore = AppStoreAccess(
    appStoreConnectKeyId: const Uuid().v4obj(),
    appStoreConnectKeyName: 'Acme team',
  );
  IosSigning? _iosSigning = IosSigning(bundleId: 'com.acme.app');
  GooglePlayAccess? _androidStore;
  AndroidSigning? _androidSigning;

  AppPublishingSetupBuilder withIosStore(AppStoreAccess? store) {
    _iosStore = store;
    return this;
  }

  AppPublishingSetupBuilder withIosSigning(IosSigning? signing) {
    _iosSigning = signing;
    return this;
  }

  AppPublishingSetupBuilder withAndroidStore(GooglePlayAccess? store) {
    _androidStore = store;
    return this;
  }

  AppPublishingSetupBuilder withAndroidSigning(AndroidSigning? signing) {
    _androidSigning = signing;
    return this;
  }

  /// A capsule whose Google Play access Serverpod Cloud has created.
  AppPublishingSetupBuilder withGooglePlayAccess() {
    _androidStore = GooglePlayAccess(
      serviceAccountEmail: 'publisher@acme.iam.gserviceaccount.com',
    );
    return this;
  }

  /// A capsule with a generated upload keystore for Android.
  AppPublishingSetupBuilder withAndroidKeystore() {
    _androidSigning = AndroidSigning(
      keyAlias: 'upload',
      generated: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    return this;
  }

  /// A capsule where nothing is set up on either platform.
  AppPublishingSetupBuilder withNothingSetUp() {
    _iosStore = null;
    _iosSigning = null;
    _androidStore = null;
    _androidSigning = null;
    return this;
  }

  AppPublishingSetup build() {
    return AppPublishingSetup(
      ios: IosPublishingSetup(store: _iosStore, signing: _iosSigning),
      android: AndroidPublishingSetup(
        store: _androidStore,
        signing: _androidSigning,
      ),
    );
  }
}

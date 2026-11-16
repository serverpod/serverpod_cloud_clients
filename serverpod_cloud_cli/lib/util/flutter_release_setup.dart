import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/gradle_source.dart';

/// The docs page on publishing apps with Serverpod Cloud.
const _appPublishingDocsUrl =
    'https://docs.serverpod.dev/cloud/concepts/app-publishing';

/// The docs section on setting up Android release signing for Serverpod
/// Cloud.
const androidReleaseSigningDocsUrl =
    '$_appPublishingDocsUrl#android-release-signing';

/// The docs section on declaring the export compliance of an iOS app.
const iosExportComplianceDocsUrl =
    '$_appPublishingDocsUrl#ios-export-compliance';

/// The docs section on replacing the default app icon of a Flutter app.
const appIconDocsUrl = '$_appPublishingDocsUrl#app-icon';

/// The environment variables that hold the upload keystore on a Serverpod
/// Cloud Android build: its path, its password, the key alias, and the key
/// password.
const _androidSigningVariables = [
  'ANDROID_KEYSTORE_PATH',
  'ANDROID_KEYSTORE_PASSWORD',
  'ANDROID_KEY_ALIAS',
  'ANDROID_KEY_PASSWORD',
];

/// Checks that the Flutter app in [appDirectory] signs its Android release
/// builds on Serverpod Cloud with the upload keystore the build provides,
/// through the `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`,
/// `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD` environment variables.
/// The Gradle build file may read these variables in any way, as long as it
/// names them outside comments.
///
/// Returns the path of the Gradle build file of the app module, relative to
/// [appDirectory].
///
/// Throws [FailureException] if the Gradle build file is missing, if its
/// release build type signs with the debug signing config only, or if it
/// does not name each of the `ANDROID_*` variables. The error says what is
/// wrong, and the hint says how to fix it.
String checkAndroidReleaseSigning(Directory appDirectory) {
  final relativePath = _gradleBuildPaths
      .where((path) => File(p.join(appDirectory.path, path)).existsSync())
      .firstOrNull;
  if (relativePath == null) {
    throw FailureException(
      error: 'The Android app has no Gradle build file.',
      hint:
          'Recreate the android project with '
          '"flutter create --platforms=android ." in the app directory.',
    );
  }

  final content = gradleWithoutComments(
    File(p.join(appDirectory.path, relativePath)).readAsStringSync(),
  );
  if (_signsReleaseWithDebugKeyOnly(content)) {
    throw FailureException(
      error: 'Release builds are signed with the debug key.',
      hint: 'Learn more: $androidReleaseSigningDocsUrl',
    );
  }
  if (!_androidSigningVariables.every(
    (variable) => _references(content, variable),
  )) {
    throw FailureException(
      error: 'Release builds do not use the keystore from Serverpod Cloud.',
      hint: 'Learn more: $androidReleaseSigningDocsUrl',
    );
  }
  return relativePath;
}

/// Reads the `ITSAppUsesNonExemptEncryption` setting of the iOS app in
/// [appDirectory], which answers the export compliance question of App
/// Store Connect for each build.
///
/// Returns whether the app declares that it uses encryption that is not
/// exempt from export compliance documentation.
///
/// Throws [FailureException] if the Info.plist of the app is missing or
/// does not set it.
bool readUsesNonExemptEncryption(Directory appDirectory) {
  final file = File(p.join(appDirectory.path, _infoPlistPath));
  if (!file.existsSync()) {
    throw FailureException(
      error: '$_infoPlistPath is missing.',
      hint:
          'Recreate the ios project with '
          '"flutter create --platforms=ios ." in the app directory.',
    );
  }
  final value = _nonExemptEncryptionSetting
      .firstMatch(file.readAsStringSync().replaceAll(_xmlComment, ''))
      ?.group(1);
  if (value == null) {
    throw FailureException(
      error: 'The app does not declare whether it uses encryption.',
      hint: 'Learn more: $iosExportComplianceDocsUrl',
    );
  }
  return value == 'true';
}

/// Whether the [platform] app in [appDirectory] still has the app icon that
/// `flutter create` gives it.
///
/// Returns false for a platform without a known default icon, and when the
/// icon file is missing.
bool hasDefaultAppIcon(Directory appDirectory, FlutterPlatform platform) {
  final icon = _defaultAppIcons[platform];
  if (icon == null) return false;
  final file = File(p.join(appDirectory.path, icon.path));
  if (!file.existsSync()) return false;
  return sha256.convert(file.readAsBytesSync()).toString() == icon.sha256;
}

/// The smallest icon file of each platform that `flutter create` writes,
/// with the SHA-256 digest of its content.
const _defaultAppIcons = {
  FlutterPlatform.android: (
    path: 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
    sha256: 'c7c0c0189145e4e32a401c61c9bdc615754b0264e7afae24e834bb81049eaf81',
  ),
  FlutterPlatform.ios: (
    path: 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png',
    sha256: 'cab10a0d391ec5bc09ef50ce49e8ad401cee7ef03707ec0923a222c5c2b3d212',
  ),
};

const _gradleBuildPaths = [
  'android/app/build.gradle.kts',
  'android/app/build.gradle',
];

const _infoPlistPath = 'ios/Runner/Info.plist';

final _xmlComment = RegExp(r'<!--[\s\S]*?-->');

final _buildTypesOpener = RegExp(r'\bbuildTypes\s*\{');

/// The `release` build type, as `release {` or, in Kotlin,
/// `getByName("release") {` or `create("release") {`.
final _releaseBlockOpener = RegExp(
  r'''(?:\brelease|(?:getByName|create)\(\s*["']release["']\s*\))\s*\{''',
);

/// The start of a `signingConfig` assignment, as `signingConfig = ...` or,
/// in Groovy, `signingConfig ...`, but not a read of it or of
/// `signingConfigs`.
final _signingConfigAssignment = RegExp(
  r'\bsigningConfig\b(?=\s*=(?!=)|[ \t]+[\w(!])',
);

/// A use of a signing config by name, as `signingConfigs.getByName("name")`
/// or, in Groovy, `signingConfigs.name`. The name is in group 1 or 2.
final _signingConfigUse = RegExp(
  r'''\bsigningConfigs\s*\.\s*(?:getByName\(\s*["'](\w+)["']\s*\)|(\w+)\b)''',
);

final _nonExemptEncryptionSetting = RegExp(
  r'<key>\s*ITSAppUsesNonExemptEncryption\s*</key>\s*<(true|false)\s*/>',
);

/// Whether [content] names the environment variable [name] as a whole
/// word, such as in `System.getenv("NAME")`,
/// `providers.environmentVariable("NAME")` or `System.env.NAME`.
bool _references(String content, String name) =>
    RegExp('\\b${RegExp.escape(name)}\\b').hasMatch(content);

/// Whether the release build type in the Gradle [content] signs with the
/// debug signing config and no other: its last `signingConfig` assignment
/// names only the `debug` config. An assignment that picks the `release`
/// config on Serverpod Cloud and the `debug` one elsewhere does not count.
bool _signsReleaseWithDebugKeyOnly(String content) {
  final buildTypes = _block(content, _buildTypesOpener);
  final release = buildTypes == null
      ? null
      : _block(buildTypes, _releaseBlockOpener);
  final assignment = release == null ? null : _lastSigningConfig(release);
  if (assignment == null) return false;
  final names = _signingConfigUse
      .allMatches(assignment)
      .map((match) => match.group(1) ?? match.group(2))
      .toSet();
  return names.length == 1 && names.single == 'debug';
}

/// The last `signingConfig` assignment in the build type [block], up to the
/// end of the block, or null if it assigns none.
String? _lastSigningConfig(String block) {
  final last = _signingConfigAssignment.allMatches(block).lastOrNull;
  return last == null ? null : block.substring(last.start);
}

/// Returns the body of the first block in [content] that [opener] opens,
/// up to its matching closing brace, or null if there is none.
String? _block(String content, RegExp opener) {
  final match = opener.firstMatch(content);
  if (match == null) return null;
  var depth = 1;
  for (var i = match.end; i < content.length; i++) {
    switch (content[i]) {
      case '{':
        depth++;
      case '}':
        depth--;
        if (depth == 0) return content.substring(match.end, i);
    }
  }
  return null;
}

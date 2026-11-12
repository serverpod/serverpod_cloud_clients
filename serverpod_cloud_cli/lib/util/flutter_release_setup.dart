import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// The page on setting up Android release signing for Serverpod Cloud.
const androidReleaseSigningDocsUrl = 'https://docs.serverpod.dev/cloud';

/// The environment variable that Serverpod Cloud sets on its app builds.
const _serverpodAppBuildVariable = 'SERVERPOD_APP_BUILD';

/// The environment variables that hold the upload keystore on a Serverpod
/// Cloud Android build: its path, its password, the key alias, and the key
/// password.
const _androidSigningVariables = [
  'ANDROID_KEYSTORE_PATH',
  'ANDROID_KEYSTORE_PASSWORD',
  'ANDROID_KEY_ALIAS',
  'ANDROID_KEY_PASSWORD',
];

/// The Info.plist lines that declare the app uses no encryption that needs
/// export compliance documentation.
const _nonExemptEncryptionFalseLines =
    '  <key>ITSAppUsesNonExemptEncryption</key>\n'
    '  <false/>';

/// The reference of the iOS `ITSAppUsesNonExemptEncryption` setting.
const iosExportComplianceDocsUrl =
    'https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption';

/// Checks that the Flutter app in [appDirectory] signs its Android release
/// builds on Serverpod Cloud with the upload keystore the build provides,
/// as the Flutter app of a new Serverpod project does: when
/// `SERVERPOD_APP_BUILD` is set, the release build type uses a `release`
/// signing config that reads `ANDROID_KEYSTORE_PATH`,
/// `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` and
/// `ANDROID_KEY_PASSWORD` from the environment.
///
/// Returns the path of the Gradle build file of the app module, relative to
/// [appDirectory].
///
/// Throws [FailureException] if the Gradle build file is missing, if the
/// last signing config its release build type sets is not the `release`
/// one, if it defines no `release` signing config, if that config does not
/// read the `ANDROID_*` variables, or if the file does not read
/// `SERVERPOD_APP_BUILD`.
String checkAndroidReleaseSigning(Directory appDirectory) {
  final relativePath = _gradleBuildPaths
      .where((path) => File(p.join(appDirectory.path, path)).existsSync())
      .firstOrNull;
  if (relativePath == null) {
    throw FailureException(
      error:
          'The Android release signing was not found: '
          '${_gradleBuildPaths.join(' and ')} are missing.',
      hint:
          'Recreate the android project with '
          '"flutter create --platforms=android ." in the app directory.',
    );
  }

  final content = _withoutComments(
    File(p.join(appDirectory.path, relativePath)).readAsStringSync(),
  );
  const hint =
      'Android release signing is managed by Serverpod Cloud. Follow this '
      'link to set it up for your project.\n'
      '$androidReleaseSigningDocsUrl';

  final buildTypes = _block(content, _buildTypesOpener);
  final release = buildTypes == null
      ? null
      : _block(buildTypes, _releaseBlockOpener);
  final assignment = release == null ? null : _lastSigningConfig(release);
  if (assignment == null || !_releaseSigningConfig.hasMatch(assignment)) {
    throw FailureException(
      error: assignment != null && _debugSigningConfig.hasMatch(assignment)
          ? '$relativePath signs release builds with the debug key.'
          : '$relativePath does not sign release builds with the release '
                'signing config.',
      hint: hint,
    );
  }

  final signingConfigs = _block(content, _signingConfigsOpener);
  final releaseSigningConfig = signingConfigs == null
      ? null
      : _block(signingConfigs, _releaseBlockOpener);
  if (releaseSigningConfig == null) {
    throw FailureException(
      error: '$relativePath does not define the release signing config.',
      hint: hint,
    );
  }

  final unreadSigningVariables = _androidSigningVariables
      .where((variable) => !_readsEnvironment(releaseSigningConfig, variable))
      .toList();
  final errors = [
    if (!_readsEnvironment(content, _serverpodAppBuildVariable))
      '$relativePath does not read $_serverpodAppBuildVariable from the '
          'environment.',
    if (unreadSigningVariables.isNotEmpty)
      'The release signing config in $relativePath does not read '
          '${_joined(unreadSigningVariables)} from the environment.',
  ];
  if (errors.isNotEmpty) {
    throw FailureException(errors: errors, hint: hint);
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
      error:
          'The export compliance setting was not found: '
          '$_infoPlistPath is missing.',
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
      error:
          '$_infoPlistPath does not set ITSAppUsesNonExemptEncryption, so '
          'App Store Connect holds each build until its export compliance '
          'is answered.',
      hint:
          'If the app uses no encryption, or only exempt encryption such as '
          'HTTPS, add these lines inside <dict> in $_infoPlistPath:\n'
          '$_nonExemptEncryptionFalseLines\n'
          'Otherwise set it to <true/>, as $iosExportComplianceDocsUrl '
          'describes.',
    );
  }
  return value == 'true';
}

const _gradleBuildPaths = [
  'android/app/build.gradle.kts',
  'android/app/build.gradle',
];

const _infoPlistPath = 'ios/Runner/Info.plist';

final _buildTypesOpener = RegExp(r'\bbuildTypes\s*\{');

final _signingConfigsOpener = RegExp(r'\bsigningConfigs\s*\{');

/// The `release` build type or signing config, as `release {` or, in
/// Kotlin, `getByName("release") {` or `create("release") {`.
final _releaseBlockOpener = RegExp(
  r'''(?:\brelease|(?:getByName|create)\(\s*["']release["']\s*\))\s*\{''',
);

/// The start of a `signingConfig` assignment, as `signingConfig = ...` or,
/// in Groovy, `signingConfig ...`, but not a read of it or of
/// `signingConfigs`.
final _signingConfigAssignment = RegExp(
  r'\bsigningConfig\b(?=\s*=(?!=)|[ \t]+[\w(!])',
);

final _xmlComment = RegExp(r'<!--[\s\S]*?-->');

/// A use of the `release` signing config, as
/// `signingConfigs.getByName("release")` or, in Groovy,
/// `signingConfigs.release`.
final _releaseSigningConfig = RegExp(
  r'''\bsigningConfigs\s*\.\s*(?:getByName\(\s*["']release["']\s*\)|release\b)''',
);

final _debugSigningConfig = RegExp(
  r'''\bsigningConfig\b\s*=?\s*signingConfigs\s*\.\s*(?:debug\b|getByName\(\s*["']debug["']\s*\))''',
);

final _nonExemptEncryptionSetting = RegExp(
  r'<key>\s*ITSAppUsesNonExemptEncryption\s*</key>\s*<(true|false)\s*/>',
);

/// Whether [content] reads the environment variable [name] with
/// `System.getenv("NAME")`, or from the environment map as
/// `System.getenv()["NAME"]` or `System.getenv().get("NAME")`, in single or
/// double quotes.
bool _readsEnvironment(String content, String name) {
  final quoted = '''["']${RegExp.escape(name)}["']''';
  return RegExp(
    r'System\.getenv\(\s*'
    '(?:$quoted'
    r'\s*\)|\)\s*(?:\[\s*'
    '$quoted'
    r'\s*\]|\.\s*get\(\s*'
    '$quoted'
    r'\s*\)))',
  ).hasMatch(content);
}

/// The last `signingConfig` assignment in the build type [block], up to the
/// end of the block, or null if it assigns none.
String? _lastSigningConfig(String block) {
  final last = _signingConfigAssignment.allMatches(block).lastOrNull;
  return last == null ? null : block.substring(last.start);
}

/// The Gradle [source] without its `//` and `/* */` comments. Comment
/// markers inside single- or double-quoted strings are kept, and the line
/// breaks of removed comments too.
String _withoutComments(String source) {
  final result = StringBuffer();
  String? quote;
  var i = 0;
  while (i < source.length) {
    final char = source[i];
    final next = i + 1 < source.length ? source[i + 1] : '';
    if (quote != null) {
      result.write(char);
      if (char == '\\' && next.isNotEmpty) {
        result.write(next);
        i += 2;
        continue;
      }
      if (char == quote) quote = null;
      i++;
    } else if (char == '/' && next == '/') {
      final end = source.indexOf('\n', i);
      i = end == -1 ? source.length : end;
    } else if (char == '/' && next == '*') {
      final end = source.indexOf('*/', i + 2);
      final comment = source.substring(i, end == -1 ? source.length : end);
      result.write('\n' * '\n'.allMatches(comment).length);
      i = end == -1 ? source.length : end + 2;
    } else {
      if (char == '"' || char == "'") quote = char;
      result.write(char);
      i++;
    }
  }
  return result.toString();
}

/// The [names] as a list in prose, like "A, B and C".
String _joined(List<String> names) => names.length == 1
    ? names.single
    : '${names.take(names.length - 1).join(', ')} and ${names.last}';

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

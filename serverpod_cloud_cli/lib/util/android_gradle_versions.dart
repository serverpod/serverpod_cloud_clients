import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/gradle_source.dart';

/// Reads the Gradle version the Android app in [appDirectory] is built
/// with, such as `8.12`: the version of the distribution its Gradle wrapper
/// downloads.
///
/// Returns null if the wrapper properties file is missing or names no
/// distribution with a version.
String? readGradleVersion(Directory appDirectory) {
  final file = File(p.join(appDirectory.path, _wrapperPropertiesPath));
  if (!file.existsSync()) return null;
  return _distributionVersion.firstMatch(file.readAsStringSync())?.group(1);
}

/// Reads the Android Gradle Plugin version the Android app in
/// [appDirectory] is built with, such as `8.9.1`: the version of the
/// `com.android.application` plugin in its Gradle settings file.
///
/// Returns null if the settings file is missing, or if it does not declare
/// the plugin with a quoted version outside comments, as when the version
/// comes from a variable or a version catalog.
String? readAndroidGradlePluginVersion(Directory appDirectory) {
  final file = _gradleSettingsPaths
      .map((path) => File(p.join(appDirectory.path, path)))
      .where((file) => file.existsSync())
      .firstOrNull;
  if (file == null) return null;
  return _androidApplicationPlugin
      .firstMatch(gradleWithoutComments(file.readAsStringSync()))
      ?.group(1);
}

const _wrapperPropertiesPath =
    'android/gradle/wrapper/gradle-wrapper.properties';

const _gradleSettingsPaths = [
  'android/settings.gradle.kts',
  'android/settings.gradle',
];

/// The version in the `distributionUrl` of the wrapper properties, as in
/// `gradle-8.12-all.zip`. A commented-out line does not match.
final _distributionVersion = RegExp(
  r'^\s*distributionUrl\s*[=:].*?gradle-(\d+(?:\.\d+)+(?:-[\w-]+?)?)-(?:bin|all)\.zip',
  multiLine: true,
);

/// The `com.android.application` plugin with a quoted version, as
/// `id("com.android.application") version "8.9.1"` or, in Groovy,
/// `id "com.android.application" version "8.9.1"`.
final _androidApplicationPlugin = RegExp(
  r'''id\s*\(?\s*["']com\.android\.application["']\s*\)?\s*version\s*\(?\s*["'](\d+(?:\.\d+)+(?:-[\w.-]+)?)["']''',
);

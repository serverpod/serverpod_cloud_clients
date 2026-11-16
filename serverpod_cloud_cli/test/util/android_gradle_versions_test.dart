import 'dart:io';

import 'package:serverpod_cloud_cli/util/android_gradle_versions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../test_utils/project_factory.dart';

void main() {
  Directory appDirectory() => Directory(d.path('app'));

  group('Given an Android project as flutter create lays it out', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          gradleVersion: '8.12',
          androidGradlePluginVersion: '8.9.1',
        ),
      ]).create();
    });

    test('when reading the Gradle version '
        'then the version of the wrapper distribution is returned', () {
      expect(readGradleVersion(appDirectory()), '8.12');
    });

    test('when reading the Android Gradle Plugin version '
        'then the version of the application plugin is returned', () {
      expect(readAndroidGradlePluginVersion(appDirectory()), '8.9.1');
    });
  });

  group('Given an Android project without Gradle wrapper and settings '
      'files', () {
    setUp(() async {
      await d.dir('app', [ProjectFactory.flutterAndroidDir()]).create();
    });

    test('when reading the Gradle version then null is returned', () {
      expect(readGradleVersion(appDirectory()), isNull);
    });

    test('when reading the Android Gradle Plugin version '
        'then null is returned', () {
      expect(readAndroidGradlePluginVersion(appDirectory()), isNull);
    });
  });

  group('Given a Gradle wrapper with a release candidate distribution and a '
      'commented-out older one', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('gradle', [
            d.dir('wrapper', [
              d.file('gradle-wrapper.properties', '''
#distributionUrl=https\\://services.gradle.org/distributions/gradle-7.6.3-all.zip
distributionUrl=https\\://services.gradle.org/distributions/gradle-9.0-rc-1-bin.zip
'''),
            ]),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Gradle version '
        'then the version of the distribution in use is returned', () {
      expect(readGradleVersion(appDirectory()), '9.0-rc-1');
    });
  });

  group('Given Groovy Gradle settings that declare the Android Gradle '
      'Plugin', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.file('settings.gradle', '''
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    // id "com.android.application" version "7.3.0" apply false
    id "com.android.application" version "8.1.0" apply false
}
'''),
        ]),
      ]).create();
    });

    test('when reading the Android Gradle Plugin version '
        'then the version of the application plugin is returned', () {
      expect(readAndroidGradlePluginVersion(appDirectory()), '8.1.0');
    });
  });

  group('Given Gradle settings with an older Android Gradle Plugin '
      'declaration in a block comment', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.file('settings.gradle.kts', '''
plugins {
    /*
    id("com.android.application") version "7.3.0" apply false
    */
    id("com.android.application") version "8.9.1" apply false
}
'''),
        ]),
      ]).create();
    });

    test('when reading the Android Gradle Plugin version '
        'then the version of the active declaration is returned', () {
      expect(readAndroidGradlePluginVersion(appDirectory()), '8.9.1');
    });
  });

  group('Given Gradle settings with an older Android Gradle Plugin '
      'declaration in a trailing comment', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.file('settings.gradle.kts', '''
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0" // id("com.android.application") version "7.3.0"
    id("com.android.application") version "8.9.1" apply false
}
'''),
        ]),
      ]).create();
    });

    test('when reading the Android Gradle Plugin version '
        'then the version of the active declaration is returned', () {
      expect(readAndroidGradlePluginVersion(appDirectory()), '8.9.1');
    });
  });

  group('Given Gradle settings that take the Android Gradle Plugin version '
      'from a variable', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.file('settings.gradle.kts', '''
plugins {
    id("com.android.application") version agpVersion apply false
}
'''),
        ]),
      ]).create();
    });

    test('when reading the Android Gradle Plugin version '
        'then null is returned', () {
      expect(readAndroidGradlePluginVersion(appDirectory()), isNull);
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Constructors for Serverpod project directories and files.
class ProjectFactory {
  static const defaultDirectoryName = 'serverpod_server';
  static const defaultPackageName = 'my_project_server';
  static const validSdkVersion = '"^3.8.0"';
  static const highValidSdkVersion = '"^3.10.3"';
  static const validServerpodVersion =
      '"^${VersionConstants.minSupportedServerpodVersion}"';

  /// Returns descriptor for a Serverpod server directory with a valid pubspec.yaml file.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor serverpodServerDir({
    String withDirectoryName = defaultDirectoryName,
    String withPackageName = defaultPackageName,
    String? withResolution,
    Iterable<d.Descriptor>? contents,
  }) {
    return d.dir(withDirectoryName, [
      serverpodServerPubspec(withPackageName: withPackageName),
      ...?contents,
    ]);
  }

  /// Returns descriptor for a valid Serverpod server pubspec.yaml file.
  /// Use `descriptor.create()` to create the file.
  static d.FileDescriptor serverpodServerPubspec({
    String withPackageName = defaultPackageName,
    String? withResolution,
  }) {
    final String resolutionString = withResolution != null
        ? 'resolution: $withResolution'
        : '';
    return d.file('pubspec.yaml', '''
name: $withPackageName
environment:
  sdk: $validSdkVersion
$resolutionString
dependencies:
  serverpod: $validServerpodVersion
''');
  }

  /// Returns descriptor for a `monorepo` Dart workspace with a Serverpod
  /// server, client, and Flutter app package with `lib/main.dart`, resolved
  /// with a lock file and a package graph.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor serverpodAppWorkspace({
    List<String> extraWorkspacePackages = const [],
    List<d.Descriptor> extraContents = const [],
  }) {
    return d.dir('monorepo', [
      d.file(
        'pubspec.yaml',
        serverpodAppWorkspaceRootPubspec(extraWorkspacePackages),
      ),
      d.file('pubspec.lock', serverpodAppWorkspaceLock),
      d.dir('.dart_tool', [
        d.file('package_graph.json', '''
{
  "roots": ["project_server", "project_client", "project_flutter"],
  "packages": [
    {"name": "project_server", "version": "0.0.0", "dependencies": ["serverpod"]},
    {"name": "project_client", "version": "0.0.0", "dependencies": ["serverpod_client"]},
    {"name": "project_flutter", "version": "0.0.0", "dependencies": ["flutter", "project_client", "serverpod_flutter"]},
    {"name": "serverpod", "version": "3.0.0", "dependencies": []},
    {"name": "serverpod_client", "version": "3.0.0", "dependencies": []},
    {"name": "serverpod_flutter", "version": "3.0.0", "dependencies": ["flutter", "serverpod_client"]},
    {"name": "flutter", "version": "0.0.0", "dependencies": []}
  ],
  "configVersion": 1
}
'''),
      ]),
      d.dir('project_server', [
        d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: $validSdkVersion
resolution: workspace
dependencies:
  serverpod: $validServerpodVersion
'''),
      ]),
      d.dir('project_client', [
        d.file('pubspec.yaml', '''
name: project_client
environment:
  sdk: $validSdkVersion
resolution: workspace
dependencies:
  serverpod_client: $validServerpodVersion
'''),
      ]),
      d.dir('project_flutter', [
        d.file('pubspec.yaml', serverpodFlutterAppPubspec()),
        d.dir('lib', [d.file('main.dart', 'void main() {}')]),
      ]),
      ...extraContents,
    ]);
  }

  /// Returns the pubspec.yaml content of a Serverpod Flutter app package
  /// in the [serverpodAppWorkspace], with [withVersion] as its version and
  /// [withFlutterConstraint] as its Flutter SDK constraint.
  static String serverpodFlutterAppPubspec({
    String withPackageName = 'project_flutter',
    String? withVersion,
    String withFlutterConstraint = '3.29.0',
  }) {
    return '''
name: $withPackageName
${withVersion == null ? '' : 'version: $withVersion'}
environment:
  sdk: $validSdkVersion
  flutter: $withFlutterConstraint
resolution: workspace
dependencies:
  flutter:
    sdk: flutter
  project_client: any
  serverpod_flutter: $validServerpodVersion
dev_dependencies:
  flutter_test:
    sdk: flutter
''';
  }

  /// Returns the pubspec.yaml content of a Flutter app package resolved in
  /// a workspace, without any Serverpod dependencies.
  static String flutterAppPubspec({
    String withPackageName = 'project_flutter',
  }) {
    return '''
name: $withPackageName
environment:
  sdk: $validSdkVersion
resolution: workspace
dependencies:
  flutter:
    sdk: flutter
''';
  }

  /// Returns descriptor for the `android` directory of a Flutter app whose
  /// app module declares [applicationId], as `flutter create` lays it out.
  /// [releaseSigning] is added to the `android` block of the app module,
  /// such as [debugKeyReleaseSigning] or [serverpodCloudReleaseSigning].
  /// With [gradleVersion], the Gradle wrapper downloads that distribution.
  /// With [androidGradlePluginVersion], the Gradle settings declare that
  /// version of the Android Gradle Plugin.
  static d.DirectoryDescriptor flutterAndroidDir({
    String applicationId = 'com.acme.app',
    String releaseSigning = '',
    String? displayName,
    Map<String, String> stringResources = const {},
    bool withDefaultAppIcon = false,
    String? gradleVersion,
    String? androidGradlePluginVersion,
  }) {
    return d.dir('android', [
      d.file('build.gradle.kts', ''),
      if (gradleVersion != null)
        d.dir('gradle', [
          d.dir('wrapper', [
            d.file('gradle-wrapper.properties', '''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\\://services.gradle.org/distributions/gradle-$gradleVersion-all.zip
'''),
          ]),
        ]),
      if (androidGradlePluginVersion != null)
        d.file('settings.gradle.kts', '''
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "$androidGradlePluginVersion" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
'''),
      d.dir('app', [
        if (withDefaultAppIcon)
          d.dir('src', [
            d.dir('main', [
              d.dir('res', [
                d.dir('mipmap-mdpi', [
                  d.file('ic_launcher.png', base64Decode(_defaultAndroidIcon)),
                ]),
              ]),
            ]),
          ]),
        d.file('build.gradle.kts', """
android {
    namespace = "$applicationId"

    defaultConfig {
        // The unique Application ID of the app.
        applicationId = "$applicationId"
    }
$releaseSigning}
"""),
        if (displayName != null)
          d.dir('src', [
            d.dir('main', [
              d.file('AndroidManifest.xml', '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="$displayName"/>
</manifest>
'''),
              if (stringResources.isNotEmpty)
                d.dir('res', [
                  d.dir('values', [
                    d.file('strings.xml', '''
<resources>
${stringResources.entries.map((entry) => '  <string name="${entry.key}">${entry.value}</string>').join('\n')}
</resources>
'''),
                  ]),
                ]),
            ]),
          ]),
      ]),
    ]);
  }

  /// The `buildTypes` block that `flutter create` writes into
  /// `android/app/build.gradle.kts`, which signs release builds with the
  /// debug key. Pass it as `releaseSigning` to [flutterAndroidDir].
  static const debugKeyReleaseSigning = """
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
""";

  /// The release signing setup that `serverpod create` adds to
  /// `android/app/build.gradle.kts`, which signs release builds on
  /// Serverpod Cloud with the keystore from the environment, and with the
  /// debug key elsewhere. Pass it as `releaseSigning` to [flutterAndroidDir].
  static const serverpodCloudReleaseSigning = """
    val isServerpodCloudBuild = System.getenv("SERVERPOD_APP_BUILD") != null

    signingConfigs {
        if (isServerpodCloudBuild) {
            create("release") {
                storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (isServerpodCloudBuild) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
""";

  /// Returns descriptor for the `ios` directory of a Flutter app whose app
  /// target has [bundleId] in every build configuration, with the test
  /// target `flutter create` adds next to it.
  ///
  /// With [usesNonExemptEncryption], the Runner's Info.plist sets
  /// `ITSAppUsesNonExemptEncryption` to it, and with [withInfoPlist] alone,
  /// the Info.plist leaves it out. The Info.plist also sets each of
  /// [infoPlistStrings] to its string value. [podfile] is the content of the
  /// Podfile, and [runnerSources] are native source files of the Runner app
  /// by file name.
  static d.DirectoryDescriptor flutterIosDir({
    String bundleId = 'com.acme.app',
    bool withInfoPlist = false,
    bool? usesNonExemptEncryption,
    String? displayName = 'Acme',
    String? bundleName,
    bool withDefaultAppIcon = false,
    Map<String, String> infoPlistStrings = const {},
    String podfile = '',
    Map<String, String> runnerSources = const {},
  }) {
    return d.dir('ios', [
      d.file('Podfile', podfile),
      if (runnerSources.isNotEmpty)
        d.dir('Runner', [
          for (final MapEntry(key: name, value: source)
              in runnerSources.entries)
            d.file(name, source),
        ]),
      if (withDefaultAppIcon)
        d.dir('Runner', [
          d.dir('Assets.xcassets', [
            d.dir('AppIcon.appiconset', [
              d.file('Icon-App-20x20@1x.png', base64Decode(_defaultIosIcon)),
            ]),
          ]),
        ]),
      if (withInfoPlist ||
          usesNonExemptEncryption != null ||
          infoPlistStrings.isNotEmpty)
        d.dir('Runner', [
          d.file('Info.plist', """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
${displayName == null ? '' : '<key>CFBundleDisplayName</key><string>$displayName</string>'}
${bundleName == null ? '' : '<key>CFBundleName</key><string>$bundleName</string>'}
${infoPlistStrings.entries.map((entry) => '\t<key>${entry.key}</key>\n\t<string>${entry.value}</string>').join('\n')}
${usesNonExemptEncryption == null ? '' : '\t<key>ITSAppUsesNonExemptEncryption</key>\n\t<$usesNonExemptEncryption/>\n'}</dict>
</plist>
"""),
        ]),
      d.dir('Runner.xcodeproj', [
        d.file('project.pbxproj', """
		331C8088294A63A400263BE5 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "\$(TEST_HOST)";
				PRODUCT_BUNDLE_IDENTIFIER = $bundleId.RunnerTests;
			};
			name = Debug;
		};
		97C147061CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				INFOPLIST_FILE = Runner/Info.plist;
				PRODUCT_BUNDLE_IDENTIFIER = $bundleId;
			};
			name = Debug;
		};
		97C147071CF9000F007C117D /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				INFOPLIST_FILE = Runner/Info.plist;
				PRODUCT_BUNDLE_IDENTIFIER = $bundleId;
			};
			name = Release;
		};
"""),
      ]),
    ]);
  }

  /// Returns descriptor for the `.flutter-plugins-dependencies` file that
  /// `flutter pub get` writes into a Flutter app, listing [iosPlugins] as
  /// the iOS plugins of the app, by name with the path of their package.
  static d.FileDescriptor flutterPluginsDependencies({
    required Map<String, String> iosPlugins,
  }) {
    return d.file(
      '.flutter-plugins-dependencies',
      jsonEncode({
        'plugins': {
          'ios': [
            for (final MapEntry(key: name, value: path) in iosPlugins.entries)
              {
                'name': name,
                'path': path,
                'native_build': true,
                'dependencies': <String>[],
              },
          ],
        },
      }),
    );
  }

  /// Returns descriptor for a `project_flutter` Flutter app that is not
  /// resolved in a workspace, with a lock file, a package graph, and
  /// `lib/main.dart` unless [withMainDart] is false. Its
  /// pubspec has [withFlutterConstraint] as its Flutter SDK constraint, and
  /// its lock file also lists each of [lockedPackages] as a hosted package.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor nonWorkspaceFlutterAppDir({
    Iterable<d.Descriptor>? contents,
    String withFlutterConstraint = '3.29.0',
    List<String> lockedPackages = const [],
    String dependencies = '',
    String dependencyOverrides = '',
    bool withMainDart = true,
  }) {
    return d.dir('project_flutter', [
      d.file('pubspec.yaml', '''
name: project_flutter
environment:
  sdk: $validSdkVersion
  flutter: "$withFlutterConstraint"
dependencies:
  flutter:
    sdk: flutter
$dependencies
dependency_overrides:
$dependencyOverrides
dev_dependencies:
  flutter_test:
    sdk: flutter
'''),
      d.file('pubspec.lock', '''
# Generated by pub
packages:
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
${lockedPackages.map(_hostedLockEntry).join()}sdks:
  dart: $validSdkVersion
  flutter: 3.29.0
'''),
      if (withMainDart) d.dir('lib', [d.file('main.dart', 'void main() {}')]),
      d.dir('.dart_tool', [
        d.file('package_graph.json', '''
{
  "roots": ["project_flutter"],
  "packages": [
    {"name": "project_flutter", "version": "0.0.0", "dependencies": ["flutter"]},
    {"name": "flutter", "version": "0.0.0", "dependencies": []}
  ],
  "configVersion": 1
}
'''),
      ]),
      ...?contents,
    ]);
  }

  /// Returns the root pubspec.yaml content of the [serverpodAppWorkspace].
  static String serverpodAppWorkspaceRootPubspec([
    List<String> extraWorkspacePackages = const [],
  ]) {
    return '''
name: monorepo
environment:
  sdk: $validSdkVersion
  flutter: 3.29.0
workspace:
  - project_server
  - project_client
  - project_flutter
${extraWorkspacePackages.map((path) => '  - $path').join('\n')}
''';
  }

  /// The pubspec.lock content of the [serverpodAppWorkspace].
  static const serverpodAppWorkspaceLock =
      '''
# Generated by pub
packages:
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
  serverpod:
    dependency: "direct main"
    description:
      name: serverpod
      sha256: "2222222222222222222222222222222222222222222222222222222222222222"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
  serverpod_client:
    dependency: "direct main"
    description:
      name: serverpod_client
      sha256: "3333333333333333333333333333333333333333333333333333333333333333"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
  serverpod_flutter:
    dependency: "direct main"
    description:
      name: serverpod_flutter
      sha256: "4444444444444444444444444444444444444444444444444444444444444444"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
sdks:
  dart: $validSdkVersion
  flutter: 3.29.0
''';
}

/// A class for constructing directories with files.
///
/// This is retained for its symlink capability. For other use cases,
/// use [ProjectFactory] and the test_descriptor package instead.
class DirectoryFactory {
  final List<DirectoryFactory> _subDirectories;
  final List<FileFactory> _files;
  final List<SymLinkFactory> _symLinks;
  final String _directoryName;

  /// Creates a new directory factory.
  /// The directory name is a random UUID by default.
  DirectoryFactory({
    String? withDirectoryName,
    List<DirectoryFactory>? withSubDirectories,
    List<FileFactory>? withFiles,
    List<SymLinkFactory>? withSymLinks,
  }) : _directoryName = withDirectoryName ?? const Uuid().v4(),
       _subDirectories = withSubDirectories ?? [],
       _files = withFiles ?? [],
       _symLinks = withSymLinks ?? [];

  /// Constructs the directory and all subdirectories and files.
  /// Returns the created directory.
  ///
  /// The [path] is the path to where the directory should be created.
  Directory construct(String path) {
    final directory = Directory(path);
    directory.createSync(recursive: true);

    for (final subDirectory in _subDirectories) {
      subDirectory.construct(
        '${directory.path}/${subDirectory._directoryName}',
      );
    }

    for (final file in _files) {
      file.construct(directory.path);
    }

    for (final symlink in _symLinks) {
      symlink.construct(directory.path);
    }

    return directory;
  }
}

/// A class for constructing files.
class FileFactory {
  final String _contents;
  final String _name;

  /// Creates a new file factory.
  ///
  /// The file name is a random UUID by default.
  /// The file contents are empty by default.
  FileFactory({String? withName, String? withContents})
    : _contents = withContents ?? '',
      _name = withName ?? const Uuid().v4();

  /// Constructs the file and writes the contents.
  /// The [path] is the path to where the file should be created.
  /// The file is created synchronously and recursively.
  File construct(String path) {
    final file = File(p.join(path, _name));
    file.createSync(recursive: true);
    file.writeAsStringSync(_contents);
    return file;
  }
}

/// A class for constructing symbolic links.
class SymLinkFactory {
  final String _target;
  final String _name;

  /// Creates a new symbolic link factory.
  ///
  /// The link name is a random UUID by default.
  /// The link target is a random UUID by default.
  ///
  /// The [withTarget] is a relative path to the target.
  SymLinkFactory({String? withName, String? withTarget})
    : _target = withTarget ?? const Uuid().v4(),
      _name = withName ?? const Uuid().v4();

  /// Constructs the symbolic link.
  /// The [path] is the path to where the link should be created.
  FileSystemEntity construct(String path) {
    final file = Link(p.join(path, _name));
    file.createSync(_target);
    return file;
  }
}

/// The base64 content of the smallest Android launcher icon that
/// `flutter create` writes, `mipmap-mdpi/ic_launcher.png`.
const _defaultAndroidIcon =
    'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAIpQTFRFAAAAAVebVMX4Kbb2VMX4AVebKbb2VMX4VMX4Kbb2VMX4VMX4VMX4AVebB1ePVMX4AVebBENyKbb2UcT4VMX4ADxrAUJ1AU2KAU6LAVSVAVSWAVWXAVaZAVaaAVeaAVebAy1LAzFRBUJuBU2ABlOJHom6H43AIZXLIprSIpzVKbb2Mbn2UcT4VMX4UU+PBQAAABV0Uk5TABAQICAwMDCPn5+vv8/Pz+/v7+/vb7KPEwAAAKVJREFUSMft1MkSgjAQRdGIA86igoKirSIOiP//ew6J3WwMnYULU3nL1LnVuwhh9/zwTpt4zjvv/G99d0gbePW+X3kJfd0Bjq8WPE8F138K6Xu3stbLQvmiwOK7fxXosdB5IVrkVaH3csq/CyP/LOYM35xRcB03GJ92B4vLMR2ZFOcs2YJBcTrEqw3wi3y/WK4B2EW+i+IUgF9ME8CxinYAVhR/sgfbkVbaxFzJpwAAAABJRU5ErkJggg==';

/// The base64 content of the smallest iOS app icon that `flutter create`
/// writes, `AppIcon.appiconset/Icon-App-20x20@1x.png`.
const _defaultIosIcon =
    'iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAAAbFBMVEX///9Uxfj6/v/3/P8BV5v0+/+O2frZ8v2Y3fuL2PqH1vpWj72T2/sptva/1Obv+v7g9f73+vy+6fyE1frv9fl10PlXx/g8vfcos/Po9/7R7/3G7P3x9vpozPlNwvjA1uZLm8tbmsAQbaUBUpIS2jkXAAAAdklEQVQY052QyQ6DMAwFMTFt05Cw7zv8/z8SXxAOF2COo5GebO8N4msJuPNDAPg77kOOhwF10uNQlwnekZPi7kb8s0SHlLQRDwBlek4z0YzWdewYv610BbZjFFrXc+LIqKhXVJd3LBuiyh2bKMRr20/GGEofsAP1wASFbdBGzgAAAABJRU5ErkJggg==';

/// The `pubspec.lock` entry of [name] as a hosted package from pub.dev.
String _hostedLockEntry(String name) =>
    '''
  $name:
    dependency: transitive
    description:
      name: $name
      sha256: "1111111111111111111111111111111111111111111111111111111111111111"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.0"
''';

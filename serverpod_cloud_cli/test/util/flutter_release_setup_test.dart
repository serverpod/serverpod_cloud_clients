import 'dart:io';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/flutter_release_setup.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../test_utils/project_factory.dart';

void main() {
  Directory appDirectory() => Directory(d.path('app'));

  group('Given an Android app module with the release signing config of a '
      'new Serverpod project', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle.kts',
      );
    });
  });

  group('Given a Groovy Android app module that signs release builds with '
      'the keystore from the environment map', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
android {
    signingConfigs {
        release {
            if (System.getenv()["SERVERPOD_APP_BUILD"] != null){
                keyAlias = System.getenv()["ANDROID_KEY_ALIAS"]
                keyPassword = System.getenv()["ANDROID_KEY_PASSWORD"]
                storeFile = file(System.getenv()["ANDROID_KEYSTORE_PATH"])
                storePassword = System.getenv()["ANDROID_KEYSTORE_PASSWORD"]
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle',
      );
    });
  });

  group('Given a Groovy Android app module that reads the keystore with '
      'System.getenv calls and get', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
def isServerpodCloudBuild = System.getenv('SERVERPOD_APP_BUILD') != null

android {
    signingConfigs {
        release {
            storeFile file(System.getenv('ANDROID_KEYSTORE_PATH'))
            storePassword System.getenv().get('ANDROID_KEYSTORE_PASSWORD')
            keyAlias System.getenv('ANDROID_KEY_ALIAS')
            keyPassword System.getenv().get("ANDROID_KEY_PASSWORD")
        }
    }
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
        }
        release {
            signingConfig isServerpodCloudBuild ? signingConfigs.release : signingConfigs.debug
        }
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle',
      );
    });
  });

  group('Given an Android app module as flutter create writes it', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: ProjectFactory.debugKeyReleaseSigning,
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying it uses the debug key', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>()
              .having((e) => e.errors, 'errors', [
                'Release builds are signed with the debug key.',
              ])
              .having(
                (e) => e.hint,
                'hint',
                'Learn more: $androidReleaseSigningDocsUrl',
              ),
        ),
      );
    });
  });

  group('Given an Android app module that reads the keystore variables and '
      'whose release build type sets the release signing config and then '
      'the debug one', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: ProjectFactory.serverpodCloudReleaseSigning
              .replaceFirst(
                'signingConfigs.getByName("debug")\n            }',
                'signingConfigs.getByName("debug")\n            }\n'
                    '            signingConfig = '
                    'signingConfigs.getByName("debug")',
              ),
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying it uses the debug key', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds are signed with the debug key.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module whose release build type uses the '
      'debug key with the release one in a trailing comment', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // signingConfig = signingConfigs.getByName("release")
        }
    }
''',
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying it uses the debug key', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds are signed with the debug key.',
          ]),
        ),
      );
    });
  });

  group('Given a Groovy Android app module that reads the keystore variables '
      'and signs release builds with the debug key', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
android {
    signingConfigs {
        release {
            storeFile file(System.getenv('ANDROID_KEYSTORE_PATH'))
            storePassword System.getenv('ANDROID_KEYSTORE_PASSWORD')
            keyAlias System.getenv('ANDROID_KEY_ALIAS')
            keyPassword System.getenv('ANDROID_KEY_PASSWORD')
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying it uses the debug key', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds are signed with the debug key.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that signs release builds with a '
      'signing config named upload that reads the keystore variables', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    signingConfigs {
        create("upload") {
            storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("upload")
        }
    }
''',
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle.kts',
      );
    });
  });

  group('Given an Android app module that signs release builds with the key '
      'in key.properties', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    val keystoreProperties = Properties()
    keystoreProperties.load(FileInputStream(rootProject.file("key.properties")))

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
''',
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException naming every unreferenced variable', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds do not use the keystore from Serverpod Cloud.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that passes the keystore variable names '
      'to a helper that reads them', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle.kts', """
fun signingValue(envVar: String): String? = System.getenv(envVar)

val releaseStoreFile = signingValue("ANDROID_KEYSTORE_PATH")

android {
    signingConfigs {
        create("release") {
            storeFile = releaseStoreFile?.let { file(it) }
            storePassword = signingValue("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = signingValue("ANDROID_KEY_ALIAS")
            keyPassword = signingValue("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
"""),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle.kts',
      );
    });
  });

  group('Given a Kotlin app module that reads the keystore variables with '
      'providers.environmentVariable', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: """
    val isServerpodCloudBuild = providers.environmentVariable("SERVERPOD_APP_BUILD").isPresent

    signingConfigs {
        create("release") {
            storeFile = file(providers.environmentVariable("ANDROID_KEYSTORE_PATH").get())
            storePassword = providers.environmentVariable("ANDROID_KEYSTORE_PASSWORD").get()
            keyAlias = providers.environmentVariable("ANDROID_KEY_ALIAS").get()
            keyPassword = providers.environmentVariable("ANDROID_KEY_PASSWORD").get()
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
""",
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle.kts',
      );
    });
  });

  group('Given a Groovy app module that reads the keystore variables with '
      'System.env', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
def isServerpodCloudBuild = System.env.SERVERPOD_APP_BUILD != null

android {
    signingConfigs {
        release {
            storeFile file(System.env.ANDROID_KEYSTORE_PATH)
            storePassword System.env.ANDROID_KEYSTORE_PASSWORD
            keyAlias System.env.ANDROID_KEY_ALIAS
            keyPassword System.env.ANDROID_KEY_PASSWORD
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle',
      );
    });
  });

  group('Given an Android app module whose release signing config does not '
      'reference ANDROID_KEY_PASSWORD', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: ProjectFactory.serverpodCloudReleaseSigning
              .replaceFirst('System.getenv("ANDROID_KEY_PASSWORD")', '"local"'),
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying the keystore is not used', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds do not use the keystore from Serverpod Cloud.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that names ANDROID_KEY_PASSWORD only in '
      'a comment', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: ProjectFactory.serverpodCloudReleaseSigning
              .replaceFirst(
                'System.getenv("ANDROID_KEY_PASSWORD")',
                '"local" // ANDROID_KEY_PASSWORD',
              ),
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying the keystore is not used', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds do not use the keystore from Serverpod Cloud.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module whose release signing config is in a '
      'block comment', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning:
              '    /*\n${ProjectFactory.serverpodCloudReleaseSigning}    */\n',
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying the keystore is not used', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'Release builds do not use the keystore from Serverpod Cloud.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module with a // inside a string before an '
      'environment read on the same line', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: ProjectFactory.serverpodCloudReleaseSigning.replaceFirst(
            'val isServerpodCloudBuild',
            'val docs = "https://docs.serverpod.dev"; val isServerpodCloudBuild',
          ),
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle.kts',
      );
    });
  });

  group('Given a Kotlin app module with the release signing config of a new '
      'Serverpod project and CRLF line endings', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file(
              'build.gradle.kts',
              '''
// SERVERPOD_APP_BUILD is set when building on Serverpod Cloud.
val isServerpodCloudBuild = System.getenv("SERVERPOD_APP_BUILD") != null

android {
    /* Only configured on Serverpod Cloud builds.
       The keystore comes from the environment. */
    signingConfigs {
        if (isServerpodCloudBuild) {
            create("release") {
                storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH")) // path
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
}
'''
                  .replaceAll('\n', '\r\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle.kts',
      );
    });
  });

  group('Given a Groovy app module that signs release builds with the '
      'keystore from the environment map and CRLF line endings', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file(
              'build.gradle',
              '''
android {
    signingConfigs {
        release {
            // CI properties exported by Serverpod Cloud
            if (System.getenv()["SERVERPOD_APP_BUILD"] != null){
                keyAlias = System.getenv()["ANDROID_KEY_ALIAS"]
                keyPassword = System.getenv()["ANDROID_KEY_PASSWORD"]
                storeFile = file(System.getenv()["ANDROID_KEYSTORE_PATH"])
                storePassword = System.getenv()["ANDROID_KEYSTORE_PASSWORD"]
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
'''
                  .replaceAll('\n', '\r\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    test('when checking the release signing '
        'then the Gradle build file is returned', () {
      expect(
        checkAndroidReleaseSigning(appDirectory()),
        'android/app/build.gradle',
      );
    });
  });

  group('Given an app without an Android app module', () {
    setUp(() async {
      await d.dir('app', [d.dir('android')]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying the build file is missing', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The Android app has no Gradle build file.',
          ]),
        ),
      );
    });
  });

  group('Given an iOS app that declares no non-exempt encryption', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(usesNonExemptEncryption: false),
      ]).create();
    });

    test(
      'when reading the export compliance setting then false is returned',
      () {
        expect(readUsesNonExemptEncryption(appDirectory()), isFalse);
      },
    );
  });

  group('Given an iOS app that declares non-exempt encryption', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(usesNonExemptEncryption: true),
      ]).create();
    });

    test(
      'when reading the export compliance setting then true is returned',
      () {
        expect(readUsesNonExemptEncryption(appDirectory()), isTrue);
      },
    );
  });

  group('Given an iOS app whose Info.plist leaves out '
      'ITSAppUsesNonExemptEncryption', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(withInfoPlist: true),
      ]).create();
    });

    test('when reading the export compliance setting '
        'then throws FailureException naming the setting', () {
      expect(
        () => readUsesNonExemptEncryption(appDirectory()),
        throwsA(
          isA<FailureException>()
              .having(
                (e) => e.errors.single,
                'error',
                'The app does not declare whether it uses encryption.',
              )
              .having(
                (e) => e.hint,
                'hint',
                contains(iosExportComplianceDocsUrl),
              ),
        ),
      );
    });
  });

  group('Given an iOS app whose Info.plist sets '
      'ITSAppUsesNonExemptEncryption only in a comment', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner', [
            d.file('Info.plist', '''
<plist version="1.0">
<dict>
	<!--
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
	-->
</dict>
</plist>
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the export compliance setting '
        'then throws FailureException naming the setting', () {
      expect(
        () => readUsesNonExemptEncryption(appDirectory()),
        throwsA(
          isA<FailureException>().having(
            (e) => e.errors.single,
            'error',
            'The app does not declare whether it uses encryption.',
          ),
        ),
      );
    });
  });

  group('Given an iOS app whose Info.plist comments out true and sets '
      'ITSAppUsesNonExemptEncryption to false', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner', [
            d.file('Info.plist', '''
<plist version="1.0">
<dict>
	<!-- <key>ITSAppUsesNonExemptEncryption</key><true/> -->
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
</dict>
</plist>
'''),
          ]),
        ]),
      ]).create();
    });

    test(
      'when reading the export compliance setting then false is returned',
      () {
        expect(readUsesNonExemptEncryption(appDirectory()), isFalse);
      },
    );
  });

  group('Given an iOS app whose Info.plist has CRLF line endings and '
      'comments out true before setting false', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner', [
            d.file(
              'Info.plist',
              '''
<plist version="1.0">
<dict>
	<!--
	<key>ITSAppUsesNonExemptEncryption</key>
	<true/>
	-->
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
</dict>
</plist>
'''
                  .replaceAll('\n', '\r\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    test(
      'when reading the export compliance setting then false is returned',
      () {
        expect(readUsesNonExemptEncryption(appDirectory()), isFalse);
      },
    );
  });

  group('Given an iOS app without an Info.plist', () {
    setUp(() async {
      await d.dir('app', [ProjectFactory.flutterIosDir()]).create();
    });

    test('when reading the export compliance setting '
        'then throws FailureException naming the missing file', () {
      expect(
        () => readUsesNonExemptEncryption(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'ios/Runner/Info.plist is missing.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app with the icon of flutter create', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(withDefaultAppIcon: true),
      ]).create();
    });

    test('when checking for the default app icon then true is returned', () {
      expect(hasDefaultAppIcon(appDirectory(), FlutterPlatform.android), true);
    });
  });

  group('Given an iOS app with the icon of flutter create', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(withDefaultAppIcon: true),
      ]).create();
    });

    test('when checking for the default app icon then true is returned', () {
      expect(hasDefaultAppIcon(appDirectory(), FlutterPlatform.ios), true);
    });
  });

  group('Given an Android app with its own icon', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.dir('src', [
              d.dir('main', [
                d.dir('res', [
                  d.dir('mipmap-mdpi', [
                    d.file('ic_launcher.png', [0x89, 0x50, 0x4e, 0x47]),
                  ]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]).create();
    });

    test('when checking for the default app icon then false is returned', () {
      expect(hasDefaultAppIcon(appDirectory(), FlutterPlatform.android), false);
    });
  });

  group('Given an iOS app without app icon files', () {
    setUp(() async {
      await d.dir('app', [ProjectFactory.flutterIosDir()]).create();
    });

    test('when checking for the default app icon then false is returned', () {
      expect(hasDefaultAppIcon(appDirectory(), FlutterPlatform.ios), false);
    });
  });
}

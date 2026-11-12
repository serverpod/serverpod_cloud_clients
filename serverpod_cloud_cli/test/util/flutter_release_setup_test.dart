import 'dart:io';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
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

  group('Given a Groovy Android app module that reads the keystore from '
      'the environment map without checking SERVERPOD_APP_BUILD', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
android {
    signingConfigs {
        release {
            keyAlias = System.getenv()["ANDROID_KEY_ALIAS"]
            keyPassword = System.getenv()["ANDROID_KEY_PASSWORD"]
            storeFile = file(System.getenv()["ANDROID_KEYSTORE_PATH"])
            storePassword = System.getenv()["ANDROID_KEYSTORE_PASSWORD"]
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
        'then throws FailureException naming SERVERPOD_APP_BUILD', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle does not read SERVERPOD_APP_BUILD from '
                'the environment.',
          ]),
        ),
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
                'android/app/build.gradle.kts signs release builds with the '
                    'debug key.',
              ])
              .having(
                (e) => e.hint,
                'hint',
                'Android release signing is managed by Serverpod Cloud. '
                    'Follow this link to set it up for your project.\n'
                    '$androidReleaseSigningDocsUrl',
              ),
        ),
      );
    });
  });

  group('Given an Android app module with no release build type', () {
    setUp(() async {
      await d.dir('app', [ProjectFactory.flutterAndroidDir()]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying release builds are not signed '
        'with the release signing config', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle.kts does not sign release builds with '
                'the release signing config.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module whose release signing is commented '
      'out', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    buildTypes {
        release {
            // signingConfig = signingConfigs.getByName("release")
        }
    }
''',
        ),
      ]).create();
    });

    test('when checking the release signing '
        'then throws FailureException saying release builds are not signed '
        'with the release signing config', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle.kts does not sign release builds with '
                'the release signing config.',
          ]),
        ),
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
        'then throws FailureException naming every unread variable', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle.kts does not read SERVERPOD_APP_BUILD '
                'from the environment.',
            'The release signing config in android/app/build.gradle.kts does '
                'not read ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, '
                'ANDROID_KEY_ALIAS and ANDROID_KEY_PASSWORD from the '
                'environment.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that signs release builds with the '
      'keystore from the environment on every build', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
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
        'then throws FailureException naming SERVERPOD_APP_BUILD', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle.kts does not read SERVERPOD_APP_BUILD '
                'from the environment.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module whose release build type sets the '
      'release signing config and then the debug one', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            signingConfig = signingConfigs.getByName("debug")
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
            'android/app/build.gradle.kts signs release builds with the '
                'debug key.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that reads the keystore variables '
      'outside its release signing config', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    val isServerpodCloudBuild = System.getenv("SERVERPOD_APP_BUILD") != null
    val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
    val keystorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
    val keyAlias = System.getenv("ANDROID_KEY_ALIAS")
    val keyPassword = System.getenv("ANDROID_KEY_PASSWORD")

    signingConfigs {
        create("release") {
            storeFile = file("local.keystore")
            storePassword = "local"
            keyAlias = "local"
            keyPassword = "local"
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
        'then throws FailureException naming the unread variables', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The release signing config in android/app/build.gradle.kts does '
                'not read ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, '
                'ANDROID_KEY_ALIAS and ANDROID_KEY_PASSWORD from the '
                'environment.',
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
        'then throws FailureException saying release builds are not signed '
        'with the release signing config', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle.kts does not sign release builds with '
                'the release signing config.',
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
            'android/app/build.gradle.kts signs release builds with the '
                'debug key.',
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

  group('Given an Android app module whose release build type reads its '
      'signing config after setting the release one', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          releaseSigning: '''
    signingConfigs {
        create("release") {
            if (System.getenv("SERVERPOD_APP_BUILD") != null) {
                storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            println(signingConfig)
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

  group('Given a Kotlin app module that uses the debug key, with the release '
      'one in a trailing comment and CRLF line endings', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file(
              'build.gradle.kts',
              '''
android {
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // signingConfig = signingConfigs.getByName("release")
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
        'then throws FailureException saying it uses the debug key', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'android/app/build.gradle.kts signs release builds with the '
                'debug key.',
          ]),
        ),
      );
    });
  });

  group('Given an app without an Android app module', () {
    setUp(() async {
      await d.dir('app', [d.dir('android')]).create();
    });

    test('when checking the release signing '
        'then throws FailureException naming the missing files', () {
      expect(
        () => checkAndroidReleaseSigning(appDirectory()),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The Android release signing was not found: '
                'android/app/build.gradle.kts and android/app/build.gradle '
                'are missing.',
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
                startsWith(
                  'ios/Runner/Info.plist does not set '
                  'ITSAppUsesNonExemptEncryption',
                ),
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
            startsWith(
              'ios/Runner/Info.plist does not set '
              'ITSAppUsesNonExemptEncryption',
            ),
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
            'The export compliance setting was not found: '
                'ios/Runner/Info.plist is missing.',
          ]),
        ),
      );
    });
  });
}

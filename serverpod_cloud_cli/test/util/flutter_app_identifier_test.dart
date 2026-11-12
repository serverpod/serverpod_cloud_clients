import 'dart:io';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../test_utils/project_factory.dart';

void main() {
  Directory appDirectory() => Directory(d.path('app'));

  group('Given an iOS project as flutter create lays it out', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(bundleId: 'com.acme.app'),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then the bundle ID of the app target is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        'com.acme.app',
      );
    });
  });

  group("Given an iOS project with Flutter's placeholder bundle ID", () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(bundleId: 'com.example.app'),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then throws FailureException naming the file to change', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            "The iOS bundle ID com.example.app is Flutter's placeholder: "
                'ios/Runner.xcodeproj/project.pbxproj sets '
                'PRODUCT_BUNDLE_IDENTIFIER to it.',
          ]),
        ),
      );
    });
  });

  group('Given an iOS project with a quoted bundle ID', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner.xcodeproj', [
            d.file('project.pbxproj', '''
buildSettings = {
	INFOPLIST_FILE = "Runner/Info.plist";
	PRODUCT_BUNDLE_IDENTIFIER = "com.acme.app";
};
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then the bundle ID is returned without quotes', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        'com.acme.app',
      );
    });
  });

  group('Given an iOS project with a braced variable in its app build '
      'settings', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner.xcodeproj', [
            d.file('project.pbxproj', r'''
buildSettings = {
	HEADER_SEARCH_PATHS = "${PODS_ROOT}/Headers";
	INFOPLIST_FILE = Runner/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = com.acme.app;
};
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then the bundle ID is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        'com.acme.app',
      );
    });
  });

  group('Given an iOS project that takes its bundle ID from a braced '
      'variable', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner.xcodeproj', [
            d.file('project.pbxproj', r'''
buildSettings = {
	INFOPLIST_FILE = Runner/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = "${APP_BUNDLE_ID}";
};
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then throws FailureException naming the variable', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            r'The iOS bundle ID could not be read: '
                r'ios/Runner.xcodeproj/project.pbxproj sets '
                r'PRODUCT_BUNDLE_IDENTIFIER to "${APP_BUNDLE_ID}", '
                r'which comes from a variable.',
          ]),
        ),
      );
    });
  });

  group('Given an iOS project with a bundle ID per flavor', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner.xcodeproj', [
            d.file('project.pbxproj', '''
buildSettings = {
	INFOPLIST_FILE = Runner/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = com.acme.app.dev;
};
buildSettings = {
	INFOPLIST_FILE = Runner/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = com.acme.app;
};
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then throws FailureException naming both bundle IDs', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The iOS bundle ID is ambiguous: '
                'ios/Runner.xcodeproj/project.pbxproj sets '
                'PRODUCT_BUNDLE_IDENTIFIER to com.acme.app.dev, '
                'com.acme.app.',
          ]),
        ),
      );
    });

    test('when reading the iOS app identifier '
        'then the hint offers setting it in scloud.yaml', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        throwsA(
          isA<FailureException>().having(
            (e) => e.hint,
            'hint',
            'Publishing needs one iOS bundle ID for the app, or set '
                'project.appIdentifiers.ios in scloud.yaml.',
          ),
        ),
      );
    });
  });

  group('Given an iOS project with a notification service extension', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner.xcodeproj', [
            d.file('project.pbxproj', '''
buildSettings = {
	INFOPLIST_FILE = Runner/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = com.acme.app;
};
buildSettings = {
	INFOPLIST_FILE = NotificationService/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = com.acme.app.NotificationService;
};
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then the bundle ID of the app target is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        'com.acme.app',
      );
    });
  });

  group('Given an iOS project that takes its bundle ID from a variable', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [
          d.dir('Runner.xcodeproj', [
            d.file('project.pbxproj', r'''
buildSettings = {
	INFOPLIST_FILE = Runner/Info.plist;
	PRODUCT_BUNDLE_IDENTIFIER = "$(APP_BUNDLE_ID)";
};
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then throws FailureException with a hint to set it', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        throwsA(
          isA<FailureException>().having(
            (e) => e.hint,
            'hint',
            'Set PRODUCT_BUNDLE_IDENTIFIER in '
                'ios/Runner.xcodeproj/project.pbxproj to the iOS bundle ID '
                'itself, or set project.appIdentifiers.ios in scloud.yaml.',
          ),
        ),
      );
    });
  });

  group('Given an app without an Xcode project', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('ios', [d.file('Podfile', '')]),
      ]).create();
    });

    test('when reading the iOS app identifier '
        'then throws FailureException naming the missing project', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.ios),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The iOS bundle ID was not found: '
                'ios/Runner.xcodeproj/project.pbxproj is missing.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module with a Kotlin build file', () {
    setUp(() async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(applicationId: 'com.acme.app'),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then the application ID is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.android),
        'com.acme.app',
      );
    });
  });

  group('Given an Android app module with a Groovy build file', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
android {
    defaultConfig {
        applicationId "com.acme.app"
    }
    buildTypes {
        debug {
            applicationIdSuffix ".debug"
        }
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then the application ID without its suffix is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.android),
        'com.acme.app',
      );
    });
  });

  group('Given an Android app module with an applicationId manifest '
      'placeholder', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle.kts', '''
android {
    defaultConfig {
        applicationId = "com.acme.app"
        manifestPlaceholders["applicationId"] = "com.acme.app"
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then the application ID is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.android),
        'com.acme.app',
      );
    });
  });

  group('Given an Android app module that takes its applicationId from a '
      'variable', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', r'''
android {
    defaultConfig {
        applicationId "${appId}"
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then throws FailureException naming the variable', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.android),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            r'The Android package name could not be read: '
                r'android/app/build.gradle sets applicationId to "${appId}", '
                r'which comes from a variable.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that sets applicationId to an unquoted '
      'variable', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle.kts', '''
android {
    defaultConfig {
        applicationId = appId
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then throws FailureException naming the value', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.android),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The Android package name could not be read: '
                'android/app/build.gradle.kts sets applicationId to appId, '
                'which is not a quoted value.',
          ]),
        ),
      );
    });

    test('when reading the Android app identifier '
        'then the hint offers setting it in scloud.yaml', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.android),
        throwsA(
          isA<FailureException>().having(
            (e) => e.hint,
            'hint',
            'Set applicationId in android/app/build.gradle.kts to the '
                'Android package name itself, or set '
                'project.appIdentifiers.android in scloud.yaml.',
          ),
        ),
      );
    });
  });

  group('Given an Android app module with a Groovy build file that sets '
      'applicationId to a project property', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle', '''
android {
    defaultConfig {
        applicationId project.property("APP_ID")
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then throws FailureException naming the value', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.android),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The Android package name could not be read: '
                'android/app/build.gradle sets applicationId to '
                'project.property("APP_ID"), which is not a quoted value.',
          ]),
        ),
      );
    });
  });

  group('Given an Android app module that compares applicationId', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle.kts', '''
android {
    defaultConfig {
        applicationId = "com.acme.app"
        if (applicationId == "com.acme.app") {
            versionNameSuffix = "-acme"
        }
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then the application ID is returned', () {
      expect(
        readAppIdentifier(appDirectory(), FlutterPlatform.android),
        'com.acme.app',
      );
    });
  });

  group('Given an Android app module whose applicationId is commented out', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [
          d.dir('app', [
            d.file('build.gradle.kts', '''
android {
    defaultConfig {
        // applicationId = "com.acme.app"
    }
}
'''),
          ]),
        ]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then throws FailureException with a hint to set it', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.android),
        throwsA(
          isA<FailureException>()
              .having((e) => e.errors, 'errors', [
                'The Android package name was not found: '
                    'android/app/build.gradle.kts sets no applicationId.',
              ])
              .having(
                (e) => e.hint,
                'hint',
                'Set applicationId for the app in '
                    'android/app/build.gradle.kts, or set '
                    'project.appIdentifiers.android in scloud.yaml.',
              ),
        ),
      );
    });
  });

  group('Given an Android directory without an app module', () {
    setUp(() async {
      await d.dir('app', [
        d.dir('android', [d.file('build.gradle.kts', '')]),
      ]).create();
    });

    test('when reading the Android app identifier '
        'then throws FailureException naming the build files', () {
      expect(
        () => readAppIdentifier(appDirectory(), FlutterPlatform.android),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The Android package name was not found: '
                'android/app/build.gradle.kts and '
                'android/app/build.gradle are missing.',
          ]),
        ),
      );
    });
  });

  group('Given a blank Android package name configured in scloud.yaml', () {
    setUp(() async {
      await d.dir('app', [ProjectFactory.flutterAndroidDir()]).create();
    });

    test('when resolving the Android app identifier '
        'then throws FailureException saying it is empty', () {
      expect(
        () => resolveAppIdentifier(
          appDirectory(),
          FlutterPlatform.android,
          configured: '  ',
          configFileName: 'scloud.yaml',
        ),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'scloud.yaml sets project.appIdentifiers.android to an empty '
                'value.',
          ]),
        ),
      );
    });
  });
}

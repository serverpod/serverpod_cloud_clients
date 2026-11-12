import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_sdk_selector.dart';
import 'package:test/test.dart';

void main() {
  group('Given no requested Flutter version', () {
    test('when selecting then null is returned', () {
      expect(FlutterSdkSelector.selectFlutterVersion(), isNull);
    });

    test('when selecting with a lockfile constraint then null is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          lockVersionConstraint: '>=3.38.0',
        ),
        isNull,
      );
    });
  });

  group('Given several requested Flutter versions', () {
    test('when selecting then the command line version wins', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.38.4',
          scloudVersion: '3.38.3',
          toolVersionsVersion: '3.38.2',
          pubspecVersionConstraint: '3.38.1',
        ),
        '3.38.4',
      );
    });

    test('when selecting without a command line version '
        'then the scloud.yaml version wins', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          scloudVersion: '3.38.3',
          toolVersionsVersion: '3.38.2',
          pubspecVersionConstraint: '3.38.1',
        ),
        '3.38.3',
      );
    });

    test('when selecting with .tool-versions and pubspec.yaml versions '
        'then the .tool-versions version wins', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          toolVersionsVersion: '3.38.2',
          pubspecVersionConstraint: '3.38.1',
        ),
        '3.38.2',
      );
    });

    test('when selecting with a blank command line version '
        'then the next source is used', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: ' ',
          scloudVersion: '3.38.3',
        ),
        '3.38.3',
      );
    });
  });

  group('Given a pubspec.yaml Flutter SDK constraint', () {
    test('when selecting a single version then the version is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          pubspecVersionConstraint: '3.38.1',
        ),
        '3.38.1',
      );
    });

    test('when selecting a range then null is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          pubspecVersionConstraint: '>=3.38.0',
        ),
        isNull,
      );
    });

    test('when selecting a caret range then null is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          pubspecVersionConstraint: '^3.38.0',
        ),
        isNull,
      );
    });

    test('when selecting a pinned version that satisfies the lockfile '
        'constraint then the version is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          pubspecVersionConstraint: '3.38.1',
          lockVersionConstraint: '>=3.38.0',
        ),
        '3.38.1',
      );
    });

    test('when selecting a pinned pre-release version '
        'then FailureException names the version and pubspec.yaml', () {
      expect(
        () => FlutterSdkSelector.selectFlutterVersion(
          pubspecVersionConstraint: '3.39.0-0.1.pre',
        ),
        throwsA(
          isA<FailureException>().having(
            (e) => e.errors,
            'errors',
            contains(
              'Unsupported Flutter version "3.39.0-0.1.pre" (from pubspec.yaml).',
            ),
          ),
        ),
      );
    });

    test('when selecting a pinned version below the lockfile constraint '
        'then FailureException is thrown', () {
      expect(
        () => FlutterSdkSelector.selectFlutterVersion(
          pubspecVersionConstraint: '3.35.7',
          lockVersionConstraint: '>=3.38.0',
        ),
        throwsA(isA<FailureException>()),
      );
    });
  });

  group('Given an asdf Flutter version with the stable suffix', () {
    test('when selecting then the version without the suffix is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          toolVersionsVersion: '3.38.4-stable',
        ),
        '3.38.4',
      );
    });
  });

  group('Given a requested Flutter version that is not a release version', () {
    for (final invalid in [
      'stable',
      'beta',
      '3.39.0-0.1.pre',
      '3.39.0-0.1.pre-beta',
      'v3.38.4',
      '^3.38.0',
      '3.38',
      '12345.0.0',
    ]) {
      test('when selecting "$invalid" '
          'then FailureException names the value and its source', () {
        expect(
          () => FlutterSdkSelector.selectFlutterVersion(scloudVersion: invalid),
          throwsA(
            isA<FailureException>().having(
              (e) => e.errors,
              'errors',
              contains(
                'Unsupported Flutter version "$invalid" (from scloud.yaml).',
              ),
            ),
          ),
        );
      });
    }
  });

  group('Given a lockfile Flutter SDK constraint', () {
    test('when selecting a version above its lower bound '
        'then the version is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.38.4',
          lockVersionConstraint: '>=3.38.0',
        ),
        '3.38.4',
      );
    });

    test('when selecting the exact exclusive upper bound '
        'then the version is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '4.0.0',
          lockVersionConstraint: '>=3.38.0 <4.0.0',
        ),
        '4.0.0',
      );
    });

    test('when selecting a version above its upper bound '
        'then the version is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '4.1.0',
          lockVersionConstraint: '>=3.38.0 <4.0.0',
        ),
        '4.1.0',
      );
    });

    test('when selecting a version below its lower bound '
        'then FailureException names the version and the constraint', () {
      expect(
        () => FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.35.7',
          lockVersionConstraint: '>=3.38.0',
        ),
        throwsA(
          isA<FailureException>().having(
            (e) => e.errors,
            'errors',
            contains(
              'The Flutter version 3.35.7 (from --flutter-version flag) is '
              'below the Flutter SDK constraint ">=3.38.0" of the app\'s '
              'packages (from pubspec.lock).',
            ),
          ),
        ),
      );
    });

    test('when selecting a version below a pre-release lower bound '
        'then the hint names the first release at the bound', () {
      expect(
        () => FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.16.0',
          lockVersionConstraint: '>=3.18.0-18.0.pre.54',
        ),
        throwsA(
          isA<FailureException>().having(
            (e) => e.hint,
            'hint',
            'Request Flutter 3.18.0 or later, or change the Flutter SDK '
                'constraints of the app.',
          ),
        ),
      );
    });

    test('when the constraint cannot be parsed '
        'then FailureException is thrown', () {
      expect(
        () => FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.38.4',
          lockVersionConstraint: 'not a constraint',
        ),
        throwsA(isA<FailureException>()),
      );
    });
  });

  group('Given a Flutter version pinned only in .tool-versions', () {
    test(
      'when selecting with its source '
      'then the version comes without its asdf suffix, from .tool-versions',
      () {
        expect(
          FlutterSdkSelector.selectFlutterVersionWithSource(
            toolVersionsVersion: '3.38.1-stable',
            pubspecVersionConstraint: '>=3.29.0',
          ),
          (version: '3.38.1', source: '.tool-versions'),
        );
      },
    );
  });

  group('Given a Flutter version set in a project configuration file with '
      'its own name', () {
    test('when selecting with its source then the file name is the source', () {
      expect(
        FlutterSdkSelector.selectFlutterVersionWithSource(
          scloudVersion: '3.38.3',
          scloudFileName: 'scloud_staging.yaml',
        ),
        (version: '3.38.3', source: 'scloud_staging.yaml'),
      );
    });
  });

  group('Given an app whose pubspec requires Flutter 3.38.0 or later', () {
    test('when selecting a requested version below it '
        'then throws FailureException naming the pubspec constraint', () {
      expect(
        () => FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.35.0',
          pubspecVersionConstraint: '>=3.38.0',
          lockVersionConstraint: '>=3.29.0',
        ),
        throwsA(
          isA<FailureException>().having((e) => e.errors, 'errors', [
            'The Flutter version 3.35.0 (from --flutter-version flag) is '
                'below the Flutter SDK constraint ">=3.38.0" of the app '
                '(from pubspec.yaml).',
          ]),
        ),
      );
    });

    test('when selecting a requested version above it '
        'then the requested version is returned', () {
      expect(
        FlutterSdkSelector.selectFlutterVersion(
          commandLineVersion: '3.38.4',
          pubspecVersionConstraint: '^3.38.0',
        ),
        '3.38.4',
      );
    });
  });
}

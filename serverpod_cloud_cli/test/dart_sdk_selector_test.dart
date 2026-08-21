import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_sdk_selector.dart';
import 'package:test/test.dart';

void main() {
  const supported = ['3.10', '3.11', '3.12', '3.13'];

  group('Given supported Dart SDK versions', () {
    test('when no version source holds a value '
        'then the highest supported version is selected', () {
      expect(
        selectDartSdkVersion(supportedSdkMinorVersions: supported),
        '3.13',
      );
    });

    test('when the supported versions are unordered '
        'then the highest supported version is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: ['3.13', '3.9', '3.11'],
        ),
        '3.13',
      );
    });

    test('when no version is supported '
        'then FailureException states that the fault is not the project', () {
      expect(
        () => selectDartSdkVersion(supportedSdkMinorVersions: []),
        throwsA(
          isA<FailureException>().having(
            (final e) => e.hint,
            'hint',
            contains('not with your project'),
          ),
        ),
      );
    });
  });

  group('Given a requested version', () {
    test('when it is a bare minor version '
        'then that minor version is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '3.11',
        ),
        '3.11',
      );
    });

    test('when it is a patch version '
        'then its minor version is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '3.11.4',
        ),
        '3.11',
      );
    });

    test('when it is a range '
        'then the highest supported version in it is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '>=3.10.0 <3.12.0',
        ),
        '3.11',
      );
    });

    test('when no supported version satisfies it '
        'then FailureException lists the available versions', () {
      expect(
        () => selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '3.9',
        ),
        throwsA(
          isA<FailureException>().having(
            (final e) => e.errors.join(),
            'errors',
            allOf(
              contains('3.9 (from --dart-version flag)'),
              contains('Available Dart SDK versions: 3.10, 3.11, 3.12, 3.13.'),
            ),
          ),
        ),
      );
    });

    test('when it cannot be parsed '
        'then FailureException names the source', () {
      expect(
        () => selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          scloudVersion: 'not-a-version',
        ),
        throwsA(
          isA<FailureException>().having(
            (final e) => e.errors.join(),
            'errors',
            contains('"not-a-version" (from scloud.yaml)'),
          ),
        ),
      );
    });
  });

  group('Given several version sources', () {
    test('when the command line holds a version '
        'then it takes precedence over the other sources', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '3.11',
          scloudVersion: '3.12',
          toolVersionsVersion: '3.13',
          pubspecVersionConstraint: '>=3.13.0 <4.0.0',
        ),
        '3.11',
      );
    });

    test('when the command line value is blank '
        'then scloud.yaml takes precedence over the lower sources', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '  ',
          scloudVersion: '3.12',
          toolVersionsVersion: '3.13',
        ),
        '3.12',
      );
    });

    test('when only .tool-versions and the pubspec hold a version '
        'then .tool-versions takes precedence', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          toolVersionsVersion: '3.11.2',
          pubspecVersionConstraint: '>=3.13.0 <4.0.0',
        ),
        '3.11',
      );
    });

    test('when only the pubspec holds a version '
        'then the highest supported version it allows is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          pubspecVersionConstraint: '>=3.10.0 <3.12.0',
        ),
        '3.11',
      );
    });
  });

  group('Given a lockfile constraint', () {
    test('when a requested version satisfies it '
        'then the requested version is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '3.12',
          lockVersionConstraint: '>=3.11.0 <4.0.0',
        ),
        '3.12',
      );
    });

    test('when it narrows the requested range '
        'then the highest version both allow is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          pubspecVersionConstraint: '>=3.10.0 <4.0.0',
          lockVersionConstraint: '>=3.10.0 <3.12.0',
        ),
        '3.11',
      );
    });

    test('when the requested version violates it '
        'then FailureException names both sources', () {
      expect(
        () => selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          commandLineVersion: '3.13',
          lockVersionConstraint: '>=3.10.0 <3.12.0',
        ),
        throwsA(
          isA<FailureException>().having(
            (final e) => e.errors.join(),
            'errors',
            allOf(
              contains('3.13 (from --dart-version flag)'),
              contains('>=3.10.0 <3.12.0 (from pubspec.lock)'),
            ),
          ),
        ),
      );
    });

    test('when no version source holds a value '
        'then the highest supported version it allows is selected', () {
      expect(
        selectDartSdkVersion(
          supportedSdkMinorVersions: supported,
          lockVersionConstraint: '>=3.10.0 <3.13.0',
        ),
        '3.12',
      );
    });
  });
}

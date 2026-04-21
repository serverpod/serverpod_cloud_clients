import 'dart:io';

import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('ensureValidVersionConstraint', () {
    test('Given concrete versions and pub constraints '
        'when ensureValidVersionConstraint is called '
        'then it completes normally', () {
      for (final s in [
        '3.9.0',
        VersionConstants.minSupportedSdkVersion,
        '3.7.0',
        '3.12.0',
        '^3.10.0',
        '>=3.9.0 <4.0.0',
      ]) {
        expect(() => ensureValidVersionConstraint(s), returnsNormally);
      }
    });

    test('Given a non-parseable string '
        'when ensureValidVersionConstraint is called '
        'then FailureException is thrown', () {
      expect(
        () => ensureValidVersionConstraint('not-a-version'),
        throwsA(isA<FailureException>()),
      );
    });

    test('Given a non-parseable string '
        'when ensureValidVersionConstraint is called '
        'then the hint references the Dart SDK docs', () {
      try {
        ensureValidVersionConstraint('oops');
        fail('Expected FailureException');
      } on FailureException catch (e) {
        expect(e.hint, contains('Use a valid pub-style constraint'));
      }
    });
  });

  group('ProjectDartVersionHint.resolveDartVersionForDeploy', () {
    test('Given a non-blank override and other sources '
        'when resolveDartVersionForDeploy is called '
        'then the override is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: '^3.9.0',
          configDartSdk: '>=3.10.0 <4.0.0',
          lazyVersionSources: [() => '3.9.5', () => '^3.8.0'],
        ),
        '^3.9.0',
      );
    });

    test('Given a blank override and a config value '
        'when resolveDartVersionForDeploy is called '
        'then the config value is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: '   ',
          configDartSdk: '^3.10.0',
          lazyVersionSources: [() => '3.9.0', () => '^3.8.0'],
        ),
        '^3.10.0',
      );
    });

    test('Given null override and null config and first lazy source empty '
        'when resolveDartVersionForDeploy is called '
        'then pubspec environment.sdk is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: null,
          configDartSdk: null,
          lazyVersionSources: [() => null, () => '^3.9.2'],
        ),
        '^3.9.2',
      );
    });

    test('Given only first lazy source '
        'when resolveDartVersionForDeploy is called '
        'then that value is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: null,
          configDartSdk: null,
          lazyVersionSources: [() => '3.9.5', () => '^3.8.0'],
        ),
        '3.9.5',
      );
    });

    test('Given config and lazy tool-versions '
        'when resolveDartVersionForDeploy is called '
        'then config wins', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: null,
          configDartSdk: '^3.10.0',
          lazyVersionSources: [() => '3.9.5', () => '^3.8.0'],
        ),
        '^3.10.0',
      );
    });

    test('Given first lazy source returns non-null '
        'when resolveDartVersionForDeploy is called '
        'then second lazy source is not invoked', () {
      var secondCalled = false;
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: null,
          configDartSdk: null,
          lazyVersionSources: [
            () => '3.9.1',
            () {
              secondCalled = true;
              return '^3.8.0';
            },
          ],
        ),
        '3.9.1',
      );
      expect(secondCalled, isFalse);
    });

    test('Given all lazy sources null '
        'when resolveDartVersionForDeploy is called '
        'then null is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: null,
          configDartSdk: null,
          lazyVersionSources: [() => null, () => null],
        ),
        isNull,
      );
    });

    test('Given an unparseable override '
        'when resolveDartVersionForDeploy is called '
        'then FailureException is thrown', () {
      expect(
        () => ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: 'not-a-constraint',
          configDartSdk: null,
          lazyVersionSources: const [],
        ),
        throwsA(isA<FailureException>()),
      );
    });

    test('Given a parseable override outside the Cloud-supported range '
        'when resolveDartVersionForDeploy is called '
        'then the override is still returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: '3.7.0',
          configDartSdk: null,
          lazyVersionSources: const [],
        ),
        '3.7.0',
      );
    });

    test('Given override "3.8" (major.minor only) '
        'when resolveDartVersionForDeploy is called '
        'then 3.8.0 is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: '3.8',
          configDartSdk: null,
          lazyVersionSources: const [],
        ),
        '3.8.0',
      );
    });

    test('Given override "  3.10  " (major.minor only) '
        'when resolveDartVersionForDeploy is called '
        'then normalized version is returned', () {
      expect(
        ProjectDartVersionHint.resolveDartVersionForDeploy(
          override: '  3.10  ',
          configDartSdk: null,
          lazyVersionSources: const [],
        ),
        '3.10.0',
      );
    });
  });

  group('resolveProjectDartSdkVersion', () {
    late Directory emptyDir;

    setUpAll(() async {
      await d.dir('empty_init').create();
      emptyDir = Directory(d.path('empty_init'));
    });

    test('Given no .tool-versions and no pubspec.yaml '
        'when resolveProjectDartSdkVersion is called '
        'then it returns minSupportedSdkVersion', () {
      final result = resolveProjectDartSdkVersion(emptyDir);
      expect(result, equals(VersionConstants.minSupportedSdkVersion));
    });

    test('Given .tool-versions with a dart entry '
        'when resolveProjectDartSdkVersion is called '
        'then that version string is returned', () async {
      await d.dir('init_tv', [
        d.file('.tool-versions', 'dart 3.9.2\n'),
      ]).create();
      final dir = Directory(d.path('init_tv'));

      final result = resolveProjectDartSdkVersion(dir);
      expect(result, equals('3.9.2'));
    });

    test(
      'Given .tool-versions without dart and pubspec.yaml with sdk constraint '
      'when resolveProjectDartSdkVersion is called '
      'then the pubspec environment.sdk constraint is returned',
      () async {
        await d.dir('init_pubspec', [
          d.file('.tool-versions', 'flutter 3.19.0\n'),
          d.file('pubspec.yaml', '''
name: my_server
environment:
  sdk: ">=3.9.0 <4.0.0"
'''),
        ]).create();
        final dir = Directory(d.path('init_pubspec'));

        final result = resolveProjectDartSdkVersion(dir);
        expect(result, equals('>=3.9.0 <4.0.0'));
      },
    );

    test(
      'Given pubspec.yaml with sdk constraint below the Cloud-supported floor '
      'when resolveProjectDartSdkVersion is called '
      'then that environment.sdk constraint is still returned',
      () async {
        await d.dir('init_below_range', [
          d.file('pubspec.yaml', '''
name: my_server
environment:
  sdk: ">=3.0.0 <4.0.0"
'''),
        ]).create();
        final dir = Directory(d.path('init_below_range'));

        final result = resolveProjectDartSdkVersion(dir);
        expect(result, equals('>=3.0.0 <4.0.0'));
      },
    );

    test('Given .tool-versions and pubspec.yaml '
        'when resolveProjectDartSdkVersion is called '
        'then .tool-versions takes precedence', () async {
      await d.dir('init_priority', [
        d.file('.tool-versions', 'dart 3.9.5\n'),
        d.file('pubspec.yaml', '''
name: my_server
environment:
  sdk: ">=3.8.0 <4.0.0"
'''),
      ]).create();
      final dir = Directory(d.path('init_priority'));

      final result = resolveProjectDartSdkVersion(dir);
      expect(result, equals('3.9.5'));
    });

    test('Given .tool-versions with an invalid dart version '
        'when resolveProjectDartSdkVersion is called '
        'then FailureException is thrown', () async {
      await d.dir('init_invalid_tv', [
        d.file('.tool-versions', 'dart not-a-version\n'),
      ]).create();
      final dir = Directory(d.path('init_invalid_tv'));

      expect(
        () => resolveProjectDartSdkVersion(dir),
        throwsA(isA<FailureException>()),
      );
    });
  });
}

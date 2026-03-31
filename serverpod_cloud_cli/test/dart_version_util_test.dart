import 'dart:io';

import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('validateDartVersion -', () {
    test(
      'Given a valid version within supported range then does not throw',
      () {
        expect(() => validateDartVersion('3.9.0'), returnsNormally);
      },
    );

    test('Given the minimum supported version then does not throw', () {
      expect(
        () => validateDartVersion(VersionConstants.minSupportedSdkVersion),
        returnsNormally,
      );
    });

    test('Given the maximum supported version then does not throw', () {
      expect(() => validateDartVersion('3.10.99'), returnsNormally);
    });

    test('Given a malformed version string then throws FailureException', () {
      expect(
        () => validateDartVersion('not-a-version'),
        throwsA(isA<FailureException>()),
      );
    });

    test(
      'Given a version below the supported range then throws FailureException',
      () {
        expect(
          () => validateDartVersion('3.7.0'),
          throwsA(isA<FailureException>()),
        );
      },
    );

    test(
      'Given a version above the supported range then throws FailureException',
      () {
        expect(
          () => validateDartVersion('3.11.0'),
          throwsA(isA<FailureException>()),
        );
      },
    );

    test(
      'Given an out-of-range version then error message contains doc link',
      () {
        try {
          validateDartVersion('3.7.0');
          fail('Expected FailureException');
        } on FailureException catch (e) {
          expect(e.hint, contains('docs.serverpod.cloud'));
        }
      },
    );
  });

  group('resolveProjectDartSdkVersion -', () {
    late Directory emptyDir;

    setUpAll(() async {
      await d.dir('empty_init').create();
      emptyDir = Directory(d.path('empty_init'));
    });

    test(
      'Given no .tool-versions and no pubspec.yaml then returns minSupportedSdkVersion',
      () {
        final result = resolveProjectDartSdkVersion(emptyDir);
        expect(result, equals(VersionConstants.minSupportedSdkVersion));
      },
    );

    test(
      'Given .tool-versions with dart entry then uses that version',
      () async {
        await d.dir('init_tv', [
          d.file('.tool-versions', 'dart 3.9.2\n'),
        ]).create();
        final dir = Directory(d.path('init_tv'));

        final result = resolveProjectDartSdkVersion(dir);
        expect(result, equals('3.9.2'));
      },
    );

    test(
      'Given .tool-versions without dart entry and pubspec.yaml with sdk constraint then uses pubspec min',
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
        expect(result, equals('3.9.0'));
      },
    );

    test(
      'Given pubspec.yaml with sdk constraint below supported range then uses minSupportedSdkVersion',
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
        expect(result, equals(VersionConstants.minSupportedSdkVersion));
      },
    );

    test('Given .tool-versions takes precedence over pubspec.yaml', () async {
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

    test(
      'Given .tool-versions with invalid dart version then throws FailureException',
      () async {
        await d.dir('init_invalid_tv', [
          d.file('.tool-versions', 'dart not-a-version\n'),
        ]).create();
        final dir = Directory(d.path('init_invalid_tv'));

        expect(
          () => resolveProjectDartSdkVersion(dir),
          throwsA(isA<FailureException>()),
        );
      },
    );
  });
}

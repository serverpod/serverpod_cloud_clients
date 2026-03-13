import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/commands/deploy/dart_version_resolver.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  late Directory emptyDir;

  setUpAll(() async {
    await d.dir('empty').create();
    emptyDir = Directory(d.path('empty'));
  });

  VersionConstraint parsePubspecSdk(final String constraint) {
    return VersionConstraint.parse(constraint);
  }

  group('DartVersionResolver.resolve -', () {
    group('resolution order -', () {
      test(
        'Given cliOverride and scloudDartVersion when resolving '
        'then cliOverride wins',
        () {
          final result = DartVersionResolver.resolve(
            rootDirectory: emptyDir,
            pubspecSdkConstraint: parsePubspecSdk('>=3.8.0 <4.0.0'),
            cliOverride: '3.10.0',
            scloudDartVersion: '3.9.0',
          );

          expect(result, equals('3.10.0'));
        },
      );

      test(
        'Given scloudDartVersion but no cliOverride when resolving '
        'then scloudDartVersion wins',
        () {
          final result = DartVersionResolver.resolve(
            rootDirectory: emptyDir,
            pubspecSdkConstraint: parsePubspecSdk('>=3.8.0 <4.0.0'),
            cliOverride: null,
            scloudDartVersion: '3.9.0',
          );

          expect(result, equals('3.9.0'));
        },
      );

      test(
        'Given .tool-versions with dart but no explicit overrides when resolving '
        'then tool-versions version is used',
        () async {
          await d.dir('project_tv', [
            d.file('.tool-versions', 'dart 3.9.2\n'),
          ]).create();
          final dir = Directory(d.path('project_tv'));

          final result = DartVersionResolver.resolve(
            rootDirectory: dir,
            pubspecSdkConstraint: parsePubspecSdk('>=3.8.0 <4.0.0'),
            cliOverride: null,
            scloudDartVersion: null,
          );

          expect(result, equals('3.9.2'));
        },
      );

      test(
        'Given no explicit overrides and no .tool-versions when resolving '
        'then pubspec constraint minimum is used',
        () {
          final result = DartVersionResolver.resolve(
            rootDirectory: emptyDir,
            pubspecSdkConstraint: parsePubspecSdk('>=3.9.0 <4.0.0'),
            cliOverride: null,
            scloudDartVersion: null,
          );

          expect(result, equals('3.9.0'));
        },
      );

      test(
        'Given no overrides and pubspec constraint starts below supported range '
        'when resolving then supported minimum is used',
        () {
          final result = DartVersionResolver.resolve(
            rootDirectory: emptyDir,
            pubspecSdkConstraint: parsePubspecSdk('>=3.0.0 <4.0.0'),
            cliOverride: null,
            scloudDartVersion: null,
          );

          expect(result, equals(VersionConstants.minSupportedSdkVersion));
        },
      );

      test(
        'Given no overrides and null pubspec constraint when resolving '
        'then supported minimum is used',
        () {
          final result = DartVersionResolver.resolve(
            rootDirectory: emptyDir,
            pubspecSdkConstraint: null,
            cliOverride: null,
            scloudDartVersion: null,
          );

          expect(result, equals(VersionConstants.minSupportedSdkVersion));
        },
      );

      test(
        'Given cliOverride takes precedence over .tool-versions when resolving '
        'then cliOverride is used',
        () async {
          await d.dir('project_tv2', [
            d.file('.tool-versions', 'dart 3.9.2\n'),
          ]).create();
          final dir = Directory(d.path('project_tv2'));

          final result = DartVersionResolver.resolve(
            rootDirectory: dir,
            pubspecSdkConstraint: parsePubspecSdk('>=3.8.0 <4.0.0'),
            cliOverride: '3.10.0',
            scloudDartVersion: null,
          );

          expect(result, equals('3.10.0'));
        },
      );
    });

    group('validation -', () {
      test(
        'Given an invalid version string when resolving '
        'then throws FailureException',
        () {
          expect(
            () => DartVersionResolver.resolve(
              rootDirectory: emptyDir,
              pubspecSdkConstraint: null,
              cliOverride: 'not-a-version',
            ),
            throwsA(isA<FailureException>()),
          );
        },
      );

      test(
        'Given a version below supported range when resolving '
        'then throws FailureException',
        () {
          expect(
            () => DartVersionResolver.resolve(
              rootDirectory: emptyDir,
              pubspecSdkConstraint: null,
              cliOverride: '3.7.0',
            ),
            throwsA(isA<FailureException>()),
          );
        },
      );

      test(
        'Given a version above supported range when resolving '
        'then throws FailureException',
        () {
          expect(
            () => DartVersionResolver.resolve(
              rootDirectory: emptyDir,
              pubspecSdkConstraint: null,
              cliOverride: '3.11.0',
            ),
            throwsA(isA<FailureException>()),
          );
        },
      );

      test(
        'Given the minimum supported version when resolving '
        'then succeeds',
        () {
          expect(
            () => DartVersionResolver.resolve(
              rootDirectory: emptyDir,
              pubspecSdkConstraint: null,
              cliOverride: VersionConstants.minSupportedSdkVersion,
            ),
            returnsNormally,
          );
        },
      );

      test(
        'Given the maximum supported version when resolving '
        'then succeeds',
        () {
          expect(
            () => DartVersionResolver.resolve(
              rootDirectory: emptyDir,
              pubspecSdkConstraint: null,
              cliOverride: '3.10.99',
            ),
            returnsNormally,
          );
        },
      );
    });
  });
}

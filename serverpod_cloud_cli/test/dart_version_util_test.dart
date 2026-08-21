import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart'
    show ServerpodClientException;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('fetchSupportedDartSdkVersions', () {
    final client = ClientMock();

    setUp(() {
      reset(client.platform);
    });

    test('Given a served policy with supported versions '
        'when fetchSupportedDartSdkVersions is called '
        'then the supported versions are returned', () async {
      when(() => client.platform.getDartSdkVersionPolicy()).thenAnswer(
        (final _) async => DartSdkVersionPolicyBuilder().withSupportedVersions([
          '3.8',
          '3.9',
        ]).build(),
      );

      await expectLater(
        fetchSupportedDartSdkVersions(client),
        completion(['3.8', '3.9']),
      );
    });

    group('Given the policy fetch throws '
        'when fetchSupportedDartSdkVersions is called', () {
      setUp(() {
        when(
          () => client.platform.getDartSdkVersionPolicy(),
        ).thenThrow(ServerpodClientException('connection failed', 500));
      });

      test('then FailureException is thrown', () async {
        await expectLater(
          fetchSupportedDartSdkVersions(client),
          throwsA(isA<FailureException>()),
        );
      });

      test('then the hint states that the fault is not the project', () async {
        await expectLater(
          fetchSupportedDartSdkVersions(client),
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
  });

  group('ensureValidVersionConstraint', () {
    test('Given concrete versions and pub constraints '
        'when ensureValidVersionConstraint is called '
        'then it completes normally', () {
      for (final s in [
        '3.9.0',
        '3.8.0',
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

  group('resolveProjectDartSdkVersion', () {
    late Directory emptyDir;

    setUpAll(() async {
      await d.dir('empty_init').create();
      emptyDir = Directory(d.path('empty_init'));
    });

    test('Given no .tool-versions and no pubspec.yaml '
        'when resolveProjectDartSdkVersion is called '
        'then it returns null', () {
      final result = resolveProjectDartSdkVersion(emptyDir);
      expect(result, isNull);
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

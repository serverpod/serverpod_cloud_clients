import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart'
    show ServerpodClientException;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/test_command_logger.dart';

void main() {
  group('fetchSupportedDartSdkPolicy', () {
    final logger = TestCommandLogger();
    final client = ClientMock();

    setUp(() {
      logger.clear();
      reset(client.platform);
    });

    group('Given a served policy with the range 3.8.0 to 3.13.0 '
        'when fetchSupportedDartSdkPolicy is called', () {
      late SupportedDartSdkPolicy? result;

      setUp(() async {
        when(() => client.platform.getDartSdkVersionPolicy()).thenAnswer(
          (final _) async => DartSdkVersionPolicyBuilder()
              .withMinVersionInclusive('3.8.0')
              .withMaxVersionExclusive('3.13.0')
              .build(),
        );

        result = await fetchSupportedDartSdkPolicy(client, logger: logger);
      });

      test('then the range allows the minimum version', () {
        expect(result?.supportedRange.allows(Version.parse('3.8.0')), isTrue);
      });

      test('then the range denies the version below the minimum', () {
        expect(result?.supportedRange.allows(Version.parse('3.7.9')), isFalse);
      });

      test('then the range allows a version below the maximum', () {
        expect(result?.supportedRange.allows(Version.parse('3.12.5')), isTrue);
      });

      test('then the range denies the maximum version', () {
        expect(result?.supportedRange.allows(Version.parse('3.13.0')), isFalse);
      });
    });

    group('Given a served policy with supported versions '
        'and a documentation url '
        'when fetchSupportedDartSdkPolicy is called', () {
      late SupportedDartSdkPolicy? result;

      setUp(() async {
        when(() => client.platform.getDartSdkVersionPolicy()).thenAnswer(
          (final _) async => DartSdkVersionPolicyBuilder()
              .withSupportedVersions(['3.8', '3.9'])
              .withDocumentationUrl(Uri.parse('https://example.com/dart-sdk'))
              .build(),
        );

        result = await fetchSupportedDartSdkPolicy(client, logger: logger);
      });

      test('then the supported versions are carried over', () {
        expect(result?.supportedVersions, ['3.8', '3.9']);
      });

      test('then the documentation url is carried over', () {
        expect(
          result?.documentationUrl,
          Uri.parse('https://example.com/dart-sdk'),
        );
      });
    });

    test('Given a policy with a minimum above the maximum '
        'when fetchSupportedDartSdkPolicy is called '
        'then null is returned', () async {
      when(() => client.platform.getDartSdkVersionPolicy()).thenAnswer(
        (final _) async => DartSdkVersionPolicyBuilder()
            .withMinVersionInclusive('3.13.0')
            .withMaxVersionExclusive('3.8.0')
            .build(),
      );

      final result = await fetchSupportedDartSdkPolicy(client, logger: logger);

      expect(result, isNull);
    });

    group('Given the policy fetch throws '
        'when fetchSupportedDartSdkPolicy is called', () {
      late SupportedDartSdkPolicy? result;

      setUp(() async {
        when(
          () => client.platform.getDartSdkVersionPolicy(),
        ).thenThrow(ServerpodClientException('connection failed', 500));

        result = await fetchSupportedDartSdkPolicy(client, logger: logger);
      });

      test('then null is returned', () {
        expect(result, isNull);
      });

      test('then no error is logged', () {
        expect(logger.errorCalls, isEmpty);
      });

      test('then no warning is logged', () {
        expect(logger.warningCalls, isEmpty);
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

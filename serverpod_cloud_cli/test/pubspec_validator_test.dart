import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/project_factory.dart';

void main() {
  final supportedSdk = SupportedDartSdkPolicy(
    supportedRange: VersionConstraint.parse('>=3.8.0 <3.12.0'),
    supportedVersions: ['3.8', '3.9', '3.10', '3.11'],
    documentationUrl: Uri.parse(
      'https://docs.serverpod.dev/cloud/reference/dart-sdk-versions',
    ),
  );

  test(
    'Given a pubspec with a serverpod dependency, when the isServerpodServer method is called, then the result is true',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.isServerpodServer();
      expect(result, isTrue);
    },
  );

  test(
    'Given a pubspec without a serverpod dependency, when the isServerpodServer method is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
'''),
      );

      final result = pubspec.isServerpodServer();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec without a sdk constraint, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, contains('No sdk constraint found in package my_project'));
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a too advanced sdk version, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.999.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, isNotEmpty);
      expect(result.first, contains('Unsupported sdk version constraint'));
    },
  );

  group('Given a pubspec with an unsupported sdk version '
      'when the projectDependencyIssues method is called', () {
    late List<String> result;

    setUp(() {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.999.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
    });

    test('then the error lists the available versions', () {
      expect(
        result.first,
        contains('Available Dart SDK versions: 3.8, 3.9, 3.10, 3.11.'),
      );
    });

    test('then the error links the documentation page', () {
      expect(
        result.first,
        contains(
          'See: https://docs.serverpod.dev/cloud/reference/dart-sdk-versions',
        ),
      );
    });
  });

  test(
    'Given a pubspec with a serverpod dependency and sdk version just above the supported range, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '3.12.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(
        result,
        isNotEmpty,
        reason: 'Version was allowed but expected to be rejected',
      );
      expect(result.first, contains('Unsupported sdk version constraint'));
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a too old sdk version, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.1.0 <3.2.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, isNotEmpty);
      expect(result.first, contains('Unsupported sdk version constraint'));
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a too old serverpod version, when the projectDependencyIssues method is called, then the result contains the serverpod error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^2.2.0
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, isNotEmpty);
      expect(
        result.first,
        contains('Unsupported serverpod version constraint'),
      );
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a compatible sdk version range, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, isEmpty);
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and the min compatible sdk version, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: "3.8.0"
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, isEmpty);
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a high but compatible sdk version, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: ${ProjectFactory.highValidSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, isEmpty);
    },
  );

  test(
    'Given a pubspec without dependencies section and a compatible sdk version, when the projectDependencyIssues method is called, then the result contains the serverpod error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, contains('No serverpod dependency found in pubspec.yaml'));
    },
  );

  test(
    'Given a pubspec without serverpod dependency, when the projectDependencyIssues method is called, then the result contains the serverpod error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(result, contains('No serverpod dependency found in pubspec.yaml'));
    },
  );

  test(
    'Given a pubspec with a flutter dependency, when the projectDependencyIssues method is called, then the result contains the flutter error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '3.29.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(
        result,
        contains(
          'A Flutter dependency is not allowed in a server package: my_project',
        ),
      );
    },
  );

  test(
    'Given a pubspec without serverpod dependency and without sdk constraint, when the projectDependencyIssues method is called, then the result contains both errors',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
dependencies:
'''),
      );

      final result = pubspec.projectDependencyIssues(
        supportedSdkPolicy: supportedSdk,
      );
      expect(
        result,
        allOf([
          contains('No serverpod dependency found in pubspec.yaml'),
          contains('No sdk constraint found in package my_project'),
        ]),
      );
    },
  );

  test(
    'Given a pubspec with serverpod.scripts.flutter_build, when hasFlutterBuildScript is called, then the result is true',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
serverpod:
  scripts:
    flutter_build: dart run tool/build_web.dart
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isTrue);
    },
  );

  test(
    'Given a pubspec without serverpod.scripts.flutter_build, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec without serverpod.scripts, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
serverpod:
  other_field: value
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec without serverpod section, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec with empty raw content, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a null supported sdk constraint and a pubspec without a sdk constraint, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(supportedSdkPolicy: null);
      expect(result, contains('No sdk constraint found in package my_project'));
    },
  );

  test(
    'Given a null supported sdk constraint and a pubspec with a too advanced sdk version, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.999.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(supportedSdkPolicy: null);
      expect(result, isEmpty);
    },
  );

  test(
    'Given a null supported sdk constraint and a pubspec with a flutter dependency, when the projectDependencyIssues method is called, then the result contains the flutter error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '3.29.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues(supportedSdkPolicy: null);
      expect(
        result,
        contains(
          'A Flutter dependency is not allowed in a server package: my_project',
        ),
      );
    },
  );

  group('TenantProjectPubspec.lockfileDependencyIssues', () {
    test(
      'Given a compatible pubspec sdk and an incompatible lockfile sdk, when both are validated, then the lockfile sdk error is returned',
      () async {
        await d.dir('mismatch', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.12.0 <4.0.0"
'''),
        ]).create();

        final pubspec = TenantProjectPubspec(
          Pubspec.parse('''
name: my_project
environment:
  sdk: '^3.10.3'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        );

        final pubspecIssues = pubspec.projectDependencyIssues(
          supportedSdkPolicy: supportedSdk,
        );
        final lockfileIssues = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('mismatch/pubspec.lock')),
          supportedSdkPolicy: supportedSdk,
        );

        expect(pubspecIssues, isEmpty);
        expect(lockfileIssues, isNotEmpty);
        expect(
          lockfileIssues.first,
          contains('Unsupported sdk version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given no pubspec.lock file, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('no_lockfile').create();
        final lockfile = d.path('no_lockfile/pubspec.lock');

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(lockfile),
          supportedSdkPolicy: supportedSdk,
        );
        expect(result, isEmpty);
      },
    );

    test(
      'Given a pubspec.lock with a supported dart sdk constraint, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('supported_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.10.0 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('supported_lockfile/pubspec.lock')),
          supportedSdkPolicy: supportedSdk,
        );
        expect(result, isEmpty);
      },
    );

    test(
      'Given a pubspec.lock with a too advanced dart sdk constraint, when lockfileDependencyIssues is called, then the result contains the sdk error',
      () async {
        await d.dir('advanced_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.12.0 <4.0.0"
  flutter: ">=3.44.0 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('advanced_lockfile/pubspec.lock')),
          supportedSdkPolicy: supportedSdk,
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Unsupported sdk version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a pubspec.lock with a too old dart sdk constraint, when lockfileDependencyIssues is called, then the result contains the sdk error',
      () async {
        await d.dir('old_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.1.0 <3.2.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('old_lockfile/pubspec.lock')),
          supportedSdkPolicy: supportedSdk,
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Unsupported sdk version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a pubspec.lock with an invalid dart sdk constraint, when lockfileDependencyIssues is called, then the result contains a parse error',
      () async {
        await d.dir('invalid_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: not-a-version
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('invalid_lockfile/pubspec.lock')),
          supportedSdkPolicy: supportedSdk,
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Invalid Dart SDK version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a null supported sdk constraint and a pubspec.lock with a too advanced dart sdk constraint, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('advanced_lockfile_no_policy', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.12.0 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('advanced_lockfile_no_policy/pubspec.lock')),
          supportedSdkPolicy: null,
        );
        expect(result, isEmpty);
      },
    );

    test(
      'Given a null supported sdk constraint and a pubspec.lock with an invalid dart sdk constraint, when lockfileDependencyIssues is called, then the result contains a parse error',
      () async {
        await d.dir('invalid_lockfile_no_policy', [
          d.file('pubspec.lock', '''
sdks:
  dart: not-a-version
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('invalid_lockfile_no_policy/pubspec.lock')),
          supportedSdkPolicy: null,
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Invalid Dart SDK version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a pubspec.lock without an sdks section, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('no_sdks_lockfile', [
          d.file('pubspec.lock', '''
packages:
  foo:
    dependency: direct
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('no_sdks_lockfile/pubspec.lock')),
          supportedSdkPolicy: supportedSdk,
        );
        expect(result, isEmpty);
      },
    );
  });
}
